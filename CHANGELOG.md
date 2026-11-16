# Changelog

Servers pick up a new version with `sudo claude-vps update`.

## Unreleased

- Paths listed in `~/.config/claude-vps/local-only` are never touched by `apply` and never captured (the repo copy is kept), for per-machine settings that should not be synced.
- Servers allow `gh pr merge` and `gh repo edit` in Claude Code without a prompt.
- `capture` skips binary files (photos, wallpapers, icons) with a warning, and `wallpapers/` is no longer in the manifest, so a private image can never reach the public repo.
- `apply` runs the executables in `~/.config/claude-vps/post-apply.d/` after it changes files, so layers such as [HaltOS](https://github.com/halitsever/haltos) survive a sync.
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
