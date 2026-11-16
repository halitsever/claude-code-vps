<p align="center">
  <img src="docs/public/logo.svg" height="80" width="80"/>
</p>

<h1 align="center">Claude Code VPS</h1>

<p align="center">
Run Claude Code on a VPS. One command turns a blank Ubuntu server into a remote Claude Code workstation:<br/>
KDE Plasma over RDP, hardened SSH, Docker, Chrome and my own KDE + Claude config.
</p>

<p align="center">
<a href="https://halitsever.github.io/claude-code-vps/guide/claude-code-vps">Step-by-step VPS guide</a> ·
<a href="https://halitsever.github.io/claude-code-vps/">Documentation</a> ·
<a href="https://halitsever.github.io/claude-code-vps/fr/">Français</a> ·
<a href="https://halitsever.github.io/claude-code-vps/it/">Italiano</a> ·
<a href="https://halitsever.github.io/claude-code-vps/tr/">Türkçe</a>
</p>

## Install

On a fresh Ubuntu 24.04+ server, as root:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Prefer to do it by hand? The [Claude Code on a VPS guide](https://halitsever.github.io/claude-code-vps/guide/claude-code-vps) walks through every step.

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
| `docs/` | VitePress site in English, French, Italian and Turkish |

Not affiliated with Anthropic. Released under the [MIT License](LICENSE).
