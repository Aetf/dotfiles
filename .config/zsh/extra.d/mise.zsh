() {
    if whence -p mise &>/dev/null; then
        eval "$(mise activate zsh)"
    fi
}

if (( $+functions[_mise_hook_chpwd] )); then
    # Update the environment on cd only. The precmd hook reruns mise after
    # every command (15-25 ms, mostly mise's own startup) to catch config
    # edits in the current directory; after editing mise.toml, `mise use`,
    # `mise install` or exporting MISE_* variables, `cd .` applies them.
    add-zsh-hook -d precmd _mise_hook_precmd

    # mise_static_paths: glob patterns for trees that hold no mise config
    # and are slow to search (network filesystems). mise runs when entering
    # one from outside, so tools and variables from the previous project are
    # dropped, and not again while moving within it.
    typeset -ga mise_static_paths
    typeset -gi _mise_in_static=0
    function _mise_static() {
        local p
        for p in $mise_static_paths; do
            [[ $PWD == ${~p} ]] && return 0
        done
        return 1
    }
    function _mise_chpwd() {
        if _mise_static; then
            (( _mise_in_static )) && return 0
            _mise_in_static=1
        else
            _mise_in_static=0
        fi
        _mise_hook_chpwd
    }
    chpwd_functions[${chpwd_functions[(i)_mise_hook_chpwd]}]=_mise_chpwd
    # Activation above has just run mise for $PWD.
    _mise_static && _mise_in_static=1
fi
