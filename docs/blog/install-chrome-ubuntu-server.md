---
title: "Install Google Chrome on Ubuntu 24.04 and Ubuntu Server"
titleTemplate: false
description: "Install Google Chrome on Ubuntu 24.04 or Ubuntu Server from Google's apt repository or the .deb, run it headless, and use it with Claude Code."
date: 2026-11-28
faq:
  - q: "Is Google Chrome in Ubuntu's own repositories?"
    a: "No. Chrome comes from Google's apt repository at dl.google.com. Ubuntu's chromium-browser package installs Chromium as a snap, which is a different browser build."
  - q: "Can I install Chrome on Ubuntu Server without a desktop?"
    a: "Yes. The google-chrome-stable package installs on a server without a desktop and runs with --headless. A desktop is only needed when you want to see and click the browser."
  - q: "Is there Google Chrome for ARM64 Linux?"
    a: "Google's apt repository lists google-chrome-stable for both amd64 and arm64, checked on 28 November 2026. Older guides that say Chrome has no ARM64 Linux build are out of date."
  - q: "How do I update Chrome on Ubuntu?"
    a: "Through apt. Installing the package adds or uses Google's repository, so sudo apt update && sudo apt upgrade picks up new Chrome versions."
---

# Install Google Chrome on Ubuntu 24.04 and Ubuntu Server

<p class="post-meta">Halit Sever · 28 November 2026</p>

Google Chrome is not in Ubuntu's archive, and Ubuntu's `chromium-browser` package installs Chromium as a snap. To get Chrome itself you add Google's apt repository or install Google's `.deb`. Both work the same on Ubuntu 24.04 desktop and on a server with no desktop at all.

claude-code-vps installs Chrome on every server, for the KDE desktop you reach over RDP and for Claude Code's browser tools. This post shows the commands it runs and the two other common ways.

## Option 1: Google's apt repository (what claude-code-vps runs)

From the `apps` step in [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh):

```bash
sudo install -d -m 755 /etc/apt/keyrings
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
  | sudo gpg --dearmor --yes -o /etc/apt/keyrings/google-chrome.gpg

sudo tee /etc/apt/sources.list.d/google-chrome.sources <<'EOF'
Types: deb
URIs: https://dl.google.com/linux/chrome/deb/
Suites: stable
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/google-chrome.gpg
EOF

sudo apt-get update
sudo apt-get install -y google-chrome-stable
```

This uses the deb822 `.sources` format that Ubuntu 24.04 uses for its own sources, and a key in `/etc/apt/keyrings` that only this repository trusts. Updates then arrive with `apt upgrade` like any other package.

## Option 2: the .deb from Google

```bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
```

`apt install ./file.deb` pulls in the dependencies that `dpkg -i` would leave missing. The package also adds Google's repository, so later versions come in through `apt upgrade`.

## ARM64 servers

Google's repository index lists `google-chrome-stable` for both `amd64` and `arm64`, checked on 28 November 2026. On an ARM64 server, set `Architectures: arm64` in the source file, or download `google-chrome-stable_current_arm64.deb`.

claude-code-vps currently installs Chrome only on amd64 and skips it on arm64 with the message "Chrome has no arm64 build". That message predates Google's ARM64 packages.

## Check it

```bash
google-chrome --version
```

## Running Chrome headless

On a server without a desktop, Chrome runs in headless mode:

```bash
google-chrome --headless --screenshot=/tmp/page.png --window-size=1280,800 https://example.com
google-chrome --headless --dump-dom https://example.com > page.html
```

For tools that drive Chrome over the DevTools protocol, such as Playwright or Puppeteer, start it with `--remote-debugging-port=9222`, or let the tool start Chrome itself by pointing it at `/usr/bin/google-chrome`.

## Chrome for Claude Code on a server

Claude Code's [Chrome integration](https://code.claude.com/docs/en/chrome) works with Google Chrome through the Claude in Chrome extension. Start Claude Code with `claude --chrome`, or run `/chrome` inside a session. It needs a `/login` sign-in, not an API key.

On Linux, Claude Code writes a native messaging host file to `~/.config/google-chrome/NativeMessagingHosts/com.anthropic.claude_code_browser_extension.json`, and Chrome reads it on startup. If the extension is not detected the first time, restart Chrome.

The extension runs in a normal Chrome window, so on a server you need a desktop to open it. On claude-code-vps that is the KDE Plasma session over RDP: connect with any RDP client to port 53389, open Chrome there, install the extension, and Claude Code running in Konsole or in tmux as the same user can use it. See [Remote desktop](/guide/remote-desktop).

## Removing Chrome

```bash
sudo apt remove google-chrome-stable
sudo rm /etc/apt/sources.list.d/google-chrome.sources /etc/apt/keyrings/google-chrome.gpg
```

## FAQ

<Faq />

## Related

- [Install Docker on Ubuntu Server](/blog/install-docker-ubuntu-server): the rest of the `apps` step
- [Install Claude Code on Linux](/blog/install-claude-code-linux): native installer, apt and npm
- [Remote desktop](/guide/remote-desktop): reaching the server's desktop from any OS
- [What gets installed](/guide/what-it-installs): every setup step
