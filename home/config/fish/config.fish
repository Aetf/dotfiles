# Path to your oh-my-fish.
set fish_path $HOME/.oh-my-fish

# Path to your custom folder (default path is ~/.oh-my-fish/custom)
#set fish_custom $HOME/dotfiles/oh-my-fish

# Load oh-my-fish configuration.
. $fish_path/oh-my-fish.fish

Theme "bobthefish"

Plugin "theme"
Plugin "tmux"

set PATH "/home/aetf/.local/bin" $PATH

function fish_user_key_bindings
    # Map Ctrl+C to discard current command line content
    bind \cc 'commandline ""'
end

set TERM xterm-256color
