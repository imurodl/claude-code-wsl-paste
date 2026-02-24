#!/bin/bash
set -e

echo "Installing claude-code-wsl-paste..."

# Check we're running inside WSL
if [[ -z "$WSL_DISTRO_NAME" ]]; then
    echo "Error: This script must be run inside WSL."
    exit 1
fi

# Check dependencies
if ! command -v convert &>/dev/null; then
    echo "Error: ImageMagick not found. Install it:"
    echo "  sudo apt install imagemagick"
    exit 1
fi

if ! command -v /usr/bin/wl-paste &>/dev/null; then
    echo "Error: wl-paste not found. Install it:"
    echo "  sudo apt install wl-clipboard"
    exit 1
fi

# Install wl-paste wrapper
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
sudo cp "$SCRIPT_DIR/wl-paste" /usr/local/bin/wl-paste
sudo chmod +x /usr/local/bin/wl-paste

echo "Installed wl-paste wrapper to /usr/local/bin/wl-paste"

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
