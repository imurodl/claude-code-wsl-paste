# claude-code-wsl-paste

Paste screenshots and images into [Claude Code](https://docs.anthropic.com/en/docs/claude-code) running on WSL with **Alt+V**.

> **Note:** The underlying BMP detection issue has been [fixed upstream](https://github.com/anthropics/claude-code/pull/25935) (merged Feb 16, 2026). Once a Claude Code release includes that fix, this wrapper becomes unnecessary. The Alt+V keybinding will likely still be required.

## The Problem

Claude Code's image paste does not work on WSL. The CLI relies on `wl-paste` to read clipboard contents, but Windows screenshots are stored as BMP on the clipboard, while Claude Code only looks for `image/png`. This is a known issue:

- [#3150](https://github.com/anthropics/claude-code/issues/3150) — Cannot copy screenshots from WSL terminal
- [#13738](https://github.com/anthropics/claude-code/issues/13738) — Clipboard image paste not working in WSL
- [#14635](https://github.com/anthropics/claude-code/issues/14635) — xclip/wl-paste fail without X11 in WSL2
- [#1361](https://github.com/anthropics/claude-code/issues/1361) — Can't paste image from clipboard
- [#834](https://github.com/anthropics/claude-code/issues/834) — Unable to paste images into TUI

## The Solution

A `wl-paste` wrapper that auto-detects your environment and picks the best approach:

### WSLg mode (when WSLg clipboard works)
Delegates everything to the real `/usr/bin/wl-paste`, only intercepts BMP→PNG conversion via ImageMagick. Text, `wl-copy`, other MIME types — all pass through unchanged. Based on the approach by [@gptool](https://github.com/anthropics/claude-code/issues/3150).

**Requires:** `imagemagick`, `wl-clipboard`

### Fallback mode (when WSLg clipboard is broken)
Bypasses WSLg entirely using `win32yank.exe` for text and `powershell.exe` for images. Saves clipboard image to a temp file via UNC path to avoid binary corruption.

**Requires:** `win32yank.exe`, `powershell.exe`

The wrapper caches the WSLg check for 60 seconds, so there's no overhead on repeated calls.

## Install

```bash
git clone https://github.com/imurodl/claude-code-wsl-paste.git
cd claude-code-wsl-paste
bash install.sh
```

The installer auto-detects which mode your system supports and warns about missing dependencies.

## Usage

1. Take a screenshot (Win+Shift+S, PrintScreen, or any snipping tool)
2. In Claude Code, press **Alt+V**
3. The screenshot is pasted into your conversation

Regular text copy/paste continues to work normally.

## Uninstall

```bash
sudo rm /usr/local/bin/wl-paste
```

The real `/usr/bin/wl-paste` takes over automatically.

## License

MIT
