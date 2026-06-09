#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="${HOME}/.local/bin"
CLAUDE_SETTINGS="${HOME}/.claude/settings.json"
CCMA_VERSION="0.3.8"

mkdir -p "$DEST"

# ── 1. npm dependency ──────────────────────────────────────────────────────────
if ! command -v claude-code-multi-accounts &>/dev/null; then
    echo "Installing claude-code-multi-accounts@${CCMA_VERSION}..."
    npm install -g "claude-code-multi-accounts@${CCMA_VERSION}"
else
    echo "claude-code-multi-accounts: $(claude-code-multi-accounts --version 2>/dev/null || echo ok)"
fi

# ── 2. Binaries ────────────────────────────────────────────────────────────────
for old in cc-ls cc-use cc-best cc-log cc-stats cc-capture cc-help; do
    [ -f "$DEST/$old" ] && rm "$DEST/$old" && echo "Removed legacy $old"
done

for script in bin/cc bin/cc-switch; do
    name=$(basename "$script")
    cp "$REPO_ROOT/$script" "$DEST/$name"
    chmod +x "$DEST/$name"
    echo "Installed $name → $DEST/$name"
done

# ── 3. Statusline ──────────────────────────────────────────────────────────────
STATUSLINE_DEST="${HOME}/.claude/statusline-command.sh"
STATUSLINE_CMD="bash '${STATUSLINE_DEST}'"

cp "$REPO_ROOT/hooks/statusline.sh" "$STATUSLINE_DEST"
chmod +x "$STATUSLINE_DEST"
echo "Installed statusline → $STATUSLINE_DEST"

if [ -f "$CLAUDE_SETTINGS" ] && command -v python3 &>/dev/null; then
    python3 - "$CLAUDE_SETTINGS" "$STATUSLINE_CMD" <<'EOF'
import json, sys
path, cmd = sys.argv[1], sys.argv[2]
with open(path) as f:
    cfg = json.load(f)
cfg["statusLine"] = {"type": "command", "command": cmd}
with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
print(f"Configured statusLine → {cmd}")
EOF
else
    echo "⚠  Set statusLine manually in ~/.claude/settings.json:"
    echo "   \"statusLine\": {\"type\": \"command\", \"command\": \"${STATUSLINE_CMD}\"}"
fi

echo
echo "Done. Add ~/.local/bin to PATH if needed:"
echo '  export PATH="$HOME/.local/bin:$PATH"'
echo "Run 'cc help' to get started."
