# Changelog

Servers pick up a new version with `sudo claude-vps update`.

## Unreleased

- `capture` records your public Claude Code plugins (Anthropic directory and official marketplace) in `dotfiles/plugins.txt`, and `apply` installs the ones a server is missing. Your own skills stay out.

## 0.3.0

- [claudegrid](https://github.com/halitsever/claudegrid) comes preinstalled from its latest `.deb`, with its Konsole profile, app menu entry and `qdbus` for Konsole split panes.
- Node.js 20+ on every supported release. Ubuntu 24.04 gets Node 22 from NodeSource, since its own nodejs is 18.

## 0.2.0

- `sudo claude-vps update` pulls the latest version and re-runs setup, keeping the options from the first install (`/etc/claude-vps.conf`).
- `claude-vps sync` tells you when a new version arrived.
- `claude-vps release X.Y.Z` tags a release; GitHub publishes it with the notes below.
- Re-running setup no longer restarts xrdp or reloads SSH when nothing changed, so open RDP sessions stay up.
- Machines that run `capture` are marked as config sources, and `apply` will not roll their live settings back without `--force`.
- An empty `~/.claude/CLAUDE.md` is created on new servers instead of shipping personal instructions.
- Docs in 11 languages.

## 0.1.0

- First version: one-command setup for Ubuntu 24.04+ with Claude Code, KDE Plasma over xrdp, key-only SSH, ufw, Docker, gh and Chrome.
- `capture`, `publish`, `sync`, `apply` and `autosync` keep KDE and Claude config in sync through the repo.
