#!/bin/bash
set -e

echo "Uninstalling claude-code-wsl-paste..."

# Remove wl-paste wrapper
if [[ -f /usr/local/bin/wl-paste ]]; then
    sudo rm /usr/local/bin/wl-paste
    echo "Removed /usr/local/bin/wl-paste (system wl-paste at /usr/bin/wl-paste restored)"
else
    echo "No wrapper found at /usr/local/bin/wl-paste"
fi

# Remove wl-copy wrapper
if [[ -f /usr/local/bin/wl-copy ]]; then
    sudo rm /usr/local/bin/wl-copy
    echo "Removed /usr/local/bin/wl-copy (system wl-copy at /usr/bin/wl-copy restored)"
else
    echo "No wrapper found at /usr/local/bin/wl-copy"
fi

# Clean up temp file
rm -f /tmp/.clipboard-image.png

echo "Done. Claude Code keybindings left unchanged."
