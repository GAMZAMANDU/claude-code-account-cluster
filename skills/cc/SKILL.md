---
name: cc
description: Show Claude Code account status and help switch accounts to avoid rate limits
level: 1
---

# cc — Account Status & Switcher

Use this skill when the user asks about account usage, rate limits, or wants to switch Claude Code accounts.

## Available commands

- `cc ls` — list all accounts with 5H/7D usage bars and reset times
- `cc use <n>` — switch to account at index n
- `cc best` — auto-switch to account with most remaining capacity
- `cc log` — show switch history
- `cc stats` — usage heatmap and session statistics
- `cc capture` — save current login and logout (for adding new accounts)

## When rate-limited

Run `cc best` to immediately switch to the best available account. Claude Code will pick up the new credentials on the next request without restarting.

## Task

{{ARGUMENTS}}
