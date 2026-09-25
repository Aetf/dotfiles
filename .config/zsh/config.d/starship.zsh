# Starship prompt integration.
#
# Config: starship has no include mechanism, so the config is assembled from
# fragments in ~/.config/starship: base.toml + (jj.toml inside a jj workspace,
# git.toml elsewhere) + $starship_fragments. Other configs register their own
# fragments (tables only) with `starship_fragments+=(path)`. Each variant is
# concatenated into the cache and rebuilt when a fragment is newer or the list
# changed; STARSHIP_CONFIG is switched per prompt without forking.
#
# Rendering: starship draws only the first line, once per precmd, into
# $_prompt_line. The prompt character on the second line is drawn by zsh from
# zsh-vi-mode's mode, so mode switches and the transient prompt only re-expand
# variables instead of rerunning starship (which would redo git status).
# _prompt_starship_setup runs after `starship init` (zinit atload in .zshrc).

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

autoload -Uz add-zsh-hook add-zle-hook-widget
add-zsh-hook precmd _starship_pick_config

typeset -g _prompt_line _prompt_char _prompt_color _prompt_starship_cmd

function _prompt_update_char() {
    local sym
    case ${ZVM_MODE-} in
        n) sym='❮' ;;
        v|vl) sym='V' ;;
        r) sym='▶' ;;
        *) sym='❯' ;;
    esac
    _prompt_char="%F{$_prompt_color}$sym%f "
}

function _prompt_render() {
    # $? is still the last command's status in every precmd hook.
    if (( $? )); then _prompt_color=196; else _prompt_color=76; fi
    _prompt_line=${(e)_prompt_starship_cmd}
    _prompt_update_char
    PROMPT=$'${_prompt_line}\n${_prompt_char}'
}

# Transient prompt: once a line is accepted, redraw it as just the prompt character.
function _prompt_transient() {
    PROMPT="%F{$_prompt_color}❯%f "
    zle .reset-prompt
}

# The first line holds a width-dependent filler; redraw it for the new width.
function TRAPWINCH() {
    [[ -n $_prompt_starship_cmd ]] && zle || return 0
    _prompt_line=${(e)_prompt_starship_cmd}
    zle .reset-prompt
    return 0
}

function _prompt_starship_setup() {
    # `starship init` set PROMPT to its `$(starship prompt ...)` command; keep
    # that as the renderer. The right prompt is unused, so drop its second fork.
    _prompt_starship_cmd=$PROMPT
    RPROMPT=
    add-zsh-hook precmd _prompt_render  # after starship's precmd sets its variables
    add-zle-hook-widget line-finish _prompt_transient
    zvm_after_select_vi_mode_commands+=(_prompt_update_char)
}
