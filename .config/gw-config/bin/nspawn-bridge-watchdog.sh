#!/bin/bash
# Nspawn bridge watchdog (worker for units/nspawn-bridge-watchdog.service).
#
# systemd-nspawn's Bridge= enrolls each container's vb-* veth into its bridge
# at start, but on this firmware the veth can come back detached after a
# container restart. This watchdog re-attaches any vb-* interface whose
# master is not the bridge named in its container's .nspawn file.

DEFAULT_BRIDGE="br5"
SEARCH_PATHS=("/etc/systemd/nspawn")

echo "Starting Nspawn Bridge Watchdog..."

# Parse container config to find the intended bridge.
get_bridge_for_container() {
    local container_name="$1"
    local config_bridge=""

    for path in "${SEARCH_PATHS[@]}"; do
        local config_file="$path/$container_name.nspawn"
        if [[ -f "$config_file" ]]; then
            config_bridge=$(grep -i "^Bridge=" "$config_file" | cut -d= -f2 | tr -d '[:space:]')
            if [[ -n "$config_bridge" ]]; then
                echo "$config_bridge"
                return
            fi
        fi
    done
    echo "$DEFAULT_BRIDGE"
}

# Check and fix a specific interface.
process_interface() {
    local raw_iface="$1"

    # Strip the '@ifX' suffix (e.g., vb-adguard@if8 -> vb-adguard); it is
    # strictly visual output from 'ip link', the real device name has no @.
    local iface="${raw_iface%%@*}"

    # We only care about 'vb-' (Virtual Bridge) interfaces.
    if [[ "$iface" =~ ^vb-(.*) ]]; then
        local container_name="${BASH_REMATCH[1]}"
        local target_bridge=$(get_bridge_for_container "$container_name")

        # If target bridge doesn't exist, skip silently.
        if ! ip link show "$target_bridge" > /dev/null 2>&1; then return; fi

        # If already attached, skip silently.
        if ip -d link show "$iface" | grep -q "master $target_bridge"; then return; fi

        echo "FIX: Re-attaching $iface ($container_name) to $target_bridge"
        ip link set dev "$iface" master "$target_bridge"
    fi
}

# 1. Catch-up: scan all existing interfaces on startup.
for iface in $(ip link show | awk -F': ' '/vb-/ {print $2}'); do
    process_interface "$iface"
done

# 2. Monitor: listen for kernel NEWLINK events.
#    --line-buffered ensures immediate pipe processing.
ip monitor link | grep --line-buffered "vb-" | while read -r line; do
    if [[ "$line" =~ ^[0-9]+:[[:space:]]+(vb-[^:]+): ]]; then
        process_interface "${BASH_REMATCH[1]}"
    fi
done
