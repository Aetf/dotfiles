# Include anything in env.d
# (*) is the glob qualifier for executable file
# see http://zsh.sourceforge.net/Doc/Release/Expansion.html#Glob-Qualifiers
if [ -d "$ZDOTDIR/env.d" ]; then
    for i in $ZDOTDIR/env.d/*.zsh(.); do
        source "$i"
    done
fi

# Note on updating systemd user instance and dbus environment variables
# * SDDM will source user default shell rc files in /usr/share/sddm/scripts/{Xsession,wayland-session}
# * SDDM then runs startplasma_{x11,wayland}
# * startplasma_{x11,wayland} will sync all current environment variables to dbus, systemd and klauncher
# This has the problem that in a non-graphical environment, systemd and dbus environemnts are not
# updated.
# Maybe we should sync variable at the end of zprofile.
