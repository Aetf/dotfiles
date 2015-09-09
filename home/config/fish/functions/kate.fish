function kate --description 'Open kate editor quietly'
	command kate $argv >/dev/null ^&1 &
end
