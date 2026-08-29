#!/bin/bash
# Mirror /data/custom/nspawn (source of truth, pushed by deploy.sh) into
# /etc/systemd/nspawn, the live copies systemd-nspawn@.service reads at
# container start.
#
# Same persistence reasoning as 20-units.sh: /etc has survived every observed
# firmware update, so this is insurance for a major jump or factory reset. It
# runs BEFORE the machines are started by 40-machines.sh so a container never
# comes up without its bridge/network config. Unlike /etc/systemd/system this
# directory is wholly ours, so it is a true mirror: *.nspawn files absent from
# the source are removed (a retired container stays retired on a recovery
# boot, not just after a deploy).

set -u

src=/data/custom/nspawn
[ -d "$src" ] || exit 0
mkdir -p /etc/systemd/nspawn

for f in "$src"/*.nspawn; do
    [ -e "$f" ] || continue
    if ! cmp -s "$f" "/etc/systemd/nspawn/$(basename "$f")"; then
        echo "nspawn-units: installing $(basename "$f")"
        cp "$f" /etc/systemd/nspawn/
    fi
done

for f in /etc/systemd/nspawn/*.nspawn; do
    [ -e "$f" ] || continue
    if [ ! -e "$src/$(basename "$f")" ]; then
        echo "nspawn-units: removing stale $(basename "$f")"
        rm "$f"
    fi
done
