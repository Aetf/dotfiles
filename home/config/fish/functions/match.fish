function match --description 'match string against a pattern'
	if test (count $argv) -ne 2
		echo "match: Expected two arguments, "(count $argv)" received."
		echo "Usage: match PATTERN STRING"
		return 1
	end
	switch $argv[2]
		case $argv[1]
			return 0
	end
	return 1
end
