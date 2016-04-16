function cdmk --description 'Create a directory and set CWD' -w cd
	command mkdir $argv
	if test $status = 0
		if not match "-*" $argv[-1]
			cd $argv[-1]
			return
		end
	end
end
