# load work
() {
    local candidates=(
        "$XDG_CONFIG_HOME/work/zsh/index.zsh"
    )
    for candidate in $candidates; do
        if [ -f "$candidate" ]; then
            source "$candidate"
        fi
    done
}

