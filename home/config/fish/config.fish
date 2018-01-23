#
# ~/.config/fish/config.fish
#

# If not running interactively, don't do anything
if not status -i; exit; end

# Some environment variables
## More colorful
if test $TERM != "screen-256color";
    set TERM xterm-256color
end

## Default editor
set -x EDITOR vim

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
function _setup_powerline
    powerline-daemon -q
    set fish_function_path $fish_function_path "/usr/local/lib/python2.7/site-packages/powerline/bindings/fish"
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
