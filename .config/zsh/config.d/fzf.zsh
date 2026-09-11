# default to use fd when invoked without any arguments or pipe
typeset -g FZF_DEFAULT_COMMAND="fd --type f --no-ignore-vcs --follow"
# Solarized colors
typeset -g FZF_DEFAULT_OPTS="--height
40%
--border
--color=bg+:#393939,bg:#2d2d2d,spinner:#66cccc,hl:#6699cc
--color=fg:#a09f93,header:#6699cc,info:#ffcc66,pointer:#66cccc
--color=marker:#66cccc,fg+:#e8e6df,prompt:#ffcc66,hl+:#6699cc"

# CTRL-T (paste a path) and ALT-C (cd) walk the current directory first and the
# rest of $HOME afterwards.  Two fd passes rather than `fd . . $HOME`: cwd hits
# stay relative, which keeps them shorter than the absolute $HOME ones and so
# ahead of them in fzf's ranking, and the $HOME pass prunes the cwd subtree, so
# nothing is offered twice under two names.  fzf hands this string to `sh -c`,
# hence POSIX syntax and $PWD expanded at key press rather than at startup.
_fzf_walk='
fd --type @TYPE@ --no-ignore-vcs --follow
cwd=${PWD%/}
case $HOME/ in "$cwd"/*) exit 0 ;; esac  # cwd walk already covered $HOME
case $PWD/ in
    "$HOME"/*) exec fd --type @TYPE@ --no-ignore-vcs --follow \
                      --exclude "/${PWD#$HOME/}" . "$HOME" ;;
esac
exec fd --type @TYPE@ --no-ignore-vcs --follow . "$HOME"
'

# paste the selected entry onto command line
typeset -g FZF_CTRL_T_COMMAND=${_fzf_walk//@TYPE@/f}

# cd into directory
typeset -g FZF_ALT_C_COMMAND=${_fzf_walk//@TYPE@/d}

unset _fzf_walk

# use exa to show entries of the directory in the preview window
# the preview window can be scrolled by ctrl+UP and ctrl+DOWN
typeset -g FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always {}'"
