# Make sure various path are unique
local varnames=(
    PATH
    MANPATH

    LIBRARY_PATH
    LD_LIBRARY_PATH
    LIB

    INCLUDE
    CPATH

    PKG_CONFIG_PATH
    CMAKE_PREFIX_PATH
)
for varname ($varnames) {
    # tie (-T) UPPERCASE_PATH to lowercase_path (:l), the UPPERCASE_PATH is scalar, lowercase_path is array.
    # and make sure there is no duplication (-U), global (-g), and exported (-x)
    typeset -T -Ugx $varname ${varname:l}
}

# Extra Path
if [ -d $HOME/.local/bin ]; then
    uappend path $HOME/.local/bin
fi

# Holds only the sudo shim, which must shadow /usr/bin/sudo; the rest of
# ~/.local/bin stays behind the system paths.
if [ -d $HOME/.local/lib/sudo-shim ]; then
    uprepend path $HOME/.local/lib/sudo-shim
fi

if [ -d $XDG_DATA_HOME/zsh/zinit/polaris/bin ]; then
    uprepend path $XDG_DATA_HOME/zsh/zinit/polaris/bin
fi
