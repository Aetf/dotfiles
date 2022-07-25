# SSH-agent is managed by systemd --user scope
() {
    if [[ -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ]]; then
        export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
    fi
}
