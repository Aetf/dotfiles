# SSH agent socket resolution.
#
# sshd hands each session a *per-session* agent socket path: OpenSSH >= 10 puts
# it at ~/.ssh/agent/s.<hash>.sshd.<random>, older ones (macOS still) at
# /tmp/ssh-<random>/agent.<pid>. Exporting that verbatim means every long-lived
# process inside a tmux pane pins a socket that dies with the session that
# created it, and tmux's update-environment only ever fixes *newly created*
# panes.
#
# So the path a login session exports is a fixed symlink, and the symlink is
# what gets repointed on each login. Everything resolves it at connect time,
# which fixes already-running processes too - no environment update needed.
#
# Three things are deliberately structural here, not probed:
#
# - An explicitly empty SSH_AUTH_SOCK means "no agent" and is left alone. ssh
#   itself reads it that way. This is how tool runners (Claude Code's Bash
#   tool on headless hosts) and `SSH_AUTH_SOCK= git push` opt out.
# - Only a login shell may claim the shared symlink or go looking for an
#   agent. A non-login shell is `ssh host cmd`, a script shim, a service: it
#   lives seconds, so pointing the machine-wide symlink at its forwarded
#   socket would strand every tmux pane on a socket that dies with it - and
#   when the command was `ssh <this very host>`, the forwarded socket chains
#   back to the symlink itself and every agent request loops forever.
# - Liveness is `-S` (the file exists), never a connect(). A socket whose
#   sshd-session is still alive but whose client vanished accepts connections
#   and never answers; probing it from here would queue one dead connection
#   per shell start until its backlog fills and connect() itself blocks -
#   turning "ssh hangs" into "every zsh hangs". That state is prevented at the
#   source (sshd ClientAlive, ssh ServerAlive, ForwardAgent no to oneself) and
#   swept by ssh-agent-socket-gc, which can afford a timeout.
#
# Anything else that already works is left alone: the macOS Keychain agent,
# gpg-agent, gnome-keyring, the systemd --user agent a desktop session
# inherited. Only sshd's own per-session paths are rewritten.

() {
    (( ${+SSH_AUTH_SOCK} )) && [[ -z $SSH_AUTH_SOCK ]] && return

    local stable=$HOME/.ssh/ssh_auth_sock

    if [[ ! -o login ]]; then
        [[ -S ${SSH_AUTH_SOCK-} ]] || unset SSH_AUTH_SOCK
        return
    fi

    case ${SSH_AUTH_SOCK-} in
        ($HOME/.ssh/agent/s.*|/tmp/ssh-*/agent.*|/private/tmp/ssh-*/agent.*)
            if [[ -S $SSH_AUTH_SOCK ]]; then
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

    # Keep what we hold if it exists ($stable included; -S follows the
    # symlink, so a dangling one does not count), else the symlink, else the
    # systemd --user agent, else nothing.
    local cand
    for cand in ${SSH_AUTH_SOCK-} $stable ${XDG_RUNTIME_DIR:+$XDG_RUNTIME_DIR/ssh-agent.socket}; do
        if [[ -S $cand ]]; then
            export SSH_AUTH_SOCK=$cand
            return
        fi
    done
    unset SSH_AUTH_SOCK
}
