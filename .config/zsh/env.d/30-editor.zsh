# Check and prefer nvim
if hash nvim &>/dev/null; then
    export EDITOR=nvim
else
    export EDITOR=vim
fi
