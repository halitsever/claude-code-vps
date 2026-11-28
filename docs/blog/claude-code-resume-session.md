---
title: "Claude Code Resume Session: --continue, --resume, /resume"
titleTemplate: false
description: "Resume a Claude Code session with claude --continue, claude --resume or /resume: names, session IDs, the picker, what carries over and where transcripts live."
date: 2026-11-28
faq:
  - q: "How do I resume my last Claude Code session?"
    a: "Run claude --continue in the same directory. It reopens the most recent session for that directory. claude --resume opens a picker of earlier sessions instead."
  - q: "How do I resume a Claude Code session by name?"
    a: "Name it with claude -n my-task at startup or /rename my-task during the session, then run claude --resume my-task. An exact match resumes directly; an ambiguous name opens the picker with the name as the search."
  - q: "Where does Claude Code store sessions?"
    a: "As JSONL transcripts in ~/.claude/projects/, one folder per working directory. They are kept for 30 days by default; cleanupPeriodDays in settings.json changes that."
  - q: "Why does claude --continue not find my session?"
    a: "Sessions are stored per directory, so start claude in the same folder. Sessions started with claude -p or the Agent SDK are left out of --continue and the picker; resume those by session ID."
---

# How to resume a Claude Code session

<p class="post-meta">Halit Sever · 28 November 2026</p>

Claude Code saves every conversation as you work, so closing the terminal, running `/clear` or losing an SSH connection does not throw the work away. This post covers the ways back in, what a resumed session keeps and loses, and where the transcripts are on disk. Everything here comes from Anthropic's [sessions docs](https://code.claude.com/docs/en/sessions) and `claude --help` on version 2.1.326.

## The short version

| Command | What it does |
| --- | --- |
| `claude --continue` (`-c`) | Reopens the most recent session in the current directory |
| `claude --resume` (`-r`) | Opens the session picker |
| `claude --resume <name>` | Resumes the session with that name |
| `claude --resume <session-id>` | Resumes that session, from any directory |
| `/resume` | Switches to another session from inside a running one |

Sessions belong to a project directory. If `claude --continue` opens the wrong thing or nothing at all, check that you started it in the same folder.

## Name sessions you will come back to

Unnamed sessions get a generated title from your first prompt, which works, but a name is easier to type:

```bash
claude -n auth-refactor          # name it at startup
/rename auth-refactor            # or rename it later, inside the session
claude --resume auth-refactor    # come back to it
```

An exact name match resumes directly, even from another worktree of the same repository. If the name matches more than one session, `claude --resume` opens the picker with it as the search term.

## The session picker

`claude --resume` with no argument, or `/resume` inside a session, opens the picker:

| Key | Action |
| --- | --- |
| Up / Down or `k` / `j` | Move between sessions |
| Enter | Resume the highlighted one |
| Space | Preview it |
| Ctrl+R | Rename it |
| `/` or typing | Search; a pull request URL finds the session that made it |
| Ctrl+A | Show sessions from every project on the machine |
| Ctrl+W | Show all worktrees of this repository |
| Ctrl+B | Only sessions from the current git branch |

## What comes back, and what does not

A resumed session restores the conversation: messages, tool calls and results. If it was compacted, it continues from the last summary. It keeps the model it was using, and from a terminal `--continue` or `--resume <id>` also restores the permission mode, with one exception: a session that was in bypass mode comes back in your normal starting mode, and you have to pass `--dangerously-skip-permissions` again.

Some things are not restored:

- A tool call that was still running when the process died is not rerun.
- Background Bash commands and monitors are not restarted. Background subagents that did not finish show up as a note in the transcript.
- Launch flags are not saved. Pass `--mcp-config`, `--plugin-dir`, `--add-dir`, `--settings` and `--allowedTools` again if you used them.

Resuming the same session in two terminals at once makes both write one transcript, and later one side's messages can go missing. To try something else without touching the original, fork it:

```bash
claude --continue --fork-session
```

Inside a session, `/branch` does the same.

## Sessions from scripts

Sessions started with `claude -p` or the Agent SDK stay out of the picker and out of `claude --continue`. You can still resume one by ID, and print mode can ask an old session a follow-up:

```bash
claude -p --resume <session-id> --output-format json "summarize what we changed" | jq -r '.result'
```

## Where sessions are stored

Transcripts are JSONL files at `~/.claude/projects/<project>/<session-id>.jsonl`, where `<project>` is the working directory path with non-alphanumeric characters replaced by `-`. The format is internal and changes between versions, so use `/export` or the script interfaces above rather than parsing the files.

They are kept for 30 days. To change that, set `cleanupPeriodDays` in [settings.json](/blog/claude-code-settings-json). `claude purge` deletes a project's transcripts sooner.

## On a server: resume or reattach

On a remote machine there are two different things people call "resuming":

- **Reattaching** to a Claude Code process that never stopped. If you started `claude` inside tmux and your SSH connection dropped, the agent kept working. Reconnect and run `tmux attach`; nothing needs resuming. [Claude Code over SSH](/blog/claude-code-ssh) covers this setup.
- **Resuming** a session whose process ended: the server rebooted, you exited, or you restarted to pick up a [new version](/blog/update-claude-code). That is `claude --continue` or `claude --resume`.

Because transcripts live in the server user's `~/.claude/projects/`, sessions started on the server can only be resumed on the server. claude-code-vps's config sync does not move them either: from `~/.claude` it captures only `settings.json`, the `hooks/` folder and the plugin list, never transcripts or credentials.

## FAQ

<Faq />

## Related

- [Claude Code over SSH](/blog/claude-code-ssh): sessions that survive a dropped connection
- [How to update Claude Code](/blog/update-claude-code): new versions start with the next session
- [Claude Code settings.json](/blog/claude-code-settings-json): `cleanupPeriodDays` and the other keys
- [Keeping config in sync](/guide/sync): what claude-code-vps copies between machines
