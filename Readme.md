<p align="center">
  <img src="docs/public/logo.svg" height="80" width="80"/>
</p>

<h1 align="center">claude-vps</h1>

<p align="center">
One command turns a blank Ubuntu server into a remote Claude Code workstation:<br/>
KDE Plasma over RDP, hardened SSH, Docker, Chrome and my own KDE + Claude config.
</p>

<p align="center">
<a href="https://halitsever.github.io/claude-vps/">Documentation</a> ·
<a href="https://halitsever.github.io/claude-vps/tr/">Türkçe</a>
</p>

## Install

On a fresh Ubuntu 24.04+ server, as root:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-vps/main/install.sh | sudo bash
```

Then SSH in as the new user, run `tmux` and `claude`, or connect to the desktop with any RDP client on port `53389`.

## Keep the server in sync

```bash
claude-vps publish        # on your machine: capture KDE + Claude config, commit, push
claude-vps sync           # on the server: pull and apply
claude-vps autosync on    # or let the server pull every 30 minutes
```

What gets captured is listed in [`dotfiles/manifest.txt`](dotfiles/manifest.txt). Credentials are never part of it.

## Layout

| Path | |
| --- | --- |
| `install.sh` | bootstrap for `curl \| bash` |
| `bin/claude-vps` | the CLI |
| `lib/setup.sh` | the nine setup steps |
| `lib/dotfiles.sh` | capture, apply, sync |
| `dotfiles/home` | captured config, mirrored into `$HOME` |
| `docs/` | VitePress site, English and Turkish |

Not affiliated with Anthropic. Released under the [MIT License](LICENSE).
