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

# bindkey '\C-C' kill-whole-line
