@~/.claude/HOST.md
@~/.local/state/claude/vault/Claude/global/GLOBAL.md

# 记忆系统（Obsidian vault 直连）

记忆统一存放在 Obsidian vault 的 `Claude/` 下（真实路径每台机器不同，稳定入口是 symlink `~/.local/state/claude/vault`），按 scope 分文件夹（`global`/`home`/`esphome`/…）。各项目的 auto-memory 目录是指向 `~/.local/state/claude/vault/Claude/<scope>` 的 symlink，内建记忆机制照常工作，只是落盘进 vault。

## 存储纪律

- 写记忆前若发现本项目的 memory 目录**不是 symlink**（新项目、新机器、或项目路径变动导致 project 身份变化），先运行 `claude-vault-link <scope> [项目目录]` 收编：它会把已产生的零散本地记忆并入 scope 并建好 symlink。scope 名用语义名（如 `blog`、`kluster`），已有 scope 见 `~/.local/state/claude/vault/Claude/`。
- 若 `~/.local/state/claude/vault` 不存在或悬空：不要写本地记忆，提醒用户做每机 bootstrap：`mkdir -p ~/.local/state/claude && ln -s <vault路径> ~/.local/state/claude/vault`。
- 见到 `*.sync-conflict-*` 文件说明 Syncthing 冲突，人工合并内容后删除冲突副本。

## 记忆分流

- **全局**（跨项目、跨机器都适用的 user/feedback 类：语言偏好、工作方式规则等）→ 写 `Claude/global/`，并在 `Claude/global/GLOBAL.md` 追加一行 `@~/.local/state/claude/vault/Claude/global/<file>.md`（该文件每个会话经本文件 import 加载，不走召回）。
- **项目/领域事实** → 写本项目 scope，照常维护该 scope 的 MEMORY.md 索引。

## 记忆的写法

正文遵守 [[../global/feedback-docs-as-built]] 的 fact doc 纪律（一切产出文字通用）。记忆特有的几条：

- 状态与结论可带绝对日期戳（如 "2026-08-18 竣工"）；知识过时就地改写并留一行指针；确认错误的记忆直接删除。
- 记忆**多机共享**：只对某台机器成立的事实要标明机器名（如【机器:Aetf-Arch-Homelab】）。本机身份见 `~/.claude/HOST.md`。
- 互链用 `[[wikilink]]`；跨 scope 用相对形式如 `[[../home/xxx]]`。中文为主、英文术语照写。
- **MEMORY.md 是目录不是摘要**：每条一行 `- [标题](file.md) — 一句话说明这里面是什么`，不要把结论抄进索引。它每个会话全额加载，密度要低。
