#!/bin/bash
# Link container rootfs from /data/custom/machines into /var/lib/machines
# (wiped by firmware updates) and converge every machine to enabled+running —
# every boot, not just when the symlink is missing, so a machine left disabled
# or stopped is corrected too.
#
# Uses systemctl on the systemd-nspawn@ template rather than machinectl:
# machinectl enable/start is a thin wrapper producing the identical
# machines.target.wants symlink and unit start (machinectl list/status/shell
# keep working regardless — they query machined, which registers containers at
# runtime). systemctl is part of the firmware base, so linking and enabling
# still succeed even if 10-packages.sh failed; only the start itself needs
# systemd-container.

set -u

mkdir -p /var/lib/machines
# machinectl enable would do this implicitly; systemctl enable of the
# instance units does not.
systemctl is-enabled machines.target >/dev/null 2>&1 || systemctl enable machines.target

failed=0
for dir in /data/custom/machines/*/; do
    [ -d "$dir" ] || continue
    machine=$(basename "$dir")
    # homelab-containers `just deploy` keeps rollback rootfs copies next to
    # the live ones; those must never be linked or started.
    case "$machine" in
        *.old|*.new|*.failed) continue ;;
    esac
    if [ ! -e "/var/lib/machines/$machine" ]; then
        echo "machines: linking $machine"
        ln -s "/data/custom/machines/$machine" /var/lib/machines/
    fi
    unit="systemd-nspawn@$machine.service"
    systemctl is-enabled "$unit" >/dev/null 2>&1 || systemctl enable "$unit"
    if ! systemctl is-active --quiet "$unit"; then
        echo "machines: starting $machine"
        systemctl start "$unit" || { echo "machines: FAILED to start $machine" >&2; failed=1; }
    fi
done
exit "$failed"
