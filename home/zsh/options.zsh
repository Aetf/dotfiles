# ZSH options
CASE_SENSITIVE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="mm/dd/yyyy"

# HISTORY
HISTSIZE=10000
SAVEHIST=9000
HISTFILE=~/.zsh_history
HISTCONTROL=ignoredups:erasedups
HISTIGNORE="exit"

setopt inc_append_history # Update history in all windows on command execution

# multibytes
setopt COMBINING_CHARS

# Auto completion
#autoload -Uz compinit
#compinit -d
#zstyle ':completion:*' menu select
#setopt COMPLETE_ALIASES
