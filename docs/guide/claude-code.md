---
title: "Run Claude Code on a remote server"
description: "Run Claude Code on a remote server: log in on a headless box, keep agents running in tmux after SSH disconnects and get phone notifications through ntfy.sh."
---

# Working with Claude Code on your remote server

After setup, Claude Code lives on the server and you reach it over SSH. This page covers logging in without a browser on the box, keeping agents alive in tmux and getting a ping on your phone when Claude needs you.

## First login

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Claude Code prints a login link. Open it in your own browser, approve, and paste the code back. The credentials stay in `~/.claude` on the server.

Prefer an API key? Export it before starting:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

Claude Code works with an API key, but [Remote Control](https://code.claude.com/docs/en/remote-control) (driving the session from the Claude app or claude.ai) needs the claude.ai login. [Remote Control vs a server](/blog/claude-code-remote-control) covers the setup.

## Keep it running with tmux

An agent that works for an hour should not die because your laptop went to sleep. Run it inside tmux and detach:

| | |
| --- | --- |
| Detach | `Ctrl-b` then `d` |
| Reattach | `tmux attach -t claude` |
| New window | `Ctrl-b` then `c` |
| List sessions | `tmux ls` |

The shipped `.tmux.conf` turns on mouse support, a 50k line scrollback and 256 colors.

You can also open Konsole on the desktop and run `tmux attach -t claude` there. Same session, bigger screen.

## Phone notifications

`~/.claude/settings.json` registers a `Notification` hook, `~/.claude/hooks/notify.sh`, which posts to [ntfy.sh](https://ntfy.sh) whenever Claude is waiting for you.

1. Install the ntfy app on your phone and subscribe to a topic nobody will guess, e.g. `claude-7f3k9q2m`.
2. Put the same topic on the server:

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   Or pass `--ntfy-topic` during setup.

The topic is a secret: anyone who knows it can read your notifications. That is why it lives in its own file and is never captured into the repo.

## What comes preconfigured

From `dotfiles/home/.claude`:

- **`settings.json`**: dark theme, fullscreen TUI, a status line with model, folder, git branch and context usage, the plugins I use and the notify hook
- **`CLAUDE.md`**: an empty file for your own global instructions. It is only created when missing, so what you write there is never overwritten
- **`hooks/notify.sh`**: the ntfy hook above

From `dotfiles/plugins.txt`, the public plugins installed on your machine: `capture` lists everything from the Anthropic directory and the official marketplace, and `apply` installs what the server is missing. Skills you wrote yourself are left out; the ones synced from claude.ai show up once you log in.

Change any of them on your own machine and run `claude-vps publish`. See [Keeping config in sync](/guide/sync).

## Updating Claude Code

The native install updates itself in the background. To force it:

```bash
claude update
```
