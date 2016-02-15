#
# ~/.config/fish/config.fish
#

# If not running interactively, don't do anything
if not status -i; exit; end

# Some environment variables
## More colorful
if test $TERM != "screen-256color" -a $TERM != "linux";
    set TERM "xterm-256color"
end

## Only set these if we don't have DISPLAY
## otherwise, these've been set in $HOME/.xprofile
if test "$DISPLAYx" = "x";
    ## Install directory
    set -x INSTALLDIR ~/Software
    ## Default editor
    set -x EDITOR vim
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
    set PATH ~/bin $PATH
    ## more in INSTALLDIR
    for dir in (find $INSTALLDIR -maxdepth 1 -mindepth 1 -type d -not -name src -print);
        begin
            set PATH $PATH "$dir";
            if [ -d "$dir/bin" ];
                set PATH $PATH "$dir/bin";
            end
        end
    end
    ## ruby gem executable
    set PATH $PATH ~/.gem/ruby/2.2.0/bin
end

# Make time output more informations
set -x TIME
set TIME "\
Time\n\
\tTotal:\t\t%es\n\
\tIn user:\t%Us\n\
\tIn kernel:\t%Ss\n\
\tCPU perentage:\t%P\n\
Memory\n\
\tUsage:\t\t%Xk+%Dk / %Kk (Shared+Unshared / Total)\n\
\tPage faults:\t%F/%R (Major/Minor)\n\
\tSwapped out:\t%W times\n\
I/O\n\
\tInputs:\t\t%I\n\
\tOutputs:\t%O"

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

# Prompt line hook provided by powerline
switch $TERM
    case 'xterm' 'xterm-256color'
        powerline-setup
    case 'linux'
        set -x POWERLINE_CONFIG_OVERRIDES 'common.term_truecolor=false'
        powerline-setup
    case 'screen-256color'
        set -x POWERLINE_CONFIG_OVERRIDES 'common.term_truecolor=false'
        powerline-setup
    case '*'
        function fish_prompt
            fallback_prompt
        end
end

# Fix KeeAgent enviroment variable
#set _ssh_socket_dir '/tmp/ssh-agent-lib-sock'
#set _ssh_socket (find "$_ssh_socket_dir" -maxdepth 1 -mindepth 1 -type s -print)
#if test -S "$_ssh_socket";
#    set -x SSH_AGENT_PID (echo "$_ssh_socket" | sed 's/[^.]*\.//')
#    set -x SSH_AUTH_SOCK "$_ssh_socket"
#end
