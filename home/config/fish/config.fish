#
# ~/.config/fish/config.fish
#

# If not running interactively, don't do anything
if not status -i; exit; end

# If ssh-agent haven't been started, we are in kmscon or linux console
# start ssh-agent with tmux
if test "$SSH_AUTH_SOCK"x = "x";
    if test "$TERM" = "linux";
        # Don't start tmux on linux console
        exec ssh-agent fish
    else
        exec ssh-agent tmux new -As console
    end
end

# Some environment variables
## Only set these if we don't have DISPLAY
## otherwise, these've been set in $HOME/.xprofile
if test "$DISPLAY"x = "x";
    ## Install directory
    set -x INSTALLDIR "$HOME/software"
    ## Default editor
    set -x EDITOR vim
    set -x VISUAL $EDITOR
    ## Used for virtualbox
    set -x VBOX_USB usbfs
    ## Nasm environment
    set -x NASMENV "-i /home/aetf/Develop/ASM/inc"
    set -x NASM $NASMENV
    ## Predefined variables to Java runtime
    set -x _JAVA_OPTIONS "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"
    ## Ccache directory
    set -x CCACHE_DIR /opt/.ccache
    set -x CCACHE_COMPRESS
    ## XDG variables
    set -x XDG_CONFIG_HOME "$HOME/.config"

    # Prepend user's bin directory to PATH
    if test -d "$HOME/customizations/scripts"
        set PATH "$HOME/customizations/scripts" $PATH
    end
    ## Local bin directory
    if test -d "$HOME/.local/bin"
        set PATH "$HOME/.local/bin" $PATH
    end
    ## ruby gem executable
    for p in ~/.gem/ruby/*/bin
        set PATH $PATH $p
    end
    ## Node.js executable
    if test -d "$HOME/.node_modules/bin"
        set PATH $PATH "$HOME/.node_modules/bin"
    end
    ## rust cargo executable
    if test -d "$HOME/.cargo/bin"
        set PATH $PATH "$HOME/.cargo/bin"
    end
    ## Spack executable
    if test -d "$HOME/.local/spack/bin"
        set PATH "$HOME/.local/spack/bin" $PATH
    end
end

# Some useful alias (functions in .config/fish/functions)
# ll='ls -lh'
# la='ls -ah'
# lla='ls -lah'
# rm='rm -I --preserve-root'
# update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'
# cdmk
# cmatrix='cmatrix -bls'
# work='cd /tmp/workspace'
# grepc='grep --color=always'

## More colorful
switch $TERM
    case 'xterm-256color' 'konsole'
        set TERM konsole
        # explicitly enable 256color and 24bit color in fish
        set fish_term256 1
        set fish_term24bit 1
    case '*256col*'
        # should not need this, as fish will enable 256 color if the term contains "256color"
        #set fish_term256 1
        set fish_term24bit 1
    case 'tmux'
        set fish_term256 1
        set fish_term24bit 1
end

# Prompt line hook provided by powerline
function _setup_powerline
    powerline-daemon -q
    set fish_function_path $fish_function_path "/usr/lib/python3.6/site-packages/powerline/bindings/fish"
    powerline-setup
end
switch $TERM
    case 'xterm*' 'konsole' 'tmux'
        _setup_powerline
    case 'linux'
        set -x POWERLINE_CONFIG_OVERRIDES 'common.term_truecolor=false'
        _setup_powerline
    case '*'
        function fish_prompt
            fallback_prompt
        end
end
functions --erase _setup_powerline

# Silence 'Picked up _JAVA_OPTIONS' message on command line (combined with java.fish)
set _SILENT_JAVA_OPTIONS "$_JAVA_OPTIONS"
set -e _JAVA_OPTIONS

# Default command for fzf
set -x FZF_DEFAULT_COMMAND 'plocate "^"(pwd)'
## paste the selected entry onto command line
set -x FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
## cd into directory
set -x FZF_ALT_C_COMMAND 'plocate -t dir "^"(pwd)'

# Custom key bindings
function fish_user_key_bindings
    # Map Ctrl+C to discard current command line content
    bind \cc 'commandline ""'
    # Enable fzf keybindings
    fzf_key_bindings
end


# Programmable shell title
function fish_title
    if test "$_" = "ssh"
        echo "$_: "(string split " " $argv[1])[-1]
    else
        echo "$_: "(prompt_pwd)
    end
end

