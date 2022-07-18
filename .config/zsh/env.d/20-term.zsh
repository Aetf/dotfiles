# Fix TERM
if [[ $TERM == "konsole" ]]; then
    export TERM=konsole-256color
fi
if [[ $TERM == "tmux" ]]; then
    export TERM=tmux-256color
fi
