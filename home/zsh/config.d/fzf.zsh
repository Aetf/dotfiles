# default to use fd
typeset -g FZF_DEFAULT_COMMAND="fd --type=file --no-ignore-vcs --follow . $HOME"
## paste the selected entry onto command line
typeset -g FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
## cd into directory
typeset -g FZF_ALT_C_COMMAND="fd --type d --no-ignore-vcs --follow . $HOME"
## Solarized colors
typeset -g FZF_DEFAULT_OPTS="--height
40%
--border
--color=bg+:#393939,bg:#2d2d2d,spinner:#66cccc,hl:#6699cc
--color=fg:#a09f93,header:#6699cc,info:#ffcc66,pointer:#66cccc
--color=marker:#66cccc,fg+:#e8e6df,prompt:#ffcc66,hl+:#6699cc"

## overwrite ctrl-T to copy filepath to commandline to alt-f
bindkey -r "^T"
bindkey "\ef" fzf-file-widget
