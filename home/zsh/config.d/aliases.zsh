# Alias
alias ls='ls --color=auto -h -v --indicator-style=classify'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -al'
alias bd=". bd -si"
alias kfg="kill -- -\$(jobs -p); fg"
alias htop="TERM=screen htop"
function cdmk() {
    mkdir -p "$@"
    cd $1
}
