function fk --description "Kill processes"
  set -l __kp__pid (command ps -ef | sed 1d | fzf (echo $FZF_DEFAULT_OPTS) -m --header='[kill:process]' | awk '{print $2}')
  set -l __kp__kc $argv[1]

  if test "x$__kp__pid" != "x"
    if test "x$argv[1]" != "x"
      echo $__kp__pid | xargs kill $argv[1]
    else
      echo $__kp__pid | xargs kill -9
    end
    kp
  end
end

