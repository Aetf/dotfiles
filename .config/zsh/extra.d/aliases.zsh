# Alias

## --group --header --modified --accessed are for long mode, but is ignored in normal mode
## --links shows hardlink count
alias ls='eza --classify --icons --links --group --header --modified --accessed --time-style=long-iso'
alias ll='ls -l'
alias la='ls -aa'
alias lla='ls -aal'
alias p='paru'

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias open='xdg-open'
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS equivalent (flat view, wide output)
    alias ps='ps axww -o pid,user,command'
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux equivalent (forest view)
    alias ps='ps xawf -eo pid,user,args'
fi

() {{
    touch /tmp/test
    if rm --preserve-root /tmp/test &>/dev/null ; then
        alias rm='rm -I --preserve-root'
    else
        alias rm='rm -I'
    fi
} always {
    command rm -f /tmp/test
}}

() {
    if ! hash nproc &>/dev/null; then
        alias nproc='sysctl -n hw.physicalcpu'
    fi
}

function cdmk() {
    mkdir -p "$@"
    cd $1
}
function htop() {
    local htoprc=$XDG_CONFIG_HOME/htop/htoprc.low
    if [[ $(tput lines) -gt 50 ]]; then
        htoprc=$XDG_CONFIG_HOME/htop/htoprc.high
    fi
    env TERM=screen HTOPRC=$htoprc htop "$@"
}

# Better cd that goes to file's parent directory automatically
function cd() {
    if [[ -n "$1" && ! -d "$1" ]]; then
        builtin cd "${1%/*}"
    else
        builtin cd "$@"
    fi
}

# Gmailctl doesn't support xdg config dir
# See https://github.com/mbrt/gmailctl/issues/144
function gmailctl() {
    mkdir -p "$GMAILCTL_CONFIG_DIR"
    command gmailctl --config="$GMAILCTL_CONFIG_DIR" "$@"
}

# A handy in mem workspace,
# created by systemd-tmpfiles-setup
# and have a shortcurt: alias work='cd ~work'
export work=/dev/shm/$USER/workspace
alias work='cd ~work'
