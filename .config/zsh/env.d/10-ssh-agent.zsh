# SSH agent socket resolution.
#
# sshd hands each session a *per-session* agent socket path: OpenSSH >= 10 puts
# it at ~/.ssh/agent/s.<hash>.sshd.<random>, older ones (macOS still) at
# /tmp/ssh-<random>/agent.<pid>. Exporting that verbatim means every long-lived
# process inside a tmux pane pins a socket that dies with the session that
# created it, and tmux's update-environment only ever fixes *newly created*
# panes.
#
# So the path we export is a fixed symlink, and the symlink is what gets
# repointed on each login. Everything resolves it at connect time, which fixes
# already-running processes too - no environment update needed anywhere.
#
# Anything else that already works is left alone: the macOS Keychain agent,
# gpg-agent, gnome-keyring. Only sshd's own per-session paths are rewritten.

() {
    local stable=$HOME/.ssh/ssh_auth_sock

    case ${SSH_AUTH_SOCK-} in
        ($HOME/.ssh/agent/s.*|/tmp/ssh-*/agent.*|/private/tmp/ssh-*/agent.*)
            if [[ -S ${SSH_AUTH_SOCK-} ]]; then
                # Spawned directly by sshd. Claim the socket and forget the path
                # it arrived under; nothing downstream should ever see it.
                ln -sfn -- $SSH_AUTH_SOCK $stable
                export SSH_AUTH_SOCK=$stable
                return
            fi
            # A dead per-session path inherited from some older session.
            unset SSH_AUTH_SOCK
            ;;
    esac

    # Already holding something that works, $stable included. -S follows the
    # symlink, so a dangling one does not count.
    [[ -S ${SSH_AUTH_SOCK-} ]] && return

    if [[ -S $stable ]]; then
        export SSH_AUTH_SOCK=$stable
    elif [[ -n ${XDG_RUNTIME_DIR-} && -S $XDG_RUNTIME_DIR/ssh-agent.socket ]]; then
        # Linux with the systemd --user agent and no agent forwarded in.
        export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
    else
        unset SSH_AUTH_SOCK
    fi
}
