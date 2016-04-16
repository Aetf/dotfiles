function venv --description 'Create python virtualenv in ~/.local/venvs'
    set argc (count $argv)
    if test $argc -eq 0
        echo helptext
    else
        set venv_path ~/.local/venvs/$argv[-1]
        if test -d $venv_path
            #fish -c ". $venv_path/bin/activate.fish; exec fish"
            # hacky workaround for virtualenv nonsense cleanup
            env _OLD_VIRTUAL_PATH= _OLD_VIRTUAL_PYTHONHOME= _OLD_FISH_PROMPT_OVERRIDE= fish -c ". $venv_path/bin/activate.fish; exec fish"
        else
            if confirm "Virtualenv $venv_path not found. create?"
                if test argc -ge 1
                    set venv_arg $argv[1:-2]
                end
                virtualenv $venv_arg $venv_path
            end
        end
    end
end
