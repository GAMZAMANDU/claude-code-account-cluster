#!/usr/bin/env bash
set -euo pipefail

DEST="${HOME}/.local/bin"
CCMA_VERSION="0.3.8"

mkdir -p "$DEST"

# Install dependency
if ! command -v claude-code-multi-accounts &>/dev/null; then
    echo "Installing claude-code-multi-accounts@${CCMA_VERSION}..."
    npm install -g "claude-code-multi-accounts@${CCMA_VERSION}"
else
    echo "claude-code-multi-accounts already installed: $(claude-code-multi-accounts --version 2>/dev/null || echo 'ok')"
fi

# Remove old cc-* binaries (replaced by single cc command)
for old in cc-ls cc-use cc-best cc-log cc-stats cc-capture cc-help; do
    if [ -f "$DEST/$old" ]; then
        rm "$DEST/$old"
        echo "Removed legacy $old"
    fi
done

# Install new binaries
for script in bin/cc bin/cc-switch; do
    name=$(basename "$script")
    cp "$script" "$DEST/$name"
    chmod +x "$DEST/$name"
    echo "Installed $name → $DEST/$name"
done

echo
echo "Add ~/.local/bin to your PATH if not already:"
echo '  export PATH="$HOME/.local/bin:$PATH"'
echo
echo "Run 'cc help' to get started."
