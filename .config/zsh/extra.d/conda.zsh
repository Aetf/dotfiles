# load conda
() {
    local candidates=(
        "/opt/mambaforge/etc/profile.d/mamba.sh"
        "/opt/mambaforge/etc/profile.d/conda.sh"
        "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    )
    for candidate in $candidates; do
        if [ -f "$candidate" ]; then
            source "$candidate"
        fi
    done

    # see if we have micromamba
    if (( $+commands[micromamba] )); then
        export MAMBA_ROOT_PREFIX=$XDG_DATA_HOME/micromamba
        mkdir -p "$MAMBA_ROOT_PREFIX"
        eval "$(micromamba shell hook --shell zsh --prefix "$MAMBA_ROOT_PREFIX" 2>/dev/null)"
        alias mamba=micromamba
    fi
}

