#!/bin/bash
set -e

echo "Installing claude-code-wsl-paste..."

# Check we're running inside WSL
if [[ -z "$WSL_DISTRO_NAME" ]]; then
    echo "Error: This script must be run inside WSL."
    exit 1
fi

# Check dependencies
if ! command -v win32yank.exe &>/dev/null; then
    echo "Error: win32yank.exe not found in PATH."
    echo "Install it: https://github.com/equalsraf/win32yank/releases"
    echo "  Or via scoop: scoop install win32yank"
    exit 1
fi

if ! command -v powershell.exe &>/dev/null; then
    echo "Error: powershell.exe not found (WSL interop may be disabled)."
    exit 1
fi

# Install wl-paste and wl-copy wrappers
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
sudo cp "$SCRIPT_DIR/wl-paste" /usr/local/bin/wl-paste
sudo cp "$SCRIPT_DIR/wl-copy" /usr/local/bin/wl-copy
sudo chmod +x /usr/local/bin/wl-paste /usr/local/bin/wl-copy

echo "Installed wl-paste wrapper to /usr/local/bin/wl-paste"
echo "Installed wl-copy wrapper to /usr/local/bin/wl-copy"

# Set up Claude Code keybinding for Alt+V image paste
KEYBINDINGS="$HOME/.claude/keybindings.json"
if [[ -f "$KEYBINDINGS" ]]; then
    echo "Keybindings file already exists at $KEYBINDINGS"
    echo "Add this manually if needed:"
    echo '  { "bindings": [{ "context": "Chat", "bindings": { "alt+v": "chat:imagePaste" } }] }'
else
    mkdir -p "$HOME/.claude"
    cat > "$KEYBINDINGS" << 'EOF'
{
  "bindings": [
    {
      "context": "Chat",
      "bindings": {
        "alt+v": "chat:imagePaste"
      }
    }
  ]
}
EOF
    echo "Created Claude Code keybinding: Alt+V for image paste"
fi

echo ""
echo "Done! Take a screenshot and press Alt+V in Claude Code to paste it."
