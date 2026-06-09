# cc-multiaccounts

Multi-account switcher for [Claude Code](https://claude.ai/code) with live rate limit visualization, auto-switching, and statusline integration.

Built on top of [ClaudeCodeMultiAccounts](https://github.com/Leuconoe/ClaudeCodeMultiAccounts).

## Features

- Live usage bars (5H / 7D) fetched in parallel from the Claude API
- Statusline showing current account, reset time, available accounts, and next recommendation
- Auto-switch to best account when rate limit hits (`rate_limit` notification hook)
- OAuth token auto-refresh before switching
- Switch history log with before/after utilization

## Install

### Script install

```bash
git clone https://github.com/gamzamandu/cc-multiaccounts
cd cc-multiaccounts
bash install.sh
```

`install.sh` installs `claude-code-multi-accounts@0.3.8`, copies `cc`/`cc-switch` to `~/.local/bin`, and configures the statusline in `~/.claude/settings.json`.

### As a Claude Code plugin

Add to `~/.claude/settings.json`:

```json
"extraKnownMarketplaces": {
  "cc-multiaccounts": {
    "source": { "source": "github", "repo": "gamzamandu/cc-multiaccounts" }
  }
}
```

```bash
claude plugin install cc-multiaccounts@cc-multiaccounts
```

> Plugin install activates the `rate_limit` auto-switch hook and `/cc` skill. Run `bash install.sh` separately for the statusline and `cc` binary.

## Requirements

- macOS (Keychain via `security` CLI)
- Python 3
- Node.js + npm
- [Claude Code CLI](https://claude.ai/code)

## Commands

| Command | Description |
|---------|-------------|
| `cc` | List accounts with usage bars |
| `cc ls` | Same as above |
| `cc use` | Interactive fzf account picker |
| `cc use <n>` | Switch to account n |
| `cc best` | Auto-switch to account with most capacity |
| `cc log [n]` | Switch history (default: 20) |
| `cc stats` | Usage heatmap + session statistics |
| `cc capture` | Save current login and logout |
| `cc help` | Command reference |

## Adding accounts

```bash
claude auth login   # log in with account to add
cc capture          # save credentials + auto-logout
# repeat for each account
claude auth login   # restore your main account
```

## Statusline

```
◉ gamzamandu  ████░░ 67%  resets 1h12m  ·  2/4 free  ·  › [3] tigimudon ░░░░░░ 5%
```

- **◉ / ⚠** — active account (⚠ = over 80% used)
- **████░░** — 5H usage minibar
- **resets 1h12m** — time until current account resets
- **2/4 free** — accounts with capacity remaining
- **› [3] tigimudon** — recommended next account

## Project structure

```
cc-multiaccounts/
├── .claude-plugin/
│   ├── plugin.json          # hooks + skills manifest
│   └── marketplace.json     # marketplace metadata
├── bin/
│   ├── cc                   # main Python CLI
│   └── cc-switch            # shim for claude-code-multi-accounts
├── hooks/
│   ├── statusline.sh        # statusline display
│   └── on-rate-limit.sh     # auto cc best on rate_limit notification
├── skills/
│   └── cc/
│       └── SKILL.md         # /cc slash command
└── install.sh
```

## License

MIT
