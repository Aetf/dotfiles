# The config starship reads. starship reads a single file and has no include
# mechanism, so base.toml in ~/.config/starship is concatenated with
# $starship_fragments into the cache, and STARSHIP_CONFIG points there. Other
# configs register their own fragments (tables only) with
# `starship_fragments+=(path)`. The file is rebuilt before a prompt when a
# fragment is newer or the list changed.

typeset -ga starship_fragments
typeset -g _starship_src=${XDG_CONFIG_HOME:-$HOME/.config}/starship
typeset -g _starship_out=${XDG_CACHE_HOME:-$HOME/.cache}/starship
typeset -g _starship_built  # fragment list the cached config was built from

function _starship_build_config() {
    local -a parts=($_starship_src/base.toml $starship_fragments)
    local out=$_starship_out/config.toml
    local stale=0 p
    [[ $_starship_built == ${(j:\n:)parts} && -e $out ]] || stale=1
    for p in $parts; do
        [[ $p -nt $out ]] && stale=1
    done
    if (( stale )); then
        mkdir -p $_starship_out && cat $parts >| $out.$$ && mv -f $out.$$ $out &&
            _starship_built=${(j:\n:)parts}
    fi
    export STARSHIP_CONFIG=$out
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _starship_build_config
