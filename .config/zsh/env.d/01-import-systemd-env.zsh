# The "Systemd-Recommended" way to sync the environment

if (( $+commands[systemctl] )); then
    if [[ -n "$XDG_RUNTIME_DIR" ]]; then
        eval "$(systemctl --user show-environment | grep -Ev '^(TERM|DISPLAY|SSH_TTY|SSH_CONNECTION_|SSH_AUTH_)' | sed 's/^/export /')"
    fi
fi
