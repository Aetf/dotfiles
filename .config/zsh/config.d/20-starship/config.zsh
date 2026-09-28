# The config starship reads. starship has no include mechanism, so the config
# is assembled from fragments in ~/.config/starship: base.toml + (jj.toml
# inside a jj workspace, git.toml elsewhere) + $starship_fragments. Other
# configs register their own fragments (tables only) with
# `starship_fragments+=(path)`. Each variant is concatenated into the cache and
# rebuilt when a fragment is newer or the list changed; STARSHIP_CONFIG is
# switched per prompt without forking.

typeset -ga starship_fragments
typeset -g _starship_src=${XDG_CONFIG_HOME:-$HOME/.config}/starship
typeset -g _starship_out=${XDG_CACHE_HOME:-$HOME/.cache}/starship
typeset -gA _starship_built  # vcs -> fragment list the cached config was built from

function _starship_pick_config() {
    local vcs=git dir=$PWD
    while [[ -n $dir ]]; do
        [[ -d $dir/.jj ]] && { vcs=jj; break }
        [[ $dir == / ]] && break
        dir=${dir:h}
    done
    local out=$_starship_out/config-$vcs.toml
    local -a parts=($_starship_src/base.toml $_starship_src/$vcs.toml $starship_fragments)
    local stale=0 p
    [[ ${_starship_built[$vcs]-} == ${(j:\n:)parts} && -e $out ]] || stale=1
    for p in $parts; do
        [[ $p -nt $out ]] && stale=1
    done
    if (( stale )); then
        mkdir -p $_starship_out && cat $parts >| $out.$$ && mv -f $out.$$ $out &&
            _starship_built[$vcs]=${(j:\n:)parts}
    fi
    export STARSHIP_CONFIG=$out
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _starship_pick_config
