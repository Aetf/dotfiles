# Alias

## --group --header --modified --accessed are for long mode, but is ignored in normal mode
alias ls='exa --classify --icons --group --header --modified --accessed --time-style=long-iso'
alias ll='ls -l'
alias la='ls -aa'
alias lla='ls -aal'
alias ps='ps xawf -eo pid,user,args'
alias p='paru'
alias open='handlr open'

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

# A handy in mem workspace,
# created by systemd-tmpfiles-setup
# and have a shortcurt: alias work='cd ~work'
export work=/dev/shm/$USER/workspace
alias work='cd ~work'

# The ansible dotfiles
export spec=$HOME/.local/spec
alias spec='cd ~spec'
