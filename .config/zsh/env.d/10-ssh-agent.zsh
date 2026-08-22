# SSH agent socket resolution.
#
# OpenSSH >= 10 puts the forwarded agent socket at
# ~/.ssh/agent/s.<hash>.sshd.<random> - a fresh path for every SSH session.
# Exporting that path directly means every long-lived process inside tmux
# (shells, nvim, ...) pins a socket that dies with the session that created it,
# and tmux's update-environment only ever fixes *newly created* panes.
#
# So the path we export is always the same symlink, and the symlink is what gets
# repointed on each login. Everything resolves it at connect time, which fixes
# already-running processes too - no environment update needed anywhere.

() {
    local stable=$HOME/.ssh/ssh_auth_sock

    # Only a shell spawned directly by sshd sees a per-session forwarded socket.
    # Anything inheriting from one already has $stable, which does not match this
    # pattern, so nested shells and tmux panes never repoint the symlink.
    if [[ $SSH_AUTH_SOCK == $HOME/.ssh/agent/s.* && -S $SSH_AUTH_SOCK ]]; then
        ln -sfn -- $SSH_AUTH_SOCK $stable
    fi

    # -S follows the symlink, so a dangling one (last SSH session gone) fails here.
    if [[ -S $stable ]]; then
        export SSH_AUTH_SOCK=$stable
    elif [[ -S $XDG_RUNTIME_DIR/ssh-agent.socket ]]; then
        # No agent forwarded in: fall back to the local systemd --user agent.
        export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
    else
        unset SSH_AUTH_SOCK
    fi
}
