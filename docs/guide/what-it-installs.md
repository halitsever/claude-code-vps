---
description: "Every step claude-vps runs on your Ubuntu server: packages, swap, SSH hardening, ufw, KDE Plasma, xrdp, Docker, Chrome, Claude Code and your dotfiles."
---

# What gets installed

`claude-vps setup` runs nine steps in order. Each one is a plain bash function in [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh), so you can read exactly what runs on your box. Skip any of them with `--skip`, or run a few with `--only`.

## 1. base

- `apt upgrade` on everything
- `git curl jq ripgrep fd-find tmux htop build-essential python3` and friends
- Node.js 20 or newer. On Ubuntu 24.04, where apt only has 18, it comes from the NodeSource repo
- `unattended-upgrades` enabled, so security patches land without you
- a 4 GB swapfile when the box has no swap and less than 8 GB RAM, which keeps Plasma and a few agents from hitting the OOM killer
- the timezone, if you pass `--timezone`

## 2. user

Creates your workstation user, adds it to `sudo`, and copies `/root/.ssh/authorized_keys` to it if it has none. The password you pick is what you type at the RDP login screen.

## 3. ssh

Writes `/etc/ssh/sshd_config.d/10-claude-vps.conf`:

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd keeps the first value it reads, which is why the file name starts with `10-`: it wins over the `50-cloud-init.conf` most cloud images ship. The step is skipped with a warning when your user has no SSH key yet, so you never lock yourself out.

## 4. firewall

`ufw` with OpenSSH and the RDP port allowed, everything else closed. Pass `--rdp-private` to keep RDP closed and reach it through an SSH tunnel instead.

## 5. desktop

`kde-plasma-desktop` plus the X11 session (`plasma-session-x11`, `kwin-x11` on Ubuntu 25.10+), Konsole, Dolphin, Kate, Spectacle, Noto and JetBrains Mono fonts. SDDM is disabled and the default target set to `multi-user`: nobody sits in front of a server, so it boots straight to a console and Plasma only starts when you connect.

::: info Why X11
xrdp drives an Xorg session. Plasma 6 still ships an X11 session on Ubuntu 24.04 to 26.04, and it is what I use day to day over RDP.
:::

## 6. rdp

- `xrdp` and `xorgxrdp`, listening on port **53389** (change with `--rdp-port`)
- `~/.xsession` that starts `startplasma-x11` with the right `XDG_*` variables
- a polkit rule that stops the "authentication is required to create a color managed device" prompt you otherwise get on every login

## 7. apps

- Docker (`docker.io`, compose v2, buildx), your user in the `docker` group
- GitHub CLI (`gh`)
- Google Chrome from Google's apt repo (amd64 only), handy when Claude needs a real browser

## 8. claude

- Claude Code through the official native installer, into `~/.local/bin/claude`. It updates itself
- [claudegrid](https://github.com/halitsever/claudegrid) from its latest `.deb` release, to open a grid of Claude Code agents in Konsole or tmux with one command. It also adds a Konsole profile and an app menu entry
- your ntfy.sh topic in `~/.claude/ntfy-topic` if you give one, which the notify hook reads

## 9. dotfiles

Hands `/opt/claude-vps` to your user, links `claude-vps` into `/usr/local/bin`, and runs `claude-vps apply` as you. That writes everything under `dotfiles/home` into your home directory: KDE config, Konsole profiles, `~/.claude/settings.json`, `CLAUDE.md`, hooks, `.tmux.conf`. It also installs the public Claude Code plugins listed in `dotfiles/plugins.txt`.

## Running steps again

Every step checks what is already there, so re-running is safe:

```bash
sudo claude-vps setup --only desktop,rdp     # e.g. after a release upgrade
sudo claude-vps setup --skip apps            # everything except Docker and Chrome
sudo claude-vps setup --no-desktop           # terminal-only box
```
