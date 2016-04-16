function cute --description 'Open CuteMarkEd editor quietly' -w cutemarked
	command cutemarked $argv >/dev/null ^&1 &
end
