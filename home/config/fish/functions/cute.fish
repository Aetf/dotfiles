function cute --description 'Open CuteMarkEd editor quietly'
	command cutemarked $argv >/dev/null ^&1 &
end
