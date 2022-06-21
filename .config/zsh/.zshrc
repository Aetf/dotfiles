if [[ "$ZPROF" = true ]]; then
    zmodload zsh/zprof
fi

# initial hash definition for zinit
declare -A ZINIT
ZINIT[HOME_DIR]="$XDG_DATA_HOME/zsh/zinit"
ZINIT[BIN_DIR]="$ZINIT[HOME_DIR]/bin"
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
if [[ ! -f "${ZINIT[MODULE_DIR]}/Src/zdharma_continuum/zinit.so" ]]; then
    zinit module build
fi
module_path+=( "${ZINIT[MODULE_DIR]}/Src" )
zmodload zdharma_continuum/zinit &>/dev/null
### End of Zinit installer's chunk

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
        # Load any plugin specific settings, these are all variable settings, so we load them first
        pick'index.zsh'
            $ZDOTDIR/config.d
        # for the sbin ice
        @zdharma-continuum/z-a-bin-gem-node
        # And then the powerlevel10k prompt, with fast gitstatus, config is in $ZDOTDIR/config.d/purepower.zsh
        @romkatv/powerlevel10k
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

        ver'master'
        atload'!_zsh_autosuggest_start'
            @zsh-users/zsh-autosuggestions

        # fzf the fuzzy finder
        multisrc'shell/{completion,key-bindings}.zsh' blockf trackbinds bindmap'^T -> \\ef'
            @junegunn/fzf

        id-as'fzf-bin'
        from'gh-r' bpick"${toolinfo[fzf]}"
        as'null' sbin'fzf'
            @junegunn/fzf

        # exa the better ls
        from'gh-r' bpick"${toolinfo[exa]}"
        mv'completions/exa.zsh -> completions/_exa.zsh'
        fbin'bin/exa -> ls'
        sbin'bin/exa'
            @ogham/exa

        # delta the better diff
        from'gh-r' bpick"${toolinfo[delta]}"
        sbin'*/delta'
            @dandavison/delta

        # fd the better find
        from'gh-r' bpick"${toolinfo[fd]}"
        sbin'*/fd'
            @sharkdp/fd

        # ripgrep the better grep
        from'gh-r' bpick"${toolinfo[ripgrep]}"
        sbin'*/rg'
            @BurntSushi/ripgrep

        # bat the better cat
        from'gh-r' bpick"${toolinfo[bat]}"
        sbin'*/bat'
            @sharkdp/bat

        # volta to manage nodejs
        from'gh-r' bpick"${toolinfo[volta]}"
        sbin'volta*'
            @volta-cli/volta

        # yadm to manage dotfiles (this is the binary used after bootstrap)
        fbin'yadm -> y'
        sbin'yadm'
            @TheLocehiliosan/yadm
    )

    ##################
    # Wait'0b' block #
    ##################
    local wait0b=(
        pick'index.zsh'
            $ZDOTDIR/extra.d
    )

    ##################
    # Wait'0c' block #
    ##################
    local wait0c=(
        # change zsh completion to use fzf.
        # This must be load after compinit but before other plugins which wrap widgets
        # zicompinit is simply "autoload -F compinit; compinit ${ZINIT[COMPINIT_OPTS]}"
        # -C will skip security permission checks when dump file is present, speeding things up
        atinit"mkdir -p $XDG_CACHE_HOME/zsh; ZINIT[COMPINIT_OPTS]='-C -d $XDG_CACHE_HOME/zsh/zcompdump'; zicompinit"
        # can't use atpull because that is run before soucing the file
        # atload'[[ -f modules/Src/aloxaf/fzftab.so ]] || build-fzf-tab-module'
        # TODO: workaround zdharma-continuum/zinit#315, that any cd in atload will trigger infinite recursion
        atload'[[ -f modules/Src/aloxaf/fzftab.so ]] || (func=$(where build-fzf-tab-module); zsh -c "FZF_TAB_HOME=$FZF_TAB_HOME; $func; build-fzf-tab-module")'
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
