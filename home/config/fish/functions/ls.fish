function ls --description "List contents of directory"
    set -l param -G -v
    if isatty 1
        set param $param -F
    end
    command ls $param $argv
end
