---
description: "Keep your KDE Plasma and Claude Code settings in sync between your own machine and your VPS with claude-vps publish, sync and autosync."
---

# Keeping config in sync

The repo is the source of truth for how the server looks and behaves. You change things on your own machine, and the server catches up.

```text
 your machine                  GitHub                     server
 ───────────                   ──────                     ──────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (or autosync, every 30 min)
```

## On your machine

Clone the repo once and put the CLI on your PATH:

```bash
git clone https://github.com/halitsever/claude-code-vps.git ~/claude-code-vps
ln -s ~/claude-code-vps/bin/claude-vps ~/.local/bin/claude-vps
```

After you change a panel, a shortcut, your Konsole profile or `~/.claude/settings.json`:

```bash
claude-vps publish
```

That runs `capture`, commits `dotfiles/` and pushes. If you would rather look at the diff first:

```bash
claude-vps capture
git -C ~/claude-code-vps diff
```

## On the server

```bash
claude-vps sync
```

It pulls and runs `apply`. Every file it is about to overwrite is copied to `~/.local/state/claude-vps/backup-<timestamp>/` first, and files that did not change are left alone.

Or let it happen by itself:

```bash
claude-vps autosync on     # systemd user timer, every 30 minutes
claude-vps autosync        # show when it runs next
claude-vps autosync off
```

### Hooks after apply

When `apply` changes files, it then runs every executable in `~/.config/claude-vps/post-apply.d/`, in name order. Tools that layer their own settings on top of your config use this to put them back after a sync, for example [HaltOS](https://github.com/halitsever/haltos). A failing hook prints a warning and does not stop the sync.

::: warning Plasma and live sessions
Plasma keeps some settings in memory and writes them back when you log out. If a sync lands while you are connected over RDP, log out and back in to see it, and avoid changing the same setting on the server in the meantime.
:::

## What gets captured

The list lives in [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/manifest.txt). A trailing slash means the whole folder.

| Area | Files |
| --- | --- |
| Plasma | `kdeglobals`, `kwinrc`, `kglobalshortcutsrc`, `plasmarc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kdedefaults/`, power and notification settings |
| Apps | `dolphinrc`, `konsolerc`, `katerc`, `~/.local/share/konsole/`, GTK theme settings, `mimeapps.list` |
| Look | `~/.local/share/color-schemes/`, `plasma/`, `aurorae/` when they exist |
| Claude | `~/.claude/settings.json`, `hooks/` |
| Shell | `.tmux.conf`, `.xsession` |

Add a line to the manifest to track something else. Paths that do not exist on your machine are skipped.

## What never gets captured

Your home path is replaced with `@HOME@` so the files work for any username, and sections that hold recent files or history are dropped. Credentials are simply not on the list: `~/.claude/.credentials.json`, `~/.claude/ntfy-topic`, SSH keys, `kwalletrc`, browser profiles. Binary files such as photos, wallpapers and icons are skipped with a warning even inside a listed folder, since they cannot be scrubbed. Keep it that way, the repo is public.
