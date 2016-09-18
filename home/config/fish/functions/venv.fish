function venv --description 'Python virtualenv wrapper for fish. Start virtualenv in subshell'
    set argc (count $argv)
    if test $argc -eq 0
        echo "Usage:  venv [OPTIONS] VENVPATH"
        echo "Activate virtual environment at VENVPATH in a subshell. Creating new one if necessary."
        echo "You can deactivate it by simply typing exit or ctrl+D in the subshell."
        echo "OPTIONS are directly passed to the virtualenv command."
        echo ""
        echo "The actual path to the virtual environment is decided in the followling order:"
        echo "    1. If VENVPATH/bin/activate.fish exists, stop"
        echo "    2. If VENVPATH is absolute path (starts with /), stop"
        echo "    3. VENVPATH=~/.local/venvs/VENVPATH/bin/activate.fish"
        echo "    4. If VENVPATH/bin/activate.fish exists, stop"
        echo "If stopped without found activate.fish, prompt to create the virtual environment at VENVPATH."
    else
        set orig_path $argv[-1]
        set venv_path $orig_path
        set -e argv[-1]

        # Search for the specified venv_path
        if not test -f "$venv_path/bin/activate.fish"
            switch "$venv_path"
                case '/*'
                    # nothing
                case '*'
                    set venv_path ~/.local/venvs/$venv_path
            end
        end

        if not test -f "$venv_path/bin/activate.fish"
            if confirm "Virtualenv \"$orig_path\" not found. Create at $venv_path?"
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
