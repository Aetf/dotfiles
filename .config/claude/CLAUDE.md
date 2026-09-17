@~/.config/claude/HOST.md
@~/.local/state/claude/vault/Claude/global/GLOBAL.md

# 记忆系统（Obsidian vault 直连）

记忆统一存放在 Obsidian vault 的 `Claude/` 下（真实路径每台机器不同，稳定入口是 symlink `~/.local/state/claude/vault`）。两个目录：`global/` 是每会话经本文件 import 全额加载的规则；`memory/` 是内建 auto-memory 的目录（`MEMORY.md` 索引 + 事实文件，走召回）。**所有机器、所有项目共用这一个 `memory/`**——settings.json 的 `autoMemoryDirectory` 指向它，不按项目分目录、不靠 symlink。机器画像在 `machines/<hostname>.md`（本机那份经 `HOST.md` 一行 import 已加载），agent 面的画像在 `agents/`；改机器事实改那里，不改 yadm。

## 存储纪律

- 若 `~/.local/state/claude/vault` 不存在或悬空：**不要写记忆**（harness 会在悬空路径下建真目录，之后与 vault 冲突），提醒用户做每机 bootstrap：`mkdir -p ~/.local/state/claude && ln -s <vault路径> ~/.local/state/claude/vault`。
- 见到 `*.sync-conflict-*` 文件说明 Syncthing 冲突，人工合并内容后删除冲突副本。

## 记忆分流

- **全局规则**（跨项目、跨机器都适用的 user/feedback 类：语言偏好、工作方式规则等）→ 写 `Claude/global/`，并在 `Claude/global/GLOBAL.md` 追加一行 `@~/.local/state/claude/vault/Claude/global/<file>.md`。
- **其余一切事实** → `Claude/memory/`，照常维护 `MEMORY.md` 索引。

## 记忆的写法

正文遵守 [[../global/feedback-docs-as-built]] 的 fact doc 纪律（一切产出文字通用）。记忆特有的几条：

- 状态与结论可带绝对日期戳（如 "2026-08-18 竣工"）；知识过时就地改写并留一行指针；确认错误的记忆直接删除。
- 记忆**多机共享**：只对某台机器成立的事实要标明机器——frontmatter `machine: [<hostname>]`，索引行加【机器:X】。本机身份见 `~/.config/claude/HOST.md`。
- 互链用 `[[wikilink]]`；指向 global 用 `[[../global/xxx]]`。中文为主、英文术语照写。
- **MEMORY.md 是目录不是摘要**：每条一行 `- [标题](file.md) — 一句话说明这里面是什么`，不要把结论抄进索引。它只加载前 200 行 / 25 KB；逼近上限时把一族条目收成一个「入口」笔记（如 kluster-nextgen），不分目录。
