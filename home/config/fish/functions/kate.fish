function kate --description 'Open kate editor quietly' -w kate
	command kate $argv >/dev/null ^&1 &
end
