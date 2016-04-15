function lldb
	. ~/.local/venvs/voltron/bin/activate.fish 
    command lldb $argv
    deactivate
end
