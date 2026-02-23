# claude-code-wsl-paste

Paste screenshots and images into [Claude Code](https://docs.anthropic.com/en/docs/claude-code) running on WSL with **Alt+V**.

## The Problem

Claude Code's image paste does not work on WSL. The CLI relies on `wl-paste` to read clipboard contents, but on WSL the clipboard bridge between Windows and Linux doesn't handle image data properly. This is a known issue with no official fix:

- [#13738](https://github.com/anthropics/claude-code/issues/13738) — Clipboard image paste not working in WSL
- [#3150](https://github.com/anthropics/claude-code/issues/3150) — Cannot copy screenshots from WSL terminal
- [#14635](https://github.com/anthropics/claude-code/issues/14635) — xclip/wl-paste fail without X11 in WSL2
- [#1361](https://github.com/anthropics/claude-code/issues/1361) — Can't paste image from clipboard
- [#834](https://github.com/anthropics/claude-code/issues/834) — Unable to paste images into TUI

## The Solution

A `wl-paste` wrapper that reads the Windows clipboard directly, bypassing the broken WSLg bridge:

- **Text clipboard** → `win32yank.exe` (reads Windows clipboard directly)
- **Image clipboard** → `powershell.exe` with `System.Windows.Forms.Clipboard` saves the image as PNG to a temp file via UNC path, then the wrapper reads it back
- **Type detection + image save in one call** — since PowerShell is slow to start, the wrapper does both in a single invocation

Combined with a Claude Code keybinding (**Alt+V** → `chat:imagePaste`), this gives you working screenshot paste on WSL.

## Requirements

- WSL 2 (Ubuntu or other distro)
- [win32yank.exe](https://github.com/equalsraf/win32yank/releases) in PATH
- PowerShell available via WSL interop (`powershell.exe`)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI

## Install

```bash
git clone https://github.com/imurodl/claude-code-wsl-paste.git
cd claude-code-wsl-paste
bash install.sh
```

This will:
- Install the `wl-paste` wrapper to `/usr/local/bin/wl-paste`
- Create a Claude Code keybinding for **Alt+V** → image paste

## Usage

1. Take a screenshot (Win+Shift+S, PrintScreen, or any snipping tool)
2. In Claude Code, press **Alt+V**
3. The screenshot is pasted into your conversation

Regular text copy/paste (Ctrl+Shift+V) continues to work normally.

## Uninstall

```bash
bash uninstall.sh
```

## How It Works

```
Alt+V in Claude Code
  → calls wl-paste --list-types
  → wrapper checks clipboard via win32yank.exe (text) and powershell.exe (image)
  → if image found, saves PNG to /tmp/.clipboard-image.png via UNC path
  → reports "image/png" as available type

Claude Code requests image
  → calls wl-paste --type image/png
  → wrapper returns the pre-saved temp file (instant, no corruption)
```

## License

MIT
