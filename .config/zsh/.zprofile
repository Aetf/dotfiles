# Source ordering: .zshenv → [.zprofile if login] → [.zshrc if interactive] → [.zlogin if login] → [.zlogout sometimes]

# env.d is NOT sourced here. It is sourced from .zshenv, which zsh's own manual
# names as the place for "the command search path, plus other important
# environment variables" - and which is the only file that covers the shells
# that actually need it: the zinit sbin shims (just, yadm, rg, fd, mise, ...)
# are `#!/usr/bin/env zsh` scripts, plus `ssh host cmd`, systemd units, and any
# non-login terminal. .zshenv strictly covers everything .zprofile would.
#
# It used to be sourced from both, which was a leftover from 1be47e6 (the commit
# that added the .zshenv pass and forgot to remove this one). That cost three
# full passes per login shell, not two: the loop here did not skip index.zsh the
# way indexer() does, so it triggered a whole extra round. Harmless for the
# idempotent uprepend/uappend helpers - but this was the only pass that ran
# *after* /etc/zsh/zprofile, so a plain assignment in env.d would throw away
# whatever /etc/profile had just appended. That is exactly what happened to
# PATH, see env.d/01-import-systemd-env.zsh.

# Note on updating systemd user instance and dbus environment variables
# * SDDM will source user default shell rc files in /usr/share/sddm/scripts/{Xsession,wayland-session}
# * SDDM then runs startplasma_{x11,wayland}
# * startplasma_{x11,wayland} will sync all current environment variables to dbus, systemd and klauncher
# This has the problem that in a non-graphical environment, systemd and dbus environemnts are not
# updated.
# Maybe we should sync variable at the end of zprofile.
