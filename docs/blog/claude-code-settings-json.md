---
title: "Claude Code settings.json: Files, Precedence, Examples"
titleTemplate: false
description: "Where Claude Code settings.json lives, how user, project and local files merge, which one wins, and a real server settings file explained key by key."
date: 2026-11-28
faq:
  - q: "Where is the Claude Code settings.json file?"
    a: "Your personal one is ~/.claude/settings.json and applies to every project. A project can have .claude/settings.json, shared through git, and .claude/settings.local.json for your own overrides. Installing Claude Code creates none of them."
  - q: "What is settings.local.json in Claude Code?"
    a: "Your personal settings for one project. It overrides the shared .claude/settings.json, and Claude Code saves permission approvals there when you choose Yes, and don't ask again. When Claude Code creates it, it keeps the file out of git."
  - q: "Which Claude Code settings file wins?"
    a: "From highest to lowest: managed settings, --settings on the command line, .claude/settings.local.json, .claude/settings.json, then ~/.claude/settings.json. Lists such as permissions.allow are merged across files instead of replaced."
  - q: "Do I need to restart Claude Code after editing settings.json?"
    a: "Usually not. Claude Code watches the files and applies most edits, including permissions and hooks, to the running session. A few keys such as model and effortLevel are read only at startup."
---

# Claude Code settings.json, explained

<p class="post-meta">Halit Sever · 28 November 2026</p>

Most Claude Code configuration lives in JSON files called `settings.json`: permissions, hooks, the status line, environment variables, the model, the update channel. There is more than one, and which one a key comes from decides who it affects. This post covers the files, how they combine, and a real settings file from the claude-code-vps repository, using Anthropic's [settings docs](https://code.claude.com/docs/en/settings).

## The four files

| Scope | File | Applies to |
| --- | --- | --- |
| User | `~/.claude/settings.json` | You, in every project on this machine |
| Shared project | `.claude/settings.json` | Everyone working in the project, if you commit it |
| Project local | `.claude/settings.local.json` | You, in one project |
| Managed | `managed-settings.json` and other managed sources | Everyone your organization deploys it to |

Installing Claude Code creates none of these. Claude Code writes `~/.claude/settings.json` when you save a personal setting such as the theme, and `.claude/settings.local.json` when you pick "Yes, and don't ask again" on a permission prompt. Inside a git repository the local file sits at the repository root, and the first time Claude Code writes it, it adds the file to your global git excludes so it stays out of commits. If you create it by hand, add it to `.gitignore` yourself.

There is also `~/.claude.json`, which Claude Code writes for itself: account details, MCP server configuration, per-project trust decisions. You do not need to edit it.

## Which file wins

When two files set the same key, the higher one wins:

1. Managed settings
2. `--settings` on the command line, for that session
3. `.claude/settings.local.json`
4. `.claude/settings.json`
5. `~/.claude/settings.json`

Lists merge instead of overriding: a `permissions.allow` list in your user file and another in the project file both apply. Environment variables are not a level in this stack; each variable and settings key pair has its own rule, and the [env vars reference](https://code.claude.com/docs/en/env-vars) says which wins.

To try a value for one session without saving it:

```bash
claude --settings '{"model": "claude-opus-5-5"}'
```

## Editing it

Settings files are strict JSON. A `//` comment or a trailing comma is a syntax error, and Claude Code reports a Settings Error at the next start. Adding the schema line gives you autocomplete and validation in editors that support JSON Schema:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json"
}
```

Claude Code watches the files and applies most edits to a running session, including `permissions` and `hooks`. A few keys, such as `model` and `effortLevel`, are read only at startup; use `/model` and `/effort` to change those mid-session. After an edit, `/status` shows which settings files loaded, and `claude doctor` lists entries it rejected.

`/config` opens a menu for a short list of personal options and saves them to the right file for you.

## A real example

This is the user settings file claude-code-vps puts on every server, from [`dotfiles/home/.claude/settings.json`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/home/.claude/settings.json). The status line command is shortened here:

```json
{
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true,
    "frontend-design@anthropic-plugin-directory": true
  },
  "tui": "fullscreen",
  "theme": "dark",
  "statusLine": {
    "type": "command",
    "command": "input=$(cat); ... echo \"$out\""
  },
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  },
  "permissions": {
    "allow": ["Bash(gh pr merge *)", "Bash(gh repo edit *)"]
  },
  "attribution": { "commit": "", "pr": "" }
}
```

Key by key:

- **`enabledPlugins`** turns on plugins by `name@marketplace`. The real file lists four.
- **`tui`** and **`theme`**: the fullscreen terminal UI and the dark theme.
- **`statusLine`** runs a command and shows its output under the prompt. [Claude Code statusline](/blog/claude-code-statusline) covers it in detail.
- **`hooks`** runs `notify.sh` on every `Notification` event, which pushes "Claude is waiting" to a phone. See [Claude Code notifications](/blog/claude-code-notifications).
- **`permissions.allow`** pre-approves two `gh` commands. See [How to make Claude Code stop asking for permission](/blog/claude-code-stop-asking-permission).
- **`attribution`** with empty strings leaves out the `Co-Authored-By` trailer Claude Code adds to commits by default and the line it adds to pull request descriptions. On version 2.1.281 and later, `"attribution": false` hides all of it.

The file in the repository also sets `skipWorkflowUsageWarning`. It is the owner's own config, synced to each server by `claude-vps sync`, so treat it as an example to copy from, not a recommended default.

## Keys people often look for

| Key | What it does |
| --- | --- |
| `model` | Default model for new sessions |
| `permissions.allow`, `ask`, `deny` | Permission rules |
| `permissions.defaultMode` | Starting permission mode, such as `acceptEdits` |
| `env` | Environment variables for every session, such as `DISABLE_AUTOUPDATER` |
| `hooks` | Commands that run on events |
| `statusLine` | The status line command |
| `autoUpdatesChannel` | `latest` or `stable`; see [How to update Claude Code](/blog/update-claude-code) |
| `cleanupPeriodDays` | Days to keep session transcripts, 30 by default |

The [settings reference](https://code.claude.com/docs/en/settings-reference) lists every key with its scope. Some keys only work from certain files: for example, `"defaultMode": "auto"` does not take effect from a project's `.claude/settings.json`, only from your user file.

## Keeping one settings.json on several machines

If you run Claude Code on a laptop and a server, the user file is the one to keep in step. claude-code-vps does it through git: `claude-vps publish` on your machine captures `~/.claude/settings.json` and `~/.claude/hooks/` into a repository, and `claude-vps sync` on the server applies them. Credentials are never captured, and your home path is replaced with a placeholder so the file works for any username. [Keeping config in sync](/guide/sync) has the details.

## FAQ

<Faq />

## Related

- [How to make Claude Code stop asking for permission](/blog/claude-code-stop-asking-permission): permission rules in practice
- [Claude Code statusline](/blog/claude-code-statusline): the `statusLine` block
- [How to update Claude Code](/blog/update-claude-code): update channel and pinning
- [Keeping config in sync](/guide/sync): one settings file across machines
