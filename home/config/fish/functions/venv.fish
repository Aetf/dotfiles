function venv --description 'Create python virtualenv in ~/.local/venvs'
    set argc (count $argv)
    if test $argc -eq 0
        echo helptext
    else
        set venv_path $argv[-1]
        set -e argv[-1]
        if not test -f "$venv_path/bin/activate.fish"
            set venv_path ~/.local/venvs/$venv_path
        end

        if not test -f "$venv_path/bin/activate.fish"
            if confirm "Virtualenv $venv_path not found. Create?"
                virtualenv $argv $venv_path
            else
                return
            end
        end

        #fish -c ". $venv_path/bin/activate.fish; exec fish"
        # hacky workaround for virtualenv nonsense cleanup
        env _OLD_VIRTUAL_PATH= _OLD_VIRTUAL_PYTHONHOME= _OLD_FISH_PROMPT_OVERRIDE= fish -c ". $venv_path/bin/activate.fish; exec fish"
    end
end
