#!/bin/bash
# Reinstall the dpkg packages that firmware updates wipe, and keep the offline
# deb cache in /data/custom/dpkg current.
#
# Firmware updates wipe /usr and /var — every apt-installed package, the dpkg
# records of them, and the apt lists — while the new firmware image ships its
# own base-package dpkg database. So on the first boot after an update this
# script must run before any nspawn container can start: systemd-nspawn and
# machinectl live in systemd-container, and libnss-mymachines is version-locked
# to it, so both must be installed in the same transaction.
#
# Cache design: when apt succeeds on a post-update boot, the debs it downloads
# are exactly the set missing from the new firmware base (dependency closure
# included, resolved against the firmware's own dpkg database). That snapshot
# atomically replaces /data/custom/dpkg. The cache is consumed only when apt is
# unreachable on a post-update boot; a stale cache cannot persist silently
# because every successful apt install refreshes it against the running
# firmware.

set -u

PACKAGES=(systemd-container libnss-mymachines rsync)
CACHE=/data/custom/dpkg

installed() {
    local p
    for p in "${PACKAGES[@]}"; do
        dpkg -s "$p" 2>/dev/null | grep -q '^Status: install ok installed' || return 1
    done
}

if installed; then
    echo "packages: ${PACKAGES[*]} all present, nothing to do"
    exit 0
fi

echo "packages: installing ${PACKAGES[*]} via apt (post-firmware-update boot)..."
# /var/lib/apt/lists is empty after a firmware update; without an update the
# install below cannot resolve anything. Its own failure is not fatal — the
# install will fail and we fall back to the cache.
apt-get update || echo "packages: apt-get update failed, continuing"

if apt-get install -y "${PACKAGES[@]}"; then
    echo "packages: refreshing the offline cache in $CACHE"
    # Ensure every package of the set is present in the archives dir, not just
    # the ones this boot happened to install (a partially-surviving set would
    # otherwise produce a partial cache).
    apt-get install -y --download-only --reinstall "${PACKAGES[@]}" ||
        echo "packages: cache refresh download failed, keeping the old cache"
    if compgen -G '/var/cache/apt/archives/*.deb' >/dev/null; then
        rm -rf "$CACHE.new" "$CACHE.old"
        mkdir -p "$CACHE.new"
        cp /var/cache/apt/archives/*.deb "$CACHE.new/"
        [ -d "$CACHE" ] && mv "$CACHE" "$CACHE.old"
        mv "$CACHE.new" "$CACHE"
        rm -rf "$CACHE.old"
    fi
    exit 0
fi

echo "packages: apt failed, falling back to the offline cache $CACHE"
# One dpkg -i invocation with every cached deb: dpkg orders the closure itself.
if compgen -G "$CACHE/*.deb" >/dev/null && yes | dpkg -i "$CACHE"/*.deb; then
    exit 0
fi
echo "packages: FAILED — neither apt nor the offline cache could install ${PACKAGES[*]}" >&2
exit 1
