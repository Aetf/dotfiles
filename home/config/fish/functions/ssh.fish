function ssh --description 'Login to vps with tmux' -w ssh
    if test (count $argv) -ge 1
        switch $argv[-1]
            case 'vps'
                command ssh $argv 'exec tmux new -As Arch'
            case 'cc*'
                command ssh $argv 'exec tmux new -As Peifeng'
            case 'clarity*'
                command ssh $argv 'exec tmux new -As Peifeng'
            case '*'
                command ssh $argv
        end
    else
        command ssh $argv
    end
end
