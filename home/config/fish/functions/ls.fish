function ls --description "List contents of directory" -w ls
    set -l param --color=auto -v -h
    if isatty 1
        set param $param --indicator-style=classify
    end
    command ls $param $argv
end
