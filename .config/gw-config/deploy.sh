#!/usr/bin/env bash
# Deploy gw-config to the UDM-SE gateway; --check does a dry-run diff only.
#
# The UDM's /etc is wiped by firmware updates. Everything managed here either
# lives under /data (survives updates) or is reinstalled from /data at boot by
# on_boot.d/0-setup-system.sh. This script pushes the yadm-managed sources of
# truth to both places.
set -euo pipefail
cd "$(dirname "$0")"
mode=${1:---apply}
flags=(-rlpc --delete --itemize-changes)
[[ $mode == --check ]] && flags+=(-n)

ssh gw 'mkdir -p /data/gw-config/nspawn' 2>/dev/null

rsync "${flags[@]}" on_boot.d/ gw:/data/on_boot.d/
rsync "${flags[@]}" nspawn/ gw:/data/gw-config/nspawn/
rsync "${flags[@]}" nspawn/ gw:/etc/systemd/nspawn/
rsync "${flags[@]}" caddy/Caddyfile gw:/data/caddy/config/caddy/Caddyfile

if [[ $mode != --check ]]; then
    ssh gw 'chmod +x /data/on_boot.d/*.sh && systemctl daemon-reload' 2>/dev/null
    echo "Applied. Caddyfile changes additionally need:"
    echo "  ssh gw systemctl restart systemd-nspawn@caddy.service"
fi
