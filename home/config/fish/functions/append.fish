function append --description 'Append STRING to VARIABLE' --no-scope-shadowing
	if test (count $argv) -ne 2
		echo "append: Expected two arguments, "(count $argv)" received."
		echo "Usage: append VARIABLE STRING"
		return 1
	end
	set -l __fish_append_value $$argv[1]
	set $argv[1] "$__fish_append_value$argv[2]"
end
