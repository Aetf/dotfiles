# The "Systemd-Recommended" way to sync the environment

# PATH is excluded on purpose. This file is sourced twice for a login shell
# (once from .zshenv, once from .zprofile), and the systemd user manager's PATH
# is the bare default `/usr/local/bin:/usr/bin`. Importing it is a plain
# assignment, so the .zprofile pass would throw away everything /etc/profile
# added in between -- /usr/local/sbin, /usr/bin/*_perl and, the one that hurt,
# /usr/lib/rustup/bin (rustup's shims, i.e. rust-analyzer). PATH belongs to
# 05-paths.zsh and to whatever appends to it later; systemd has nothing to say
# about it that the inherited value doesn't already cover.
#
# PWD/OLDPWD/SHLVL are excluded for the same reason, one class worse: they are
# per-process shell state, not session configuration. startplasma imports the
# whole session environment into the systemd user manager, so PWD is frozen at
# whatever it was during login -- $HOME. Re-exporting it here made every shell
# claim $PWD=$HOME no matter where it was actually started, which only zsh's own
# `cd` (or `pwd`/`%~`, which read the real cwd) ever corrected.
if (( $+commands[systemctl] )); then
    if [[ -n "$XDG_RUNTIME_DIR" ]]; then
        eval "$(systemctl --user show-environment | grep -Ev '^(PATH|TERM|DISPLAY|SSH_TTY|SSH_CONNECTION|SSH_AUTH_|PWD|OLDPWD|SHLVL)' | sed 's/^/export /')"
    fi
fi
