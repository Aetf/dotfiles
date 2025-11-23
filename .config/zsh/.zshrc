# Source ordering: .zshenv → [.zprofile if login] → [.zshrc if interactive] → [.zlogin if login] → [.zlogout sometimes]

if [[ "$ZPROF" = true ]]; then
    zmodload zsh/zprof
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# initial hash definition for zinit
declare -A ZINIT
ZINIT[HOME_DIR]="$XDG_DATA_HOME/zsh/zinit"
ZINIT[BIN_DIR]="$ZINIT[HOME_DIR]/bin"
ZINIT[ZCOMPDUMP_PATH]="$XDG_CACHE_HOME/zsh/zcompdump"
mkdir -p "$XDG_CACHE_HOME/zsh"
### Added by Zinit's installer
if [[ ! -f "${ZINIT[BIN_DIR]}/zinit.zsh" ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma-continuum/zinit)…%f"
    command mkdir -p "${ZINIT[HOME_DIR]}" && command chmod g-rwX "${ZINIT[HOME_DIR]}"
    command git clone https://github.com/zdharma-continuum/zinit "${ZINIT[BIN_DIR]}" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "${ZINIT[BIN_DIR]}/zinit.zsh"
# autoload -Uz _zinit
# (( ${+_comps} )) && _comps[zinit]=_zinit
# A binary Zsh module which transparently and automatically compiles sourced scripts
module_path+=( "${ZINIT[MODULE_DIR]}/Src" )
# first try silently load the module
if ! zmodload -s zdharma_continuum/zinit; then
    # load our patched .zinit-build-module
    source "$ZDOTDIR/scripts/build-zinit-module"
    zinit module build
fi
zmodload zdharma_continuum/zinit &>/dev/null
### End of Zinit installer's chunk


() {{
    # Functions to make configuration less verbose
    # zt() : First argument is a wait time and suffix, ie "0a".
    # See https://zdharma-continuum.github.io/zinit/wiki/Example-wait-conditions/
    # Anything that doesn't match will be passed as if it were an ice mod.
    # Default ices:
    # * depth'1' (--depth when git clone)
    # * lucid (no "Loading..." message)
    zt(){
        zinit depth'1' lucid ${1/#[0-9][a-c]/wait"${1}"} "${@:2}";
    }

    ##################
    #    Annexes     #
    # Config source  #
    #     Prompt     #
    ##################
    local early=(
        # async library
        @mafredri/zsh-async
        # Load any plugin specific settings, these are all variable settings, so we load them first
        pick'index.zsh'
            $ZDOTDIR/config.d
        # for the fbin/sbin ice
        @zdharma-continuum/zinit-annex-bin-gem-node
        # And then the powerlevel10k prompt, with fast gitstatus, config is in $ZDOTDIR/config.d/purepower.zsh
        @romkatv/powerlevel10k
        # vi-mode
        @jeffreytse/zsh-vi-mode
    )

    ######################
    # Trigger-load block #
    ######################
    local triggers=(
        # use svn mode to download multiple files selectively
        trigger-load'!x' svn
            OMZ::plugins/extract
    )

    ##################
    # Wait'0a' block #
    ##################
    # this block is mostly used to download and install binary tools
    # for this, a separate table is sourced to determine the correct
    # variant to pick
    declare -A toolinfo
    source "$ZDOTDIR/toolinfo.zsh"

    local wait0a=(
        as'completion' blockf
            $ZDOTDIR/completions.d

        # yadm to manage dotfiles (this is the binary used after bootstrap)
        sbin'yadm'
        sbin'yadm -> y'
        # fbin'yadm -> y'
            @TheLocehiliosan/yadm

        # fzf the fuzzy finder integration with zsh
        blockf
        trackbinds
        multisrc'shell/{completion,key-bindings}.zsh'
        sbin'bin/*'
        bindmap'^T -> \\ef'
            @junegunn/fzf
    )
    # conditionally add tool binaries
    if [ ! -z "${toolinfo[fzf]}" ]; then
        wait0a+=(
            id-as'fzf-bin'
            from'gh-r' bpick"${toolinfo[fzf]}"
            as'null' sbin'fzf'
                @junegunn/fzf
        )
    fi
    if [ ! -z "${toolinfo[eza]}" ]; then
        wait0a+=(
            # eza the better ls
            from'gh-r' bpick"${toolinfo[eza]}"
            fbin'eza -> ls'
            sbin'eza'
                @eza-community/eza
        )
    fi

    if [ ! -z "${toolinfo[delta]}" ]; then
        wait0a+=(
            # delta the better diff
            from'gh-r' bpick"${toolinfo[delta]}"
            sbin'*/delta'
                @dandavison/delta
        )
    fi
    if [ ! -z "${toolinfo[fd]}" ]; then
        wait0a+=(
            # fd the better find
            from'gh-r' bpick"${toolinfo[fd]}"
            mv'*/_fd -> _fd'
            sbin'*/fd'
                @sharkdp/fd
        )
    fi

    if [ ! -z "${toolinfo[ripgrep]}" ]; then
        wait0a+=(
            # ripgrep the better grep
            from'gh-r' bpick"${toolinfo[ripgrep]}"
            sbin'*/rg'
                @BurntSushi/ripgrep
        )
    fi

    if [ ! -z "${toolinfo[bat]}" ]; then
        wait0a+=(
            # bat the better cat
            from'gh-r' bpick"${toolinfo[bat]}"
            sbin'*/bat'
                @sharkdp/bat
        )
    fi

    if [ ! -z "${toolinfo[mise]}" ]; then
        wait0a+=(
            # volta to manage nodejs
            from'gh-r' bpick"${toolinfo[mise]}"
            sbin'bin/mise'
                @jdx/mise
        )
    fi

    if [ ! -z "${toolinfo[git-crypt]}" ]; then
        wait0a+=(
            # git-crypt for encryption yadm repo
            from'gh-r' bpick"${toolinfo[git-crypt]}"
            sbin'git-crypt* -> git-crypt'
                @AGWA/git-crypt
        )
    fi

    if [ ! -z "${toolinfo[just]}" ]; then
        wait0a+=(
            # just for better make
            from'gh-r' bpick"${toolinfo[just]}"
            sbin'just'
                @casey/just
        )
    fi

    if [ ! -z "${toolinfo[uv]}" ]; then
        wait0a+=(
            # uv for python
            from'gh-r' bpick"${toolinfo[uv]}"
            sbin'uv'
                @astral-sh/uv
        )
    fi
    ##################
    # Wait'0b' block #
    ##################
    local wait0b=(
        pick'index.zsh'
        blockf
        # some extra program may call compinit prematurelly (e.g. micromamba)
        # we eargly load compinit but don't call it yet such that they don't do it.
        autoload'compinit'
            $ZDOTDIR/extra.d
    )

    ##################
    # Wait'0c' block #
    ##################
    local wait0c=(
        ver'master'
        #atload'!_zsh_autosuggest_start'
            @zsh-users/zsh-autosuggestions

        # change zsh completion to use fzf.
        # This must be load after compinit but before other plugins which wrap widgets
        # zicompinit is simply "autoload -Uz compinit; compinit ${ZINIT[COMPINIT_OPTS]}"
        atinit"zicompinit"
        # can't use atpull because that is run before soucing the file
        # atload'[[ -f modules/Src/aloxaf/fzftab.so ]] || build-fzf-tab-module'
        # TODO: workaround zdharma-continuum/zinit#315, that any cd in atload will trigger infinite recursion
        atload'[[ -n modules/Src/aloxaf/fzftab.(so|bundle)(#qN) ]] || (func=$(where build-fzf-tab-module); zsh -c "FZF_TAB_HOME=$FZF_TAB_HOME; $func; (hash nproc &>/dev/null || alias nproc=sysctl -n hw.physicalcpu) build-fzf-tab-module")'
        # don't mess with our fpath
        blockf
            @Aloxaf/fzf-tab

        # zicdreplay will replay all previously captured compdef
        atinit"zicdreplay"
            @zdharma-continuum/fast-syntax-highlighting
    )

    ##################
    # Actual loading #
    ##################
    # light mode disables tracking of what plugin does and disables plugin
    # unloading, but is faster.
    zt light-mode for "${early[@]}"
    zt light-mode for "${triggers[@]}"
    zt 0a light-mode for "${wait0a[@]}"
    zt 0b light-mode for "${wait0b[@]}"
    zt 0c light-mode for "${wait0c[@]}"
} always {
    unfunction zt
}}

if [[ "$ZPROF" = true ]]; then
    zprof
fi
