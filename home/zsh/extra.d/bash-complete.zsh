# enable bash completion script compatibility mode
autoload -U +X bashcompinit
bashcompinit
for comp in $HOME/.bash_completion.d/*; do
    source $comp
done
