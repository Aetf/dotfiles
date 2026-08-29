#!/bin/bash
# Converge self-managed systemd units from /data/custom/units (source of
# truth, pushed by deploy.sh) into /etc/systemd/system, enabled and running.
#
# /etc/systemd has survived every observed firmware update (Ubiquiti migrates
# /etc), so day-to-day this is a no-op self-heal; it is load-bearing after a
# major-version jump or factory reset where the /etc migration may not happen.
# udm-boot.service is the anchor of the whole on_boot chain: as long as
# /data/custom/units holds a copy, recovering a wiped /etc is one manual
# command (see the README runbook) — everything else then restores itself.
#
# udm-boot.service is only converged and enabled, never restarted: it is the
# oneshot running this very script. Retiring a unit is manual (disable + rm on
# the device); this script does not mirror deletions because /etc/systemd/system
# also holds symlinks and units we do not own.

set -u

srcdir=/data/custom/units
[ -d "$srcdir" ] || exit 0

for src in "$srcdir"/*.service; do
    [ -e "$src" ] || continue
    unit=$(basename "$src")
    dest=/etc/systemd/system/$unit
    changed=0
    if ! cmp -s "$src" "$dest"; then
        echo "units: installing $unit"
        cp "$src" "$dest"
        systemctl daemon-reload
        changed=1
    fi
    systemctl is-enabled "$unit" >/dev/null 2>&1 || systemctl enable "$unit"
    [ "$unit" = udm-boot.service ] && continue
    if [ "$changed" -eq 1 ]; then
        echo "units: restarting $unit to pick up the new unit file"
        systemctl restart "$unit"
    elif ! systemctl is-active --quiet "$unit"; then
        echo "units: starting $unit"
        systemctl start "$unit"
    fi
done
