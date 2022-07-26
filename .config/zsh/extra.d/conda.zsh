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
}

