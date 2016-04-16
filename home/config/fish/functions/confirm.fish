function confirm --description 'Confirm with a prompt'
    if test (count $argv) -eq 0
        set prompt 'Are you sure ?'
    else
        set prompt "$argv"
    end
    append prompt " [Y/n] "
    read -l -p "echo '$prompt'" response
    switch $response
        case n no
            return 1
        case '*'
            return
    end
end