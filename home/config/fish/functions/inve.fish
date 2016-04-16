function inve --description 'Activate python virtualenv in ~/.local/venvs'
	set -x VIRTUAL_ENV_DISABLE_PROMPT 1
. ~/.local/venvs/$argv[1]/bin/activate.fish
end
