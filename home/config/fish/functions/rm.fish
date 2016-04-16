function rm --description 'Safe rm' -w rm
	command rm -I --preserve-root $argv
end
