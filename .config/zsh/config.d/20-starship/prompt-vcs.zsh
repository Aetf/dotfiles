# VCS state of $PWD as an async prompt segment (async-prompt-segments.zsh),
# shown in ${env_var.STARSHIP_VCS} at the end of the prompt's left side, so the
# space it takes while a result is pending moves nothing else.
#
# The worker walks up from $PWD like git does (stopping below
# $GIT_CEILING_DIRECTORIES) and at the first directory with a marker hands
# over to a provider:
#   .jj -> "jj:<store type>" (colocated repos count as jj), .git -> "git",
#   .hg -> "hg".
# prompt_vcs_providers maps those kinds to functions that run in the worker as
# `<fn> <root> <pwd>` (current directory already $PWD) and print the segment,
# with its colors as ANSI escapes. A marker whose kind has no provider ends
# the walk with no segment. Configs add providers during startup, e.g.
#   prompt_vcs_providers[hg]=my_hg_status
# prompt_vcs_skip holds glob patterns for $PWD where no lookup is done.

typeset -gA prompt_vcs_providers=(
    git _prompt_vcs_git
    jj:git _prompt_vcs_jj_starship
)
typeset -ga prompt_vcs_skip

function _prompt_vcs_context() {
    local p
    for p in $prompt_vcs_skip; do
        [[ $PWD == ${~p} ]] && return 0
    done
    reply=($PWD "${GIT_CEILING_DIRECTORIES-}")
}

# Runs in the worker: $1 directory, $2 GIT_CEILING_DIRECTORIES.
function _prompt_vcs_job() {
    emulate -L zsh -o extended_glob
    local dir=$1 kind= k up
    local -a ceilings=(${(s.:.)2})
    local -A markers
    for k in ${(k)prompt_vcs_providers}; do
        markers[${k%%:*}]=1
    done
    while [[ -z $kind ]]; do
        if (( ${+markers[jj]} )) && [[ -d $dir/.jj ]]; then
            _prompt_vcs_jj_store_type $dir
            kind=jj:$REPLY
        elif (( ${+markers[git]} )) && [[ -e $dir/.git ]]; then
            kind=git
        elif (( ${+markers[hg]} )) && [[ -d $dir/.hg ]]; then
            kind=hg
        else
            up=${dir:h}
            [[ $up == $dir ]] && return 0
            (( ${ceilings[(Ie)$up]} )) && return 0
            dir=$up
        fi
    done
    local fn=${prompt_vcs_providers[$kind]-}
    [[ -n $fn ]] || return 0
    builtin cd -q -- $1 2>/dev/null || return 0
    $fn $dir $1
}

