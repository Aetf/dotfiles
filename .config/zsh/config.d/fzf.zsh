# default to use fd when invoked without any arguments or pipe
typeset -g FZF_DEFAULT_COMMAND="fd --type f --no-ignore-vcs --follow"
# Solarized colors
typeset -g FZF_DEFAULT_OPTS="--height
40%
--border
--color=bg+:#393939,bg:#2d2d2d,spinner:#66cccc,hl:#6699cc
--color=fg:#a09f93,header:#6699cc,info:#ffcc66,pointer:#66cccc
--color=marker:#66cccc,fg+:#e8e6df,prompt:#ffcc66,hl+:#6699cc"

# paste the selected entry onto command line
typeset -g FZF_CTRL_T_COMMAND="fd --type f --no-ignore-vcs --follow . . $HOME"

# cd into directory
typeset -g FZF_ALT_C_COMMAND="fd --type d --no-ignore-vcs --follow . . $HOME"
# use exa to show entries of the directory in the preview window
# the preview window can be scrolled by ctrl+UP and ctrl+DOWN
typeset -g FZF_ALT_C_OPTS="--preview 'exa --tree --level=2 --color=always {}'"
