function ssh --description 'Login to vps with tmux'
    if test (count $argv) -ge 1
        if test $argv[1] = 'vps'
            command ssh $argv 'tmux new -As \'Arch\''
            return
        end
    end
    command ssh $argv
end
