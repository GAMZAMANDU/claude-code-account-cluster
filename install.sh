#!/usr/bin/env bash
set -euo pipefail

DEST="${HOME}/.local/bin"
mkdir -p "$DEST"

for script in bin/cc-*; do
  name=$(basename "$script")
  cp "$script" "$DEST/$name"
  chmod +x "$DEST/$name"
  echo "Installed $name → $DEST/$name"
done

echo
echo "Add ~/.local/bin to your PATH if not already:"
echo '  export PATH="$HOME/.local/bin:$PATH"'
echo
echo "Run 'cc-help' to get started."
