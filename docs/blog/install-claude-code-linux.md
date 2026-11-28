---
title: "How to Install Claude Code on Linux (Ubuntu, Debian, Arch)"
titleTemplate: false
description: "Install Claude Code on Linux with the native installer, apt, dnf or npm. Covers Ubuntu, Debian, Fedora, Alpine and Arch, PATH and headless login."
date: 2026-11-28
faq:
  - q: "Is there Claude Code for Linux?"
    a: "Yes. Anthropic lists Ubuntu 20.04+, Debian 10+ and Alpine Linux 3.19+ as supported, on x64 or ARM64 with 4 GB of RAM or more. The native installer, apt, dnf and apk packages and the npm package all work on Linux."
  - q: "Where does the native installer put Claude Code?"
    a: "The launcher is ~/.local/bin/claude, a symlink into ~/.local/share/claude/versions/. If your shell cannot find claude after installing, ~/.local/bin is not on your PATH yet."
  - q: "Can I install Claude Code on Arch Linux?"
    a: "Arch is not on Anthropic's supported list, but the native installer is a single Linux binary and the AUR has a community claude-code package. Anthropic does not maintain the AUR package."
  - q: "How do I log in to Claude Code on a server without a browser?"
    a: "Run claude, press c to copy the login URL, open it in a browser on any other device, sign in, and paste the code back at the Paste code here if prompted prompt."
---

# How to install Claude Code on Linux

<p class="post-meta">Halit Sever · 28 November 2026</p>

Claude Code runs natively on Linux. You can install it with one curl command, with your distribution's package manager, or with npm. This guide walks through each route, the PATH fix most people hit, and how to log in on a machine that has no browser. The commands come from [Anthropic's setup docs](https://code.claude.com/docs/en/setup), checked on 28 November 2026.

## Requirements

| | |
| --- | --- |
| Distributions | Ubuntu 20.04+, Debian 10+, Alpine Linux 3.19+ |
| Hardware | 4 GB RAM or more, x64 or ARM64 |
| Shell | Bash or Zsh |
| Account | Pro, Max, Ultra, Team, Enterprise or Console. The free claude.ai plan does not include Claude Code. |

Git is optional. ripgrep ships with Claude Code.

## Option 1: the native installer

This is the route Anthropic puts first, and the one that updates itself:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

The command prints nothing while it downloads. When it finishes, open a new terminal and check:

```bash
claude --version
claude doctor
```

`claude --version` prints a version number. `claude doctor` checks the install and your settings without starting a session.

### "claude: command not found"

The installer puts the launcher at `~/.local/bin/claude`, a symlink into `~/.local/share/claude/versions/`. If the shell cannot find it, that folder is not on your `PATH`:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Use `~/.zshrc` if your shell is Zsh.

Native installs check for updates on startup and while running, and apply them the next time you start Claude Code. `claude update` forces it.

## Option 2: apt on Ubuntu and Debian

Anthropic publishes signed apt, dnf and apk repositories. Each has a `stable` channel, which is usually about a week old and skips releases with major regressions, and a `latest` channel. For `stable` on Ubuntu or Debian:

```bash
sudo apt install curl gnupg
sudo install -d -m 0755 /etc/apt/keyrings
sudo curl -fsSL https://downloads.claude.ai/keys/claude-code.asc \
  -o /etc/apt/keyrings/claude-code.asc
echo "deb [signed-by=/etc/apt/keyrings/claude-code.asc] https://downloads.claude.ai/claude-code/apt/stable stable main" \
  | sudo tee /etc/apt/sources.list.d/claude-code.list
sudo apt update
sudo apt install claude-code
```

If `apt update` later fails with `NO_PUBKEY BAA929FF1A7ECACE`, the key did not download. Package-manager installs do not auto-update, so upgrade with `sudo apt update && sudo apt upgrade claude-code`.

## Option 3: dnf on Fedora and RHEL

```bash
sudo tee /etc/yum.repos.d/claude-code.repo <<'EOF'
[claude-code]
name=Claude Code
baseurl=https://downloads.claude.ai/claude-code/rpm/stable
enabled=1
gpgcheck=1
gpgkey=https://downloads.claude.ai/keys/claude-code.asc
EOF
sudo dnf install claude-code
```

dnf asks you to confirm the key on first install. The fingerprint should be `31DD DE24 DDFA B679 F42D 7BD2 BAA9 29FF 1A7E CACE`.

## Alpine and other musl systems

Alpine has no `bash` or `curl` by default, and the installer needs both:

```bash
apk add bash curl
curl -fsSL https://claude.ai/install.sh | bash
```

## Arch Linux

Arch is not on Anthropic's supported list. Two routes work in practice:

- The native installer above. It installs a Linux binary into your home folder and does not depend on the distribution's packages.
- The AUR package `claude-code`. It is maintained by the Arch community, not by Anthropic, so it updates when its maintainer updates it.

## Option 4: npm

```bash
npm install -g @anthropic-ai/claude-code@latest
```

The npm package needs Node.js 22 or later and installs the same native binary through a per-platform optional dependency. Anthropic warns against `sudo npm install -g`. Upgrade with the same command; `npm update -g` may not move you to the newest release.

## Logging in on a machine without a browser

Run `claude`. On a desktop it opens a browser window. On a server or over SSH:

1. Press `c` to copy the login URL, or select it in the terminal.
2. Open it in a browser on your laptop or phone and sign in.
3. If the browser shows a code, paste it at the `Paste code here if prompted` prompt.

On Linux the credentials end up in `~/.claude/.credentials.json` with file mode `0600`. An `ANTHROPIC_API_KEY` in the environment also works, and Claude Code asks once whether to use it. [Remote Control](/blog/claude-code-remote-control) is the exception: it only works with a claude.ai login.

## Installing it on a server in one go

If the Linux machine is a fresh Ubuntu VPS, [claude-code-vps](/guide/getting-started) does the install for you, together with a sudo user, key-only SSH, ufw, tmux, Docker, Chrome and an optional KDE desktop over RDP:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

It runs the native installer as your workstation user, so Claude Code lands in that user's `~/.local/bin` and updates itself. [What gets installed](/guide/what-it-installs) lists every step.

## FAQ

<Faq />

## Related

- [Claude Code over SSH](/blog/claude-code-ssh): a working setup once it is installed
- [Install Docker on Ubuntu Server](/blog/install-docker-ubuntu-server): the other tool most agents need
- [Run Claude Code on a remote server](/guide/claude-code): first login, tmux and notifications
- [Troubleshooting](/reference/troubleshooting): `claude` not found and other server problems
