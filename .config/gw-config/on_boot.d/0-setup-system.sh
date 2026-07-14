#!/bin/bash
# This script installs systemd-container if it's not installed.
# Also links any containers from /data/custom/machines to /var/lib/machines.

set -e

if ! dpkg -l systemd-container | grep ii >/dev/null; then
    if ! apt -y install systemd-container debootstrap; then
        yes | dpkg -i /data/custom/dpkg/*.deb
    fi
fi

# rsync is needed by gw-config's deploy.sh (drift check / apply from homelab)
if ! command -v rsync >/dev/null; then
    apt -y install rsync || yes | dpkg -i /data/custom/dpkg/rsync_*.deb
fi

# Firmware update persistence model (verified against 6 updates,
# 2025-12..2026-06, via dpkg.log and file mtimes):
#   - /data always persists
#   - hand-placed files in /etc have SURVIVED every observed update
#     (Ubiquiti migrates /etc), but this is undocumented behavior
#   - dpkg/apt-installed packages are WIPED on every update
# So the package reinstalls here are load-bearing every single update,
# while this nspawn restore is insurance against a major-version jump
# or factory reset where /etc migration might not happen. It runs
# BEFORE the machines get linked and started below, so they never come
# up without their bridge/network config.
if [ -d /data/gw-config/nspawn ]; then
    mkdir -p /etc/systemd/nspawn
    if ! diff -rq /data/gw-config/nspawn /etc/systemd/nspawn >/dev/null 2>&1; then
        cp /data/gw-config/nspawn/*.nspawn /etc/systemd/nspawn/
        systemctl daemon-reload
    fi
fi

mkdir -p /var/lib/machines
for machine in $(ls /data/custom/machines/); do
	if [ ! -e "/var/lib/machines/$machine" ]; then
		ln -s "/data/custom/machines/$machine" "/var/lib/machines/"
		machinectl enable $machine
		machinectl start $machine
	fi
done
