#!/bin/bash
set -e

echo "Installing claude-code-wsl-paste..."

# Check we're running inside WSL
if [[ -z "$WSL_DISTRO_NAME" ]]; then
    echo "Error: This script must be run inside WSL."
    exit 1
fi

# Check for at least one clipboard backend
HAS_WSLG=false
HAS_WIN32YANK=false

if /usr/bin/wl-paste --list-types &>/dev/null; then
    HAS_WSLG=true
fi
if command -v win32yank.exe &>/dev/null; then
    HAS_WIN32YANK=true
fi

if [[ "$HAS_WSLG" == "false" ]] && [[ "$HAS_WIN32YANK" == "false" ]]; then
    echo "Error: No clipboard backend available."
    echo "  Either WSLg must be working, or install win32yank.exe:"
    echo "  https://github.com/equalsraf/win32yank/releases"
    exit 1
fi

# ImageMagick needed for WSLg mode (BMP→PNG conversion)
if [[ "$HAS_WSLG" == "true" ]] && ! command -v convert &>/dev/null; then
    echo "Warning: ImageMagick not found (needed for WSLg mode)."
    echo "  sudo apt install imagemagick"
    if [[ "$HAS_WIN32YANK" == "false" ]]; then
        echo "Error: No fallback available either. Install ImageMagick or win32yank.exe."
        exit 1
    fi
    echo "  Falling back to win32yank.exe + PowerShell mode."
fi

# PowerShell needed for fallback mode
if [[ "$HAS_WSLG" == "false" ]] && ! command -v powershell.exe &>/dev/null; then
    echo "Error: powershell.exe not found (needed for image paste in fallback mode)."
    exit 1
fi

# Install wl-paste wrapper
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
sudo cp "$SCRIPT_DIR/wl-paste" /usr/local/bin/wl-paste
sudo chmod +x /usr/local/bin/wl-paste

if [[ "$HAS_WSLG" == "true" ]]; then
    echo "Installed wl-paste wrapper (WSLg mode: BMP→PNG via ImageMagick)"
else
    echo "Installed wl-paste wrapper (fallback mode: win32yank + PowerShell)"
fi

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
