# cc-multiaccounts

Multi-account switcher for [Claude Code](https://claude.ai/code) with rate limit visualization and auto-switching.

Built on top of [ClaudeCodeMultiAccounts](https://github.com/Leuconoe/ClaudeCodeMultiAccounts) (`claude-code-multi-accounts@0.3.8`).

## Why

Claude Code has 5-hour and 7-day rate limits. When one account hits the limit, you can switch to another account to keep working. This toolkit makes that seamless.

## Requirements

- macOS (uses Keychain via `security` CLI)
- Node.js + npm (to install `claude-code-multi-accounts` — handled by install.sh)
- Python 3
- Claude Code CLI

## Install

```bash
git clone https://github.com/gamzamandu/cc-multiaccounts
cd cc-multiaccounts
bash install.sh
```

`install.sh` automatically installs `claude-code-multi-accounts@0.3.8` if not present.

## Commands

All commands go through the single `cc` binary:

| Command | Description |
|---------|-------------|
| `cc` | List all accounts with rate limit bars |
| `cc ls` | Same as above |
| `cc use` | Interactive account picker (fzf) |
| `cc use <n>` | Switch to account at index n |
| `cc best` | Auto-switch to account with most remaining capacity |
| `cc log [n]` | Show switch history (default: 20 entries) |
| `cc stats` | GitHub-style usage heatmap + session statistics |
| `cc capture` | Save current login session and auto-logout |
| `cc help` | Show command reference |

## Usage

### Add accounts

For each account you want to add:

```bash
claude auth login   # log in with the target account
cc capture          # saves credentials and logs out
```

Repeat for all accounts. Then restore your main account:

```bash
claude auth login   # log back in with your primary account
```

### Switch accounts

Close Claude Code first, then:

```bash
cc best             # auto-pick the account with most capacity
# or
cc use              # interactive fzf picker
# or
cc use 1            # switch to account at index 1
```

Relaunch Claude Code. The new account is active.

### Inside Claude Code

Running `cc best` from within a Claude Code session will automatically:
1. Switch to the best account (Keychain update)
2. Kill the current session
3. Resume with `claude --resume <session-id>`

### Check status

```bash
cc              # account list with ▶ active and ★ best markers
cc stats        # heatmap of activity over the past year
cc log          # switch history with before/after utilization
```

## How it works

Claude Code stores OAuth credentials in the macOS Keychain under `"Claude Code-credentials"`. `claude-code-multi-accounts` reads/writes `~/.ClaudeCodeMultiAccounts.json` and `~/.claude.json`.

These scripts bridge the gap with Keychain awareness:
- `cc capture` syncs Keychain → file before snapshot
- `cc use` writes credentials to both file and Keychain before switching
- `cc best` picks the optimal account by lowest 5H utilization
- Switch history is logged to `~/.cc-multiaccounts-history.jsonl`

## Rate limit display

```
5H ████████░░░░ 67%  resets 4h06m
7D ██████░░░░░░ 47%  resets 143h26m
```

- **5H** = 5-hour rolling window utilization
- **7D** = 7-day rolling window utilization
- Bar fills = usage (red = near limit, green = plenty left)
- `▶` = active account, `★` = recommended next account

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [claude-code-multi-accounts](https://github.com/Leuconoe/ClaudeCodeMultiAccounts) | 0.3.8 | Account store read/write and switching |

## License

MIT