# Store type of the jj workspace at $1 (git, google.piper, ...).
function _prompt_vcs_jj_store_type() {
    local repo=$1/.jj/repo
    REPLY=unknown
    if [[ -f $repo ]]; then
        # A secondary workspace: the file holds the repo path, relative to .jj.
        repo=$(<$repo)
        [[ $repo == /* ]] || repo=$1/.jj/$repo
    fi
    [[ -r $repo/store/type ]] && REPLY=$(<$repo/store/type)
}

# Bounds a provider command, if coreutils' timeout is there.
function _prompt_vcs_run() {
    if (( $+commands[timeout] )); then
        command timeout 10 "$@"
    else
        command "$@"
    fi
}

# jj with a git-backed store: jj-starship, which reads it through jj-lib.
function _prompt_vcs_jj_starship() {
    _prompt_vcs_run jj-starship --no-jj-prefix
}

# git, formatted like p10k lean: branch (`:upstream` if named differently),
# `HEAD @hash` when detached, an operation in progress with its step, then
# ⇡ahead ⇣behind *stashes ~conflicted +staged !modified »renamed ✘deleted
# !typechanged ?untracked. The counts follow starship's git_status (which
# parses the same `git status --porcelain=2`). GIT_OPTIONAL_LOCKS=0 keeps a
# background status from taking the index lock that the user's git needs.
function _prompt_vcs_git() {
    emulate -L zsh -o extended_glob
    local root=$1 out
    out=$(GIT_OPTIONAL_LOCKS=0 _prompt_vcs_run git -C $root \
        status --porcelain=2 --branch --show-stash 2>/dev/null) || return 0
    local head= oid= upstream= line xy
    local -i ahead=0 behind=0 has_ab=0 stash=0 conflicted=0 staged=0 modified=0
    local -i renamed=0 deleted=0 typechanged=0 untracked=0
    for line in ${(f)out}; do
        case $line in
            ('# branch.oid '*) oid=${line#\# branch.oid } ;;
            ('# branch.head '*) head=${line#\# branch.head } ;;
            ('# branch.upstream '*) upstream=${line#\# branch.upstream } ;;
            ('# branch.ab '*)
                has_ab=1
                [[ $line == (#b)'# branch.ab +'(<->)' -'(<->) ]] && ahead=$match[1] behind=$match[2]
                ;;
            ('# stash '*) stash=${line#\# stash } ;;
            ([12]' '*)
                [[ $line == 2* ]] && (( renamed++ ))
                xy=${line[3,4]}
                [[ $xy[1] == D ]] && (( deleted++ ))
                [[ $xy[2] == D ]] && (( deleted++ ))
                [[ $xy[2] == [MA] ]] && (( modified++ ))
                [[ $xy[1] == [MAT] ]] && (( staged++ ))
                [[ $xy[2] == T ]] && (( typechanged++ ))
                ;;
            ('u '*) (( conflicted++ )) ;;
            ('? '*) (( untracked++ )) ;;
        esac
    done

    local -a segs
    function _seg() { segs+=($'\e[38;5;'$1'm'$2$'\e[0m') }
    if [[ $head == '(detached)' ]]; then
        _seg 76 HEAD
        [[ $oid == [[:xdigit:]]## ]] && _seg 76 "@${oid[1,8]}"
    else
        local remote=${upstream#*/}
        [[ -n $upstream && $remote != $head ]] && _seg 76 "$head:$remote" || _seg 76 $head
    fi
    _prompt_vcs_git_state $root && _seg 196 $REPLY
    if (( has_ab )); then
        if (( ahead && behind )); then
            _seg 76 "⇣$behind ⇡$ahead"
        elif (( ahead )); then
            _seg 76 "⇡$ahead"
        elif (( behind )); then
            _seg 76 "⇣$behind"
        fi
    fi
    (( stash )) && _seg 76 "*$stash"
    (( conflicted )) && _seg 196 "~$conflicted"
    (( staged )) && _seg 178 "+$staged"
    (( modified )) && _seg 178 "!$modified"
    (( renamed )) && _seg 178 "»$renamed"
    (( deleted )) && _seg 178 "✘$deleted"
    (( typechanged )) && _seg 178 "!$typechanged"
    (( untracked )) && _seg 39 "?$untracked"
    unfunction _seg
    print -r -- ${(j: :)segs}
}

# The operation in progress in the repo at $1, like starship's git_state:
# REBASING 2/5, AM, AM/REBASE, CHERRY-PICKING, MERGING, BISECTING, REVERTING.
function _prompt_vcs_git_state() {
    local gd=$1/.git cur= total=
    if [[ -f $gd ]]; then
        # A linked worktree or submodule: .git holds "gitdir: <path>".
        gd=$(<$gd)
        gd=${gd#gitdir: }
        [[ $gd == /* ]] || gd=$1/$gd
    fi
    if [[ -d $gd/rebase-apply ]]; then
        if [[ -e $gd/rebase-apply/rebasing ]]; then
            REPLY=REBASING
        elif [[ -e $gd/rebase-apply/applying ]]; then
            REPLY=AM
        else
            REPLY=AM/REBASE
        fi
        [[ -r $gd/rebase-apply/next ]] && cur=$(<$gd/rebase-apply/next)
        [[ -r $gd/rebase-apply/last ]] && total=$(<$gd/rebase-apply/last)
    elif [[ -d $gd/rebase-merge ]]; then
        REPLY=REBASING
        [[ -r $gd/rebase-merge/msgnum ]] && cur=$(<$gd/rebase-merge/msgnum)
        [[ -r $gd/rebase-merge/end ]] && total=$(<$gd/rebase-merge/end)
    elif [[ -e $gd/CHERRY_PICK_HEAD ]]; then
        REPLY=CHERRY-PICKING
    elif [[ -e $gd/MERGE_HEAD ]]; then
        REPLY=MERGING
    elif [[ -e $gd/BISECT_LOG ]]; then
        REPLY=BISECTING
    elif [[ -e $gd/REVERT_HEAD ]]; then
        REPLY=REVERTING
    else
        return 1
    fi
    [[ $cur == <-> && $total == <-> ]] && REPLY+=" $cur/$total"
    return 0
}

prompt_segment STARSHIP_VCS _prompt_vcs_context _prompt_vcs_job
