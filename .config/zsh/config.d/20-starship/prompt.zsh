# The zsh prompt around starship.
#
# starship draws only the first line, once per precmd, into $_prompt_line. The
# prompt character on the second line is drawn by zsh from zsh-vi-mode's mode,
# so mode switches and the transient prompt only re-expand variables instead
# of rerunning starship. prompt_starship_redraw reruns starship and redraws in
# place, for inputs that change after precmd.
# _prompt_starship_setup runs after `starship init` (zinit atload in .zshrc).

autoload -Uz add-zsh-hook add-zle-hook-widget

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

# Render starship's line one column narrower than the terminal (p10k's
# ZLE_RPROMPT_INDENT=1 margin): Konsole's "Clear Scrollback and Reset" nudges
# the pty to COLUMNS+1 and back without resizing its screen, and a full-width
# line rendered in that window wraps and pushes the second line down. -h hides
# COLUMNS' special meaning, so zle keeps the real width.
function _prompt_render_line() {
    local -h COLUMNS=$((COLUMNS - 1))
    _prompt_line=${(e)_prompt_starship_cmd}
}

function _prompt_render() {
    # $? is still the last command's status in every precmd hook.
    if (( $? )); then _prompt_color=196; else _prompt_color=76; fi
    _prompt_render_line
    _prompt_update_char
    PROMPT=$'${_prompt_line}\n${_prompt_char}'
}

# Transient prompt: once a line is accepted, redraw it as just the prompt character.
function _prompt_transient() {
    PROMPT="%F{$_prompt_color}❯%f "
    zle .reset-prompt
}

# Rerun starship for the first line and redraw the prompt in place, for inputs
# that change after precmd (window size, background segments). No-op outside
# zle.
function prompt_starship_redraw() {
    [[ -n $_prompt_starship_cmd ]] && zle || return 0
    _prompt_render_line
    zle .reset-prompt
}

# The first line holds a width-dependent filler; redraw it for the new width.
function TRAPWINCH() {
    prompt_starship_redraw
    return 0
}

function _prompt_starship_setup() {
    # Without starship's init (missing or empty init.zsh) PROMPT is not its
    # command and prompt_subst is unset, so the prompt below would render as
    # literal variable names. Keep zsh's default prompt instead.
    if (( ! $+functions[prompt_starship_precmd] )); then
        print -u2 "starship init not loaded; run: zinit update starship/starship"
        return
    fi
    # `starship init` set PROMPT to its `$(starship prompt ...)` command; keep
    # that as the renderer, adding --profile while starship_profile is set and
    # exporting starship_env first (both from config.zsh). They are expanded
    # inside the command substitution on each render, so the exports stay in
    # that subshell. The right prompt is unused, so drop its second fork.
    local profile_arg='${starship_profile:+--profile=$starship_profile}'
    local env_cmd='(( ${#starship_env} )) && export "${starship_env[@]}"; '
    _prompt_starship_cmd=${PROMPT/ prompt / prompt $profile_arg }
    _prompt_starship_cmd=${_prompt_starship_cmd/#\$\(/\$( $env_cmd}
    RPROMPT=
    add-zsh-hook precmd _prompt_render  # after starship's precmd sets its variables
    add-zle-hook-widget line-finish _prompt_transient
    zvm_after_select_vi_mode_commands+=(_prompt_update_char)
}
