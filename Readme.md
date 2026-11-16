<p align="center" class="logo-section">
<img src="docs/public/logo.svg" alt="Claude Code VPS logo" height="96" width="96"/>
<br/>
<img src="https://halitsever-api.vercel.app/api/repo-title?title=Claude%20Code%20VPS">

<p align="center">
Run Claude Code on a VPS. One command turns a blank Ubuntu server into a remote Claude Code workstation:<br>
KDE Plasma over RDP, hardened SSH, tmux, Docker, Chrome and your own KDE + Claude config.<br>
<br/>
<br/>
<img src="https://img.shields.io/github/sponsors/halitsever"/>
</p>
<p align="center">
<a align="center" href="https://halitsever.github.io/claude-code-vps/">Documentation</a> ·
<a href="https://halitsever.github.io/claude-code-vps/guide/claude-code-vps">VPS guide</a> ·
<a href="https://halitsever.github.io/claude-code-vps/es/">Español</a> ·
<a href="https://halitsever.github.io/claude-code-vps/de/">Deutsch</a> ·
<a href="https://halitsever.github.io/claude-code-vps/fr/">Français</a> ·
<a href="https://halitsever.github.io/claude-code-vps/pt/">Português</a> ·
<a href="https://halitsever.github.io/claude-code-vps/it/">Italiano</a> ·
<a href="https://halitsever.github.io/claude-code-vps/ru/">Русский</a> ·
<a href="https://halitsever.github.io/claude-code-vps/zh/">简体中文</a> ·
<a href="https://halitsever.github.io/claude-code-vps/ja/">日本語</a> ·
<a href="https://halitsever.github.io/claude-code-vps/ko/">한국어</a> ·
<a href="https://halitsever.github.io/claude-code-vps/tr/">Türkçe</a>
  </p>
</p>

<p align="center">
<img src="https://halitsever-api.vercel.app/api/details"/>
</p>

- [**One command setup**](https://halitsever.github.io/claude-code-vps/guide/getting-started) - base packages, sudo user, key-only SSH, ufw, KDE Plasma, xrdp, Docker, gh, Chrome, Claude Code and [claudegrid](https://github.com/halitsever/claudegrid)
- [**Step-by-step VPS guide**](https://halitsever.github.io/claude-code-vps/guide/claude-code-vps) - every step by hand, if you would rather not run a script
- [**Config sync**](https://halitsever.github.io/claude-code-vps/guide/sync) - `claude-vps publish` at home, `claude-vps sync` or autosync on the server
- [**Phone notifications**](https://halitsever.github.io/claude-code-vps/guide/claude-code) - a Notification hook that pushes "Claude is waiting" to ntfy.sh
- [**HaltOS**](https://github.com/halitsever/haltos) - an optional monochrome, terminal-style desktop on top of this setup, installed together with claude-code-vps in one command

<p align="center" >
<img src="https://halitsever-api.vercel.app/api/installation"/>
</p>

On a fresh Ubuntu 24.04+ server, as root:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Then SSH in as the new user, run `tmux` and `claude`, or connect to the desktop with any RDP client on port `53389`.

When a new version is released, update each server with:

```bash
sudo claude-vps update
```

Keep the server in sync with your own machine:

```bash
claude-vps publish        # on your machine: capture KDE + Claude config, commit, push
claude-vps sync           # on the server: pull and apply
claude-vps autosync on    # or let the server pull every 30 minutes
```

What gets captured is listed in [`dotfiles/manifest.txt`](dotfiles/manifest.txt). Credentials are never part of it.

<p align="center">
<a href="https://github.com/halitsever/claude-code-vps/issues"><img src="https://halitsever-api.vercel.app/api/issue"/></a>
</p>

<p align="center">
Found a bug or have an idea? Open an <a href="https://github.com/halitsever/claude-code-vps/issues">issue</a>.<br/>
Read the <a href=".github/CONTRIBUTING.md">contributing guide</a> before sending a pull request.<br/>
Not affiliated with Anthropic.
</p>

<p align="center">
<img src="https://halitsever-api.vercel.app/api/sponsor"/>
</p>

<p align="center">
<img src="https://halitsever-api.vercel.app/api/license"/>
</p>

<p align="center">
Released under the <a href="LICENSE">MIT License</a>.
</p>
