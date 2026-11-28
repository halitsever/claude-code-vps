---
title: "Claude Code Notifications: Get a Push When It Needs You"
titleTemplate: false
description: "Set up Claude Code notifications with a Notification hook: a phone push through ntfy.sh, a desktop alert or a terminal bell, and when each one fires."
date: 2026-11-28
faq:
  - q: "When does the Claude Code Notification hook fire?"
    a: "For permission prompts after they have waited about six seconds, and for idle prompts about 60 seconds after Claude finishes responding if you have not typed since. Other types cover logins, MCP dialogs and background agents."
  - q: "How do I get a Claude Code notification when it is done?"
    a: "The idle_prompt notification fires about a minute after Claude finishes and you have not typed. For an alert the moment a turn ends, use a Stop hook instead of a Notification hook."
  - q: "Why does notify-send not work on my server?"
    a: "notify-send needs a desktop notification daemon, which headless servers and SSH sessions do not have. Use a push service such as ntfy for remote machines."
  - q: "Is an ntfy.sh topic private?"
    a: "No. ntfy.sh has no sign-up, so the topic name works like a password. Anyone who knows it can read and send messages, so pick a long random name and keep it out of git."
---

# Claude Code notifications on your phone, desktop or terminal

<p class="post-meta">Halit Sever · 28 November 2026</p>

A long Claude Code task often stops halfway for a permission prompt, and nobody is looking at the terminal. A Notification hook fixes that: Claude Code runs a command whenever it wants your attention, and the command can send a push to your phone, show a desktop alert or play a sound.

This post shows the hook claude-code-vps ships, which posts to [ntfy.sh](https://ntfy.sh), then the desktop and sound versions. Event names and timings come from the [hooks reference](https://code.claude.com/docs/en/hooks#notification), checked on 28 November 2026.

## When Claude Code sends a notification

The `Notification` event has a `notification_type`, and you can match on it. The two you will see most:

| Type | When it fires |
| --- | --- |
| `permission_prompt` | Claude needs you to approve a tool use, and the prompt has waited about six seconds |
| `idle_prompt` | Claude finished about 60 seconds ago and you have not typed since |

Others cover a completed login (`auth_success`), MCP forms and URL requests (`elicitation_dialog`, `elicitation_url_dialog`) and background sessions in agent view (`agent_needs_input`, `agent_completed`). Leave the matcher out to run your hook for all of them.

The hook receives JSON on stdin with `message`, an optional `title` and `notification_type`:

```json
{
  "hook_event_name": "Notification",
  "message": "Claude needs your permission",
  "notification_type": "permission_prompt"
}
```

Notification hooks cannot block or change anything. They exist for side effects.

## A phone push with ntfy

This is the hook from [`dotfiles/home/.claude`](https://github.com/halitsever/claude-code-vps/tree/main/dotfiles/home/.claude) in claude-code-vps. In `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          { "type": "command", "command": "~/.claude/hooks/notify.sh" }
        ]
      }
    ]
  }
}
```

And `~/.claude/hooks/notify.sh`:

```bash
#!/usr/bin/env bash
# Pushes Claude's "waiting for you" notices to the phone via ntfy.
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude seni bekliyor"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
```

A few choices in that script are worth copying:

- **The topic lives in its own file**, `~/.claude/ntfy-topic` with mode 600, so the settings file can go into git without the secret. ntfy's docs say it plainly: with no sign-up, "the topic is essentially a password."
- **No topic file, no push.** The script exits quietly, so the same settings work on machines where you do not want pushes.
- **`-m 5` and `|| true`** keep a slow or failed request from holding up Claude Code.

To set it up:

1. Install the ntfy app on Android or iOS and subscribe to a topic nobody will guess, such as `claude-7f3k9q2m`.
2. On the machine that runs Claude Code: `echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic`
3. Make the script executable with `chmod +x ~/.claude/hooks/notify.sh`, and install `jq` if it is missing.
4. Run `/hooks` inside Claude Code to check the hook is listed.

On a server set up with claude-code-vps all of this is in place, and `sudo claude-vps setup --ntfy-topic <name>` writes the topic file. [Push notifications with ntfy](/blog/ntfy-notifications) covers priorities, tags and self-hosting.

## Desktop notifications

For a machine you sit in front of, the [hooks guide](https://code.claude.com/docs/en/hooks-guide#get-notified-when-claude-needs-input) uses the platform's own command:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "notify-send 'Claude Code' 'Claude Code needs your attention'" }
        ]
      }
    ]
  }
}
```

That is the Linux version. `notify-send` comes from `libnotify-bin` on Ubuntu and Debian, and it needs a notification daemon, which headless servers and SSH sessions do not have. On macOS the guide uses `osascript -e 'display notification ...'`, and Script Editor needs notification permission in System Settings first.

## A sound or a terminal bell

Claude Code already alerts in some terminals without a hook: Ghostty, Kitty and iTerm2 get a desktop notification when Claude Code detects them. To force a bell character everywhere, set `"preferredNotifChannel": "terminal_bell"` in your settings.

Inside tmux, notifications do not reach the outer terminal until you allow passthrough in `~/.tmux.conf`:

```bash
set -g allow-passthrough on
set -g focus-events on
```

Hooks run alongside the built-in alert, so a phone push and a terminal bell can both happen.

## Separate alerts per event

Use matchers to treat permission prompts and idle prompts differently, for example a high-priority push when Claude is blocked and a quiet one when it is merely done:

```json
{
  "hooks": {
    "Notification": [
      { "matcher": "permission_prompt", "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify-urgent.sh" }] },
      { "matcher": "idle_prompt", "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

In `notify-urgent.sh`, add `-H "Priority: high"` to the curl call. ntfy maps priority 4 to a long vibration burst and a pop-over notification.

## FAQ

<Faq />

## Related

- [Push notifications with ntfy](/blog/ntfy-notifications): the curl line, priorities and Docker self-hosting
- [ntfy vs Gotify](/blog/ntfy-vs-gotify): which push server fits a script like this
- [Control Claude Code from your phone](/claude-code-on-your-phone): the push plus an SSH app
- [Run Claude Code on a remote server](/guide/claude-code): where the hook sits in the server setup
- [Claude Code settings.json](/blog/claude-code-settings-json): where the `hooks` block lives and which file wins
