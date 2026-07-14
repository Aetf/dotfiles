#!/bin/bash

# ==============================================================================
# UniFi Systemd-Nspawn Bridge Manager (On-Boot / Idempotent)
# Location: /data/on_boot.d/10-nspawn-bridge-watchdog.sh
#
# Description:
#   1. When run without arguments (e.g., by UDM boot process), it installs/updates
#      the systemd unit and ensures the service is running.
#   2. When run with 'watchdog', it performs the active bridge monitoring.
# ==============================================================================

SERVICE_NAME="nspawn-bridge-watchdog.service"
# Resolve the absolute path of this script to ensure systemd finds it
SCRIPT_PATH="$(readlink -f "$0")"

# --- Configuration ---
DEFAULT_BRIDGE="br5"
SEARCH_PATHS=("/etc/systemd/nspawn")

# ==============================================================================
# LOGIC: Reactive Watchdog (The "Worker")
# ==============================================================================
do_watchdog() {
    echo "Starting Nspawn Bridge Watchdog..."

    # Helper: Parse container config to find intended bridge
    get_bridge_for_container() {
        local container_name="$1"
        local config_bridge=""

        for path in "${SEARCH_PATHS[@]}"; do
            local config_file="$path/$container_name.nspawn"
            if [[ -f "$config_file" ]]; then
                # Extract 'Bridge=' value
                config_bridge=$(grep -i "^Bridge=" "$config_file" | cut -d= -f2 | tr -d '[:space:]')
                if [[ -n "$config_bridge" ]]; then
                    echo "$config_bridge"
                    return
                fi
            fi
        done
        echo "$DEFAULT_BRIDGE"
    }

    # Helper: Check and fix a specific interface
    process_interface() {
        local raw_iface="$1"
        
        # CLEANUP: Strip the '@ifX' suffix (e.g., vb-adguard@if8 -> vb-adguard)
        # This is strictly visual output from 'ip link'; the real device name has no @.
        local iface="${raw_iface%%@*}"
        
        # We only care about 'vb-' (Virtual Bridge) interfaces
        if [[ "$iface" =~ ^vb-(.*) ]]; then
            local container_name="${BASH_REMATCH[1]}"
            local target_bridge=$(get_bridge_for_container "$container_name")
            
            # If target bridge doesn't exist, skip silently
            if ! ip link show "$target_bridge" > /dev/null 2>&1; then return; fi

            # If already attached, skip silently
            if ip -d link show "$iface" | grep -q "master $target_bridge"; then return; fi

            echo "FIX: Re-attaching $iface ($container_name) to $target_bridge"
            ip link set dev "$iface" master "$target_bridge"
        fi
    }

    # 1. Catch-up: Scan all existing interfaces on startup
    for iface in $(ip link show | awk -F': ' '/vb-/ {print $2}'); do
        process_interface "$iface"
    done

    # 2. Monitor: Listen for Kernel NEWLINK events
    #    --line-buffered ensures immediate pipe processing
    ip monitor link | grep --line-buffered "vb-" | while read -r line; do
        if [[ "$line" =~ ^[0-9]+:[[:space:]]+(vb-[^:]+): ]]; then
            process_interface "${BASH_REMATCH[1]}"
        fi
    done
}

# ==============================================================================
# LOGIC: Installer (The "Boot" process)
# ==============================================================================
do_install() {
    echo "--- UniFi Nspawn Bridge Watchdog Setup ---"
    
    # 1. Define the Systemd Unit content
    #    We point ExecStart to THIS script path with the 'watchdog' argument.
    UNIT_CONTENT="[Unit]
Description=Automated Bridge Watchdog for Systemd-Nspawn
After=network.target

[Service]
ExecStart=${SCRIPT_PATH} watchdog
Restart=always
RestartSec=5
Nice=10

[Install]
WantedBy=multi-user.target"

    UNIT_FILE="/etc/systemd/system/${SERVICE_NAME}"

    # 2. Write Unit File (Idempotent: Overwrites ensure correctness)
    echo "Updating systemd unit at ${UNIT_FILE}..."
    echo "$UNIT_CONTENT" > "$UNIT_FILE"

    # 3. Reload Systemd (Idempotent)
    systemctl daemon-reload

    # 4. Enable Service (Idempotent)
    systemctl enable "$SERVICE_NAME"

    # 5. Restart Service
    #    We force restart to ensure the running process matches the current script version.
    echo "Restarting service to apply latest configuration..."
    systemctl restart "$SERVICE_NAME"

    echo "--- Setup Complete. Status: ---"
    systemctl is-active "$SERVICE_NAME"
}

# ==============================================================================
# ENTRY POINT
# ==============================================================================

if [ "$1" == "watchdog" ]; then
    do_watchdog
else
    do_install
fi
