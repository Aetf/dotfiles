# zsh 的 EQUALS 展开把行首为 `=` 的词整个替换成"其余部分作为命令名"的绝对路径
# （`=ls` → /usr/bin/ls）。代价是任何以 `=` 开头的字面量都会被当命令去查：
#   echo === foo ===   → (eval):1: == not found
#   [ "$a" == "$b" ]   → zsh:1: = not found
# 这两种写法在生成的命令里极常见，而 `=cmd` 有等价替代（`${commands[cmd]}`）。
#
# 只对 Claude Code 的 Bash 工具关掉——它跑的是非交互 zsh（只读 ~/.zshenv，
# 即本目录），且命令由模型按 bash 习惯生成，踩得最频繁。交互 shell 保留展开。
# 不受影响：`=(...)` 进程替换、`--opt=val`、`VAR=val`、`[[ a == b ]]`。
[[ -n $CLAUDECODE ]] && setopt no_equals
