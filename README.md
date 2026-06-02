# cc-multiaccounts

Multi-account switcher for [Claude Code](https://claude.ai/code) with rate limit visualization and auto-switching.

Built on top of [ClaudeCodeMultiAccounts](https://github.com/nicholasgasior/ClaudeCodeMultiAccounts) (`cc-switch`).

## Why

Claude Code has 5-hour and 7-day rate limits. When one account hits the limit, you can switch to another account to keep working. This toolkit makes that seamless.

## Requirements

- macOS (uses Keychain via `security` CLI)
- [ClaudeCodeMultiAccounts](https://github.com/nicholasgasior/ClaudeCodeMultiAccounts) (`cc-switch` must be in PATH)
- Python 3
- Claude Code CLI

## Install

```bash
git clone https://github.com/your-username/cc-multiaccounts
cd cc-multiaccounts
bash install.sh
```

## Commands

| Command | Description |
|---------|-------------|
| `cc-ls` | List all accounts with rate limit progress bars |
| `cc-stats` | GitHub-style usage heatmap + session statistics |
| `cc-best` | Auto-switch to the account with most remaining capacity |
| `cc-use <index>` | Switch to a specific account |
| `cc-capture` | Save current login session and auto-logout |
| `cc-help` | Show command reference |

## Usage

### Add accounts

For each account you want to add:

```bash
claude auth login   # log in with the target account
cc-capture          # saves credentials and logs out
```

Repeat for all accounts. Then restore your main account:

```bash
claude auth login   # log back in with your primary account
```

### Switch accounts

Close Claude Code first, then:

```bash
cc-best             # auto-pick the account with most capacity
# or
cc-use 1            # switch to account at index 1
```

Relaunch Claude Code. The new account is active.

### Inside Claude Code

Running `cc-best` from within a Claude Code session will automatically:
1. Switch to the best account (Keychain update)
2. Kill the current session
3. Resume with `claude --resume <session-id>`

### Check status

```bash
cc-ls       # account list with 5H/7D usage bars
cc-stats    # heatmap of activity over the past year
```

## How it works

Claude Code stores OAuth credentials in the macOS Keychain under `"Claude Code-credentials"`. The `cc-switch` tool (from ClaudeCodeMultiAccounts) reads/writes `~/.claude/.credentials.json`, but newer Claude Code versions only use the Keychain.

These scripts bridge that gap:
- `cc-capture` syncs Keychain → file before snapshot
- `cc-use` writes credentials to both file and Keychain before switching
- `cc-best` picks the optimal account by lowest 5H utilization

## Rate limit display

```
5H ████████░░░░ 67%  resets 4h06m
7D ██████░░░░░░ 47%  resets 143h26m
```

- **5H** = 5-hour rolling window utilization
- **7D** = 7-day rolling window utilization
- Bar fills = usage (red = near limit, green = plenty left)

## License

MIT
