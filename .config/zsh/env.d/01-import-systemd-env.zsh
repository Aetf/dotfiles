# The "Systemd-Recommended" way to sync the environment

# PATH is excluded on purpose. This file is sourced twice for a login shell
# (once from .zshenv, once from .zprofile), and the systemd user manager's PATH
# is the bare default `/usr/local/bin:/usr/bin`. Importing it is a plain
# assignment, so the .zprofile pass would throw away everything /etc/profile
# added in between -- /usr/local/sbin, /usr/bin/*_perl and, the one that hurt,
# /usr/lib/rustup/bin (rustup's shims, i.e. rust-analyzer). PATH belongs to
# 05-paths.zsh and to whatever appends to it later; systemd has nothing to say
# about it that the inherited value doesn't already cover.
if (( $+commands[systemctl] )); then
    if [[ -n "$XDG_RUNTIME_DIR" ]]; then
        eval "$(systemctl --user show-environment | grep -Ev '^(PATH|TERM|DISPLAY|SSH_TTY|SSH_CONNECTION_|SSH_AUTH_)' | sed 's/^/export /')"
    fi
fi
