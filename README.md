# cc-multiaccounts

Multi-account switcher for [Claude Code](https://claude.ai/code) with live rate limit visualization, auto-switching, and seamless account restart.

Built on top of [ClaudeCodeMultiAccounts](https://github.com/Leuconoe/ClaudeCodeMultiAccounts).

## Features

- Live usage bars (5H / 7D) fetched in parallel from the Claude API
- Statusline showing active account, reset time, available accounts, and recommendation
- Auto-switch + auto-restart when rate limit hits (`rate_limit` notification hook)
- Account switch inside Claude Code restarts the session automatically via `--resume`
- OAuth token auto-refresh before every switch
- Switch history log with before/after utilization

## Requirements

- macOS (Keychain via `security` CLI)
- Python 3
- Node.js + npm
- [Claude Code CLI](https://claude.ai/code)

## Install

```bash
git clone https://github.com/gamzamandu/cc-multiaccounts
cd cc-multiaccounts
bash install.sh
```

`install.sh` installs `claude-code-multi-accounts@0.3.8`, copies `cc`/`cc-switch` to `~/.local/bin`, and wires up the statusline and hooks in `~/.claude/settings.json`.

## Commands

| Command | Description |
|---------|-------------|
| `cc` / `cc ls` | List accounts with live usage bars |
| `cc use <n>` | Switch to account n |
| `cc best` | Switch to account with most remaining capacity |
| `cc capture` | Save current login credentials and logout |
| `cc refresh` | Refresh OAuth tokens for all accounts |
| `cc remove <n>` | Remove account at index n |
| `cc log [n]` | Switch history (default: 20) |
| `cc stats` | Usage heatmap + session statistics |
| `cc help` | Command reference |

## Account switching

When run inside Claude Code, `cc use <n>` and `cc best` automatically restart the session with `--resume` so the new account's token takes effect immediately.

When run outside Claude Code, credentials are updated and the next `claude` launch uses the switched account.

> **Note:** Auto-restart uses `osascript` to inject `claude --resume` into the terminal. Requires Accessibility access for your terminal app — grant it in **System Settings → Privacy & Security → Accessibility**.

## Adding accounts

```bash
claude auth login   # log in with the account to add
cc capture          # save credentials + auto-logout
# repeat for each account
claude auth login   # restore your main account
```

## Statusline

```
◉ Alice  ████░░ 67%  resets 1h12m  ·  2/3 free  ·  › [2] Bob ░░░░░░ 5%
```

| Element | Meaning |
|---------|---------|
| **◉** / **⚠** | Active account — ⚠ when over 80% used |
| **████░░ 67%** | 5H rate limit usage minibar |
| **resets 1h12m** | Time until current window resets |
| **2/3 free** | Accounts with capacity remaining |
| **› [2] Bob** | Recommended next account |

## Rate limit hook

When Claude Code hits a rate limit, `cc best` runs automatically via the `Notification` hook, switches to the account with the most capacity, and restarts the session.

```json
{
  "matcher": "rate_limit",
  "hooks": [{ "type": "command", "command": "/path/to/cc best" }]
}
```

## Project structure

```
cc-multiaccounts/
├── bin/
│   ├── cc              # main Python CLI
│   └── cc-switch       # shim for claude-code-multi-accounts
├── hooks/
│   └── statusline.sh   # statusline display script
└── install.sh
```

## License

MIT
