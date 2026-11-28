---
title: "Claude Code Statusline: Show Usage, Context and Git"
titleTemplate: false
description: "Set up a Claude Code statusline that shows context use, your 5-hour and weekly usage limits and the git branch: /statusline, settings.json and tested scripts."
date: 2026-11-28
faq:
  - q: "How do I add a status line to Claude Code?"
    a: "Run /statusline with a description of what you want, and Claude Code writes a script and updates your settings. Or add a statusLine block with type command and your script path to ~/.claude/settings.json yourself."
  - q: "Can the Claude Code statusline show my usage limits?"
    a: "Yes. On Pro, Max and Ultra plans the JSON the script receives has rate_limits.five_hour and rate_limits.seven_day with used_percentage and resets_at. The fields appear only after the first API response, so read them with a fallback."
  - q: "Does the status line use tokens?"
    a: "No. It runs locally as a shell command and does not consume API tokens."
  - q: "How often does the status line update?"
    a: "When the session starts, after each new assistant message, after /compact, when the permission mode or vim mode changes, and when a usage window resets. refreshInterval adds a timer on top. Updates are debounced by 300 ms."
---

# Claude Code statusline: show usage, context and the git branch

<p class="post-meta">Halit Sever · 28 November 2026</p>

Claude Code can run a command of yours and print its output in a row at the bottom of the screen. People use it for the git branch, the model, how full the context window is and, most often, how much of their usage limit is left. This post sets one up two ways and shows scripts I ran against sample input, based on Anthropic's [status line docs](https://code.claude.com/docs/en/statusline).

## The quick way: /statusline

Inside a session, describe what you want:

```text
/statusline show model name and context percentage with a progress bar
```

Claude Code writes a script into `~/.claude/` and points your settings at it. To remove it later, `/statusline delete` (or `clear`, or `remove it`) works, as does deleting the `statusLine` key yourself.

## The manual way: settings.json

The status line is a `statusLine` block in `~/.claude/settings.json`, or in a project's settings file:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  }
}
```

`command` runs in a shell, so it can be a script path or an inline command. Claude Code sends a JSON object about the session on stdin and shows whatever your command prints on stdout. Each line you print becomes a row, ANSI colours work, and so do OSC 8 links in terminals that support them. It runs locally and costs no tokens.

Two optional keys: `refreshInterval` re-runs the command every N seconds (minimum 1), useful for a clock; `hideVimModeIndicator` hides the built-in `-- INSERT --` when your script prints the vim mode itself.

## The one claude-code-vps ships

The server settings in claude-code-vps use an inline command. It needs `jq`, which setup installs:

```bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name')
pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
out="$model | ${cwd##*/}"
br=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
[ -n "$br" ] && out="$out | $br"
[ -n "$pct" ] && out="$out | ctx $(printf '%.0f' "$pct")%"
echo "$out"
```

Fed a sample input for a repository on branch `feature/login` with 41.7% context used, it prints:

```text
Opus | repo | feature/login | ctx 42%
```

Outside a git repository and before the first response, the branch and context parts drop out and it prints `Opus | tmp`. `--no-optional-locks` keeps the `git` call from taking locks that would get in the way of commands Claude is running in the same repository.

## Show usage limits

The most searched version of this is a status line that shows usage. On claude.ai Pro, Max and Ultra plans the input includes:

| Field | Meaning |
| --- | --- |
| `rate_limits.five_hour.used_percentage` | Share of the 5-hour limit used, 0 to 100 |
| `rate_limits.five_hour.resets_at` | When that window resets, in Unix seconds |
| `rate_limits.seven_day.used_percentage` | Share of the 7-day limit used |
| `rate_limits.seven_day.resets_at` | When the weekly window resets |

They appear only after the session's first API response, and each window can be missing on its own, so every read needs a fallback. This script prints context and both limits:

```bash
#!/bin/bash
input=$(cat)
model=$(jq -r '.model.display_name' <<<"$input")
ctx=$(jq -r '.context_window.used_percentage // 0' <<<"$input" | cut -d. -f1)
five=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
week=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")
reset=$(jq -r '.rate_limits.five_hour.resets_at // empty' <<<"$input")
out="$model | ctx ${ctx}%"
[ -n "$five" ] && out="$out | 5h $(printf '%.0f' "$five")%"
[ -n "$reset" ] && out="$out (resets $(date -d "@$reset" +%H:%M))"
[ -n "$week" ] && out="$out | 7d $(printf '%.0f' "$week")%"
echo "$out"
```

With sample values it prints `Opus | ctx 12% | 5h 37% (resets 11:06) | 7d 8%`, and with no usage data yet just `Sonnet | ctx 0%`. `date -d @...` is GNU date, which Linux servers have. On macOS use `date -r "$reset" +%H:%M`.

Save it as `~/.claude/statusline.sh`, run `chmod +x` on it and point `command` at it. Claude Code reloads settings on save.

## Other fields worth knowing

The input carries much more than the examples use. A few that are handy:

- `cost.total_cost_usd`: an estimate computed client-side at list price. It can differ from your bill.
- `context_window.context_window_size` and `remaining_percentage`
- `workspace.git_worktree`: the worktree name when you are inside a linked worktree
- `session_name`: the name from `--name` or `/rename`
- `pr.number`, `pr.url` and `pr.review_state` for the current branch's pull request
- `effort.level` and `vim.mode`

The docs list every field. Pipe a sample into your script, as above, before you rely on it.

## When it updates

The command runs when a session starts or resumes, after each new assistant message, after `/compact`, when the permission mode or vim mode changes, and when a usage window reaches its `resets_at`. Updates are debounced by 300 ms, and a new update cancels a run that is still going, so keep the script fast. When the session sits idle these events stop, which is what `refreshInterval` is for.

To fit the terminal, read `$COLUMNS` and keep each line at least four columns narrower than it.

## On a server

Over SSH and inside tmux the status line is the cheapest way to see which session you are looking at, which is why the claude-code-vps one leads with the folder and branch. If you sync config from your own machine with `claude-vps publish`, your status line goes to the server with the rest of `~/.claude/settings.json`; scripts in `~/.claude/` outside `hooks/` do not, so an inline command or a script under `hooks/` travels more easily.

## FAQ

<Faq />

## Related

- [Claude Code settings.json](/blog/claude-code-settings-json): the files a `statusLine` block can live in
- [Claude Code notifications](/blog/claude-code-notifications): the hook that ships next to this status line
- [Keeping config in sync](/guide/sync): how settings reach the server
- [Run Claude Code on a remote server](/guide/claude-code): the full server setup
