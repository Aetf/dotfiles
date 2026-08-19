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

## 内容规范：fact doc，不是操作历史

- 记录事实、约束、根因、可复用方法、坑；不记录"当时做了什么"的过程叙事。判据：三个月后读它能直接指导行动，而不是复述一段历史。
- 状态与结论可带绝对日期戳（如 "2026-08-18 竣工"）；知识过时就地改写并留一行指针；确认错误的记忆直接删除。
- 记忆现在是**多机共享**的：只对某台机器成立的事实要标明机器名（如【机器:Aetf-Arch-Homelab】）。
- 互链用 `[[wikilink]]`；跨 scope 用相对形式如 `[[../home/xxx]]`。中文为主、英文术语照写。
