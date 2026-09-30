# Shared background worker for slow shell work, on zsh-async (.zshrc loads it
# before config.d). Numbered to load before the configs that use it.
#
# worker_submit <job> <callback> [args...]
#   Runs `<job> args...` in the worker and, when it finishes, calls
#   `<callback> <job> <exit status> <stdout> <stderr>` in the shell. A job name
#   runs once at a time: submitting it while it runs queues one rerun with the
#   latest args, so the last request is always answered.
#   A result can be lost without the worker reporting an error, which would
#   block the job name for good. Submitting a job that has been running for
#   more than $worker_job_timeout seconds restarts the worker instead.
# worker_idle_functions
#   Called after all results the worker had ready have been handled, e.g. to
#   redraw the prompt once for several results.
# worker_restart
#   The worker is a fork of the shell, so a job function must exist when it
#   starts. It starts at the first prompt, after all startup files; submissions
#   made during startup wait for it. Call this after defining job functions
#   later; running jobs are rerun in the new worker.

zmodload -i zsh/datetime

typeset -ga worker_idle_functions
typeset -gi worker_job_timeout=60
# _worker_running maps a job to the time it was sent.
typeset -gA _worker_callback _worker_args _worker_running _worker_pending
typeset -gi _worker_started=0 _worker_ready=0

function worker_submit() {
    local job=$1
    _worker_callback[$job]=$2
    shift 2
    if (( ! _worker_ready || ${+_worker_running[$job]} )); then
        _worker_pending[$job]=${(j: :)${(q)@}}
        if (( ${+_worker_running[$job]} &&
              EPOCHSECONDS - _worker_running[$job] > worker_job_timeout )); then
            worker_restart
        fi
        return 0
    fi
    _worker_send $job "$@"
}

function _worker_send() {
    local job=$1
    if (( ! _worker_started )); then
        async_start_worker shell_worker -n || return
        async_register_callback shell_worker _worker_done
        _worker_started=1
    fi
    shift
    _worker_args[$job]=${(j: :)${(q)@}}
    _worker_running[$job]=$EPOCHSECONDS
    async_job shell_worker $job "$@"
}

function _worker_flush() {
    local job args
    for job args in "${(@kv)_worker_pending}"; do
        (( ${+_worker_running[$job]} )) && continue
        unset "_worker_pending[$job]"
        _worker_send $job "${(@Q)${(z)args}}"
    done
}

function worker_restart() {
    (( _worker_started )) || return 0
    async_stop_worker shell_worker
    _worker_started=0
    local job
    for job in ${(k)_worker_running}; do
        (( ${+_worker_pending[$job]} )) || _worker_pending[$job]=$_worker_args[$job]
    done
    _worker_running=()
    (( _worker_ready )) && _worker_flush
}

# zsh-async callback: $1 job, $2 exit status, $3 stdout, $4 duration,
# $5 stderr, $6 whether more results are buffered.
function _worker_done() {
    if [[ $1 == '[async]' ]]; then
        # The worker died or its output was corrupt.
        worker_restart
    else
        unset "_worker_running[$1]"
        ${_worker_callback[$1]:-:} $1 $2 "$3" "$5"
        (( ${+_worker_pending[$1]} )) && _worker_flush
    fi
    if (( ! ${6:-0} )); then
        local f
        for f in $worker_idle_functions; do
            $f
        done
    fi
}

function _worker_first_precmd() {
    add-zsh-hook -d precmd _worker_first_precmd
    _worker_ready=1
    _worker_flush
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _worker_first_precmd
