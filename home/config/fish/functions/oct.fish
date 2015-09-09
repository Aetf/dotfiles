function oct
    if test (count $argv) -ge 2
        if test $argv[1] = "new"
            if test $argv[2] = "post"
                set filename (command octopress $argv)
                cutemarked $filename >/dev/null ^&1 &
                return
            end
        end
    end
    command octopress $argv
end
