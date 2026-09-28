# Prompt segments computed in the background (config.d/10-async-worker.zsh) and
# shown by starship as ${env_var.NAME} modules; redrawn in place when they
# change.
#
# prompt_segment <VAR> <context-fn> <job-fn>
#   Before each prompt, <context-fn> runs in the shell (keep it cheap: no
#   forks, no slow filesystems) and sets `reply=(<context> [args...])`; an
#   empty reply turns the segment off. Then `<job-fn> <context> [args...]`
#   runs in the worker, and its stdout becomes $VAR (exported; unset when the
#   output is empty or the job fails).
#   When the context changes, $VAR is unset right away and results computed
#   for another context are dropped, so the prompt never shows a value for a
#   place it has left. Within a context the value stays until the refresh
#   arrives.
#   Register segments during startup: job functions must exist when the
#   worker starts (see worker_restart).
# prompt_redraw_request
#   For worker callbacks that change other prompt inputs: the prompt is
#   redrawn once the worker has no more results ready.

typeset -gA _prompt_segment_context_fn _prompt_segment_context
typeset -gi _prompt_redraw_pending=0

function prompt_segment() {
    local var=$1
    _prompt_segment_context_fn[$var]=$2
    # One job name per segment, so segments do not wait for each other.
    functions[_prompt_segment_job_$var]="print -r -- \"\$1\"; $3 \"\$@\""
    worker_restart
}

function prompt_redraw_request() {
    _prompt_redraw_pending=1
}

function _prompt_segments_precmd() {
    local var ctx
    local -a reply
    for var in ${(k)_prompt_segment_context_fn}; do
        reply=()
        $_prompt_segment_context_fn[$var]
        ctx=${reply[1]-}
        if [[ $ctx != ${_prompt_segment_context[$var]-} ]]; then
            _prompt_segment_context[$var]=$ctx
            unset $var
        fi
        [[ -n $ctx ]] && worker_submit _prompt_segment_job_$var _prompt_segment_done "${reply[@]}"
    done
}

# Worker callback: $1 job, $2 exit status, $3 stdout (context line, value).
function _prompt_segment_done() {
    local var=${1#_prompt_segment_job_} ctx=${3%%$'\n'*} val=
    [[ $3 == *$'\n'* ]] && val=${3#*$'\n'}
    [[ -n $ctx && $ctx == ${_prompt_segment_context[$var]-} ]] || return 0
    (( $2 == 0 )) || val=
    local old=${(P)var-} had=${(P)+var}
    if [[ -n $val ]]; then
        export $var=$val
    else
        unset $var
    fi
    [[ $val != $old || ( -z $val && had -eq 1 ) ]] && _prompt_redraw_pending=1
    return 0
}

function _prompt_segments_idle() {
    (( _prompt_redraw_pending )) || return 0
    _prompt_redraw_pending=0
    prompt_starship_redraw
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_segments_precmd
worker_idle_functions+=(_prompt_segments_idle)
