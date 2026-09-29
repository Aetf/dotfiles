# Hook profiler for prompt-profile (next to this file); source it in an
# interactive zsh.
#
# Wraps every function in chpwd_functions and precmd_functions at the time it
# is sourced (hooks added later are not timed), and prompt_starship_redraw if
# defined. Each event appends one line to $PROMPT_PROFILE_LOG:
#   <label> <phase> total=<ms> <hook>=<ms> ...
# label: $PROMPT_PROFILE_LABEL when the event happened; nothing is logged
#   while it is empty.
# phase: cd (all chpwd hooks of one cd), p1 (first prompt after the cd), p2,
#   p3, ...; redraw (one prompt_starship_redraw call, total only).

zmodload zsh/datetime
typeset -g PROMPT_PROFILE_LOG=${PROMPT_PROFILE_LOG:-/dev/null}
typeset -g PROMPT_PROFILE_LABEL=${PROMPT_PROFILE_LABEL-}
typeset -ga _pp_times
typeset -gi _pp_prompt=0

function _pp_wrap() {
    local f=$1
    (( ${+functions[_pp_orig_$f]} )) && return
    functions[_pp_orig_$f]=$functions[$f]
    functions[$f]="
        local -F _pp_t=\$EPOCHREALTIME
        _pp_orig_$f \"\$@\"
        local _pp_ret=\$?
        _pp_times+=(\"$f=\$(( (EPOCHREALTIME - _pp_t) * 1000 ))\")
        return \$_pp_ret"
}

function _pp_emit() {  # <phase>
    local -F total=0
    local kv line
    [[ -n $PROMPT_PROFILE_LABEL ]] || { _pp_times=(); return }
    for kv in $_pp_times; do (( total += ${kv#*=} )); done
    printf -v line '%s %s total=%.1f' $PROMPT_PROFILE_LABEL $1 $total
    for kv in $_pp_times; do line+=$(printf ' %s=%.1f' ${kv%%=*} ${kv#*=}); done
    print -r -- $line >> $PROMPT_PROFILE_LOG
    _pp_times=()
}

function _pp_chpwd_first() { _pp_times=() }
function _pp_chpwd_last() { _pp_emit cd; _pp_prompt=0 }
function _pp_precmd_first() { _pp_times=() }
function _pp_precmd_last() { _pp_emit p$(( ++_pp_prompt )) }

() {
    local f
    for f in $chpwd_functions $precmd_functions; do
        [[ $f == _pp_* ]] || (( ! $+functions[$f] )) || _pp_wrap $f
    done
}
chpwd_functions=(_pp_chpwd_first ${chpwd_functions:#_pp_*} _pp_chpwd_last)
precmd_functions=(_pp_precmd_first ${precmd_functions:#_pp_*} _pp_precmd_last)

if (( $+functions[prompt_starship_redraw] && ! $+functions[_pp_orig_redraw] )); then
    functions[_pp_orig_redraw]=$functions[prompt_starship_redraw]
    function prompt_starship_redraw() {
        local -F t=$EPOCHREALTIME
        _pp_orig_redraw "$@"
        [[ -n $PROMPT_PROFILE_LABEL ]] || return 0
        printf '%s redraw total=%.1f\n' $PROMPT_PROFILE_LABEL \
            $(( (EPOCHREALTIME - t) * 1000 )) >> $PROMPT_PROFILE_LOG
    }
fi
