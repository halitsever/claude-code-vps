---
title: "Claude Code Remote Control vs Running It on a Server"
titleTemplate: false
description: "What Claude Code Remote Control does, what it needs and where it stops, and how running it on an always-on VPS keeps sessions alive when your laptop closes."
date: 2026-11-28
faq:
  - q: "Does Claude Code Remote Control open a port on my machine?"
    a: "No. Anthropic's docs say the local session makes outbound HTTPS requests only and never opens inbound ports. It registers with the Anthropic API and polls for work."
  - q: "Can I use Remote Control with an API key?"
    a: "No. Remote Control needs a claude.ai login on a Pro, Max, Ultra, Team or Enterprise plan. If ANTHROPIC_API_KEY is set, Claude Code reports that the session is using API-key auth and Remote Control will not start."
  - q: "What happens to a Remote Control session when my laptop sleeps?"
    a: "The session goes offline because it runs on your laptop. An interactive session reconnects on its own when the machine is awake and online again. In server mode, claude remote-control exits after roughly 10 minutes without network."
  - q: "Can I run Remote Control on a VPS?"
    a: "Yes. Start claude remote-control inside tmux on the server, sign in with your claude.ai account, and connect from claude.ai/code or the Claude app. The server stays on, so the session does not depend on your laptop."
---

# Claude Code Remote Control vs running it on your own server

<p class="post-meta">Halit Sever · 28 November 2026</p>

Claude Code Remote Control lets you continue a Claude Code session from your phone, a tablet or another browser. The session itself keeps running on the machine where you started it. That one detail decides most of what follows: Remote Control is a window into a machine, so it is only as available as that machine.

This post covers what Remote Control does according to [Anthropic's documentation](https://code.claude.com/docs/en/remote-control), what it needs, where it stops, and what changes when the machine behind it is a server that never sleeps. Facts about Remote Control were checked against the docs on 28 November 2026.

## What Remote Control is

Remote Control connects [claude.ai/code](https://claude.ai/code) or the Claude app for iOS and Android to a Claude Code session running on your computer. Your files, MCP servers, tools and project config stay on that computer. You can type from the terminal, the browser and the phone in the same conversation, and attach photos or files from the phone.

It is not a cloud session. The docs draw the line clearly: cloud sessions run on Anthropic-managed infrastructure, while Remote Control "executes on your machine", so "your computer has to stay on and the `claude` process has to keep running."

## Three ways to start it

| Command | What you get |
| --- | --- |
| `claude remote-control` | Server mode. The process waits for remote connections, prints a URL, and shows a QR code when you press the spacebar. One process can serve several sessions. |
| `claude --remote-control` or `claude --rc "My Project"` | A normal interactive session that is also reachable from claude.ai and the app. |
| `/remote-control` or `/rc` | Turns it on inside a session that is already running. |

To have every interactive session connect by itself, run `/config` and turn on **Enable Remote Control for all sessions**. The first time you start it, Claude Code asks you to confirm once.

## What it needs

- **A claude.ai login.** Remote Control works on Pro, Max, Ultra, Team and Enterprise plans. API keys are not supported. On Team and Enterprise an Owner has to switch it on in the admin settings first.
- **The Anthropic API directly.** It is not available on Amazon Bedrock, Google Cloud's Agent Platform or Microsoft Foundry, or when `ANTHROPIC_BASE_URL` points at a gateway or proxy.
- **Feature flags left on.** `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` or `CLAUDE_CODE_DISABLE_FEATURE_FLAGS` make it unavailable.
- **A trusted folder.** In a folder you have not trusted yet, `claude remote-control` asks before it starts.

On the network side, the local session "makes outbound HTTPS requests only and never opens inbound ports." While it is connected, the transcript is stored on Anthropic's servers so the devices stay in sync. Code execution and file access stay local.

## Where it stops

The [Limitations section](https://code.claude.com/docs/en/remote-control#limitations) lists the cases that matter for long jobs:

- If you close the terminal or the `claude` process stops, the session goes offline until you bring it back.
- If the machine is awake but offline, server mode gives up after roughly 10 minutes and `claude remote-control` exits. An interactive session keeps retrying.
- After you stop the server with Ctrl+C, `claude remote-control --continue` can bring a session back for about four hours.

A laptop that sleeps in a bag is the common case here. The session waits for the laptop, and so does the work. The docs also give the fix for remote machines: "start it inside `tmux` or `screen` to keep the session running after you disconnect from SSH."

## What a server adds

[claude-code-vps](/) is the setup I use for this: one command turns a fresh Ubuntu 24.04 or newer server into a Claude Code workstation. Compared with Remote Control on a laptop, the server changes these things:

- **The machine stays on.** The `claude` process lives in a tmux session on a VPS, so closing the laptop changes nothing.
- **You get a full desktop when you want one.** KDE Plasma over RDP on port 53389, for browser checks and GUI tools. See [Remote desktop](/guide/remote-desktop).
- **Your phone gets a push when Claude waits.** A `Notification` hook posts to ntfy.sh. See [Claude Code notifications](/blog/claude-code-notifications).
- **Docker, Chrome and gh are already there**, so agents can run services and tests without touching your own machine.

The two also combine. Run Remote Control on the server and the phone talks to the always-on box instead of the laptop:

```bash
ssh dev@<server-ip>
tmux new -s rc
cd ~/projects/my-app
claude remote-control
```

Press the spacebar for the QR code, scan it with the Claude app, then detach from tmux with `Ctrl-b d`. The server keeps serving the session after you log out. Log in with your claude.ai account for this, not an API key, since Remote Control does not accept API keys.

| | Remote Control on a laptop | SSH and tmux on a VPS | Remote Control on a VPS |
| --- | --- | --- | --- |
| Works when the laptop sleeps | No | Yes | Yes |
| Phone client | Claude app | Any SSH app | Claude app |
| Needs a claude.ai plan | Yes | No, an API key also works | Yes |
| Inbound ports | None | SSH (22) | SSH (22); Remote Control itself needs none |
| Desktop for GUI work | Your laptop | RDP | RDP |

## When Remote Control is not working

Most failures come with a message that names the cause. From the [troubleshooting list](https://code.claude.com/docs/en/remote-control#troubleshooting):

- **"Remote Control requires a claude.ai subscription"**: you are signed out, or `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN` or an `apiKeyHelper` takes precedence. Remove it and run `claude auth login`.
- **"requires a full-scope login token"**: you signed in with a token from `claude setup-token`. Run `claude auth login` instead.
- **"only available when using Claude via api.anthropic.com"**: a Bedrock, Foundry or `ANTHROPIC_BASE_URL` setting routes the session elsewhere.
- **"Remote Control disconnected" in the browser**: check the machine. If `claude` is no longer running, start it again and resume the session.

`claude doctor` shows which eligibility check failed.

## FAQ

<Faq />

## Related

- [Control Claude Code from your phone](/claude-code-on-your-phone): the SSH and ntfy route, step by step
- [Claude Code over SSH](/blog/claude-code-ssh): keys, sessions that survive a disconnect, clipboard limits
- [Run Claude Code on a remote server](/guide/claude-code): first login on a headless box
- [How to run Claude Code on a VPS](/guide/claude-code-vps): every setup step by hand
- [claude --dangerously-skip-permissions](/blog/claude-dangerously-skip-permissions): what bypass mode means on a server
