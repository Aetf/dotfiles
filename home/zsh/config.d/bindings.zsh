# Key bindings
bindkey -me 2>/dev/null # disable multibyte warning

# by default: export WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'
# we take out the slash, period, angle brackets, dash here.
export WORDCHARS='*?_[]~=&;!#$%^(){}'

# [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5C' forward-word
# [Ctrl-LeftArrow] - move backward one word
bindkey '^[[1;5D' backward-word

# [Alt-RightArrow] - move forward one word
bindkey '^[[1;3C' forward-word
# [Alt-LeftArrow] - move backward one word
bindkey '^[[1;3D' backward-word

# [Alt-Delete] - forward-delete-word
bindkey '^[[3;3~' kill-word
# [Ctrl-Delete] - forward-delete-word
bindkey '^[[3;5~' kill-word

# The following is to fix single keys
[[ -f $HOME/.zsh/keys/$TERM ]] && source $HOME/.zsh/keys/$TERM
[[ -n ${key[Backspace]} ]] && bindkey "${key[Backspace]}" backward-delete-char
[[ -n ${key[Insert]} ]] && bindkey "${key[Insert]}" overwrite-mode
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[PageUp]} ]] && bindkey "${key[PageUp]}" up-line-or-history
[[ -n ${key[Delete]} ]] && bindkey "^[[3~" delete-char
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
[[ -n ${key[PageDown]} ]] && bindkey "${key[PageDown]}" down-line-or-history
# [[ -n ${key[Up]} ]] && bindkey "${key[Up]}" up-line-or-search
# [[ -n ${key[Left]} ]] && bindkey "${key[Left]}" backward-char
# [[ -n ${key[Down]} ]] && bindkey "${key[Down]}" down-line-or-search
# [[ -n ${key[Right]} ]] && bindkey "${key[Right]}" forward-char

