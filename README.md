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

A thin `wl-paste` wrapper that delegates everything to the real `/usr/bin/wl-paste` and only intercepts the BMP→PNG conversion case:

- When `wl-paste -l` is called and the clipboard has `image/bmp` but not `image/png`, it appends `image/png` to the output — this is what makes Claude Code's image detection succeed
- When `wl-paste --type image/png` is called and the real `wl-paste` can't provide PNG, it grabs the BMP and converts it to PNG via ImageMagick

Text paste, `wl-copy`, other MIME types, all flags — everything else hits the real `wl-paste` unchanged.

Based on the approach by [@gptool](https://github.com/anthropics/claude-code/issues/3150).

## Requirements

- WSL 2 (Ubuntu or other distro)
- [ImageMagick](https://imagemagick.org/) (`sudo apt install imagemagick`)
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) (`sudo apt install wl-clipboard`)
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

Regular text copy/paste continues to work normally — the wrapper passes everything through unchanged.

## Uninstall

```bash
sudo rm /usr/local/bin/wl-paste
```

The real `/usr/bin/wl-paste` takes over automatically.

## How It Works

```
Alt+V in Claude Code
  → calls wl-paste --list-types
  → wrapper delegates to real wl-paste
  → if clipboard has BMP but not PNG, appends "image/png" to output
  → Claude Code sees image/png is available

Claude Code requests image
  → calls wl-paste --type image/png
  → wrapper tries real wl-paste first
  → if no PNG available, grabs BMP and pipes through ImageMagick convert
  → returns PNG data to Claude Code
```

## License

MIT
