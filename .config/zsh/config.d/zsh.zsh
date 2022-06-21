# Basic config for zsh itself

# multibytes
setopt COMBINING_CHARS

# History
HISTFILE=$XDG_DATA_HOME/zsh/histfile
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
#setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.

# What is a word?
# http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#index-select_002dword_002dstyle
autoload -U select-word-style
# We do not use WORDCHARS, so unset it to avoid confusion
unset WORDCHARS
# For navigating words (default), use shell style:
# words are complete shell command arguments, possibly including complete quoted strings, or any tokens special to the shell.
select-word-style shell
# For killing words, use normal style
zstyle ':zle:*' word-chars ':-._~?&%+#'
zstyle ':zle:backward-kill-word' word-style normal
zstyle ':zle:kill-word' word-style normal

# A fancier eol mark
export PROMPT_EOL_MARK=$'\u23ce'  # ⏎

# Fuzzy tab completion
# 0 -- vanilla completion (abc => abc)
# 1 -- smart case completion (abc => Abc)
# 2 -- word flex completion (abc => A-big-Car)
# 3 -- full flex completion (abc => ABraCadabra)
zstyle ':completion:*' matcher-list '' \
    'm:{a-z\-}={A-Z\_}' \
    'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
    'r:|?=** m:{a-z\-}={A-Z\_}'
