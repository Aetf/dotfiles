@~/.config/claude/HOST.md

# 记忆系统（Obsidian vault 直连）

记忆统一存放在 Obsidian vault 的 `Claude/` 下。vault 的路径每台机器不同（见本机画像），**一律用真实路径，不经 symlink**：经 symlink 的写入，Claude Code 每次都弹权限窗。路径由两处按主机声明——yadm 的 `HOST.md##h.<hostname>`（import 本机画像与 `global/GLOBAL.md`）与 aconfmgr 的 `files-<hostname>/etc/claude-code/managed-settings.d/10-memory.json`（`autoMemoryDirectory`）。两个目录：`global/` 是每会话经 `HOST.md` import 全额加载的规则；`memory/` 是内建 auto-memory 的目录（`MEMORY.md` 索引 + 事实文件，走召回）。**所有机器、所有项目共用这一个 `memory/`**，不按项目分目录。机器画像在 `machines/<hostname>.md`（本机那份经 `HOST.md` import 已加载），agent 面的画像在 `agents/`；改机器事实改那里，不改 yadm。

## 存储纪律

- 若本机 vault 目录不存在（NAS 没挂载、Syncthing 目录缺失，症状是本机画像与全局规则都没加载进来）：**不要写记忆**——harness 会按 `autoMemoryDirectory` 建出真目录，之后与 vault 冲突；告诉用户 vault 不在。新机器接入见 vault 的 `Claude/README.md`。
- 见到 `*.sync-conflict-*` 文件说明 Syncthing 冲突，人工合并内容后删除冲突副本。

## 记忆分流

- **全局规则**（跨项目、跨机器都适用的 user/feedback 类：语言偏好、工作方式规则等）→ 写 `Claude/global/`，并在 `Claude/global/GLOBAL.md` 追加一行 `@<file>.md`（相对 GLOBAL.md 自己解析，与机器无关）。
- **其余一切事实** → `Claude/memory/`，照常维护 `MEMORY.md` 索引。

## 记忆的写法

正文遵守 [[../global/feedback-docs-as-built]] 的 fact doc 纪律（一切产出文字通用）。记忆特有的几条：

- 状态与结论可带绝对日期戳（如 "2026-08-18 竣工"）；知识过时就地改写并留一行指针；确认错误的记忆直接删除。
- 记忆**多机共享**：只对某台机器成立的事实要标明机器——frontmatter `machine: [<hostname>]`，索引行加【机器:X】。本机身份见 `~/.config/claude/HOST.md`。
- 互链用 `[[wikilink]]`；指向 global 用 `[[../global/xxx]]`。中文为主、英文术语照写。
- **MEMORY.md 是目录不是摘要**：每条一行 `- [标题](file.md) — 一句话说明这里面是什么`，不要把结论抄进索引。它只加载前 200 行 / 25 KB；逼近上限时把一族条目收成一个「入口」笔记（如 kluster-nextgen），不分目录。
