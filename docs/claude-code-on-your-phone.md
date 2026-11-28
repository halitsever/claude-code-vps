---
title: "Control Claude Code From Your Phone"
description: "Control Claude Code from your phone: an SSH app, a tmux session on an always-on VPS and an ntfy push when Claude waits. Works on iOS and Android."
faq:
  - q: "Can I control Claude Code from my phone?"
    a: "Yes, two ways. Anthropic's Remote Control connects the Claude app to a session on your computer. Or run Claude Code in tmux on a server and attach from any SSH app, which keeps working when your computer is off."
  - q: "Which SSH apps work on iOS and Android?"
    a: "Any SSH client that accepts a key works, for example Termius on iOS and Android, Blink Shell on iOS, or Termux with pkg install openssh on Android. Load the same private key you added to the server."
  - q: "Does closing the SSH app stop Claude Code?"
    a: "No. Claude Code runs inside tmux on the server. Closing the app or losing signal only ends the SSH connection; run tmux attach -t claude to get back to the same session."
  - q: "Is it safe to open SSH to my phone?"
    a: "claude-code-vps turns password logins off, so only your key can log in. To keep SSH off the internet entirely, run sudo claude-vps tailscale and connect from the Tailscale app on the phone."
---

# Run Claude Code from your phone over SSH

Start a task at your desk, close the laptop, and answer Claude's next question from the phone in your pocket. The setup is three pieces: Claude Code running in tmux on a server that never sleeps, an SSH app on the phone, and a push notification that tells you when Claude is waiting.

<div class="phone-flow" role="img" aria-label="Diagram: an SSH app on the phone connects to a tmux session on the VPS where Claude Code runs; a Notification hook on the VPS sends a push through ntfy.sh back to the phone.">
<svg viewBox="0 0 720 210" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
  <defs>
    <marker id="arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0L10 5L0 10z" fill="currentColor"/></marker>
  </defs>
  <g fill="none" stroke="currentColor" stroke-width="1.5">
    <rect x="10" y="20" width="160" height="170" rx="16"/>
    <rect x="550" y="20" width="160" height="170" rx="16"/>
    <rect x="285" y="125" width="150" height="62" rx="12"/>
    <path d="M170 62H548" marker-end="url(#arr)"/>
    <path d="M550 156H437" marker-end="url(#arr)" stroke-dasharray="5 4"/>
    <path d="M285 156H172" marker-end="url(#arr)" stroke-dasharray="5 4"/>
  </g>
  <g fill="currentColor" font-family="JetBrains Mono, monospace" font-size="12" text-anchor="middle">
    <text x="90" y="100" font-size="15" font-weight="700">Phone</text>
    <text x="90" y="122">SSH app</text>
    <text x="90" y="140">ntfy app</text>
    <text x="630" y="100" font-size="15" font-weight="700">VPS</text>
    <text x="630" y="122">tmux: claude</text>
    <text x="630" y="140">Notification hook</text>
    <text x="360" y="152" font-size="14" font-weight="700">ntfy.sh</text>
    <text x="360" y="172">push relay</text>
    <text x="360" y="50">ssh, then tmux attach -t claude</text>
    <text x="493" y="146" font-size="11">POST</text>
    <text x="228" y="146" font-size="11">push</text>
  </g>
</svg>
</div>

The SSH connection goes straight from the phone to the server. The push takes the other way: the server posts to ntfy.sh, and ntfy delivers it to the phone.

## 1. Set up the server

On a fresh Ubuntu 24.04 or newer VPS, as root:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --ntfy-topic claude-7f3k9q2m
```

That one command creates the `dev` user with your SSH key, turns password logins off, enables ufw, and installs tmux, Claude Code, Docker, Chrome and a KDE desktop over RDP. `--ntfy-topic` writes the topic for phone pushes. Pick your own random topic name: on ntfy.sh the topic is the password. [Getting started](/guide/getting-started) has every option.

## 2. Turn on the push

Install the ntfy app on your phone (Android or iOS) and subscribe to the same topic. That is the whole step: the server already has a `Notification` hook that posts Claude's message to `https://ntfy.sh/<topic>` whenever Claude needs a permission or has finished and is waiting. [Claude Code notifications](/blog/claude-code-notifications) explains the hook line by line.

## 3. Start Claude Code in tmux

From your laptop, once:

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Log in with the link Claude Code prints, give it a task, and close the laptop. The agent keeps running on the server.

## 4. Connect from the phone

Add the server to your SSH app with the same private key, then connect and attach:

```bash
tmux attach -t claude
```

If your SSH app can run a command on connect, set it to `tmux attach -t claude` and you land in the session right away.

On a small screen, a few tmux keys help:

| | |
| --- | --- |
| Detach and leave it running | `Ctrl-b` then `d` |
| Scroll back | `Ctrl-b` then `[`, `q` to leave |
| Zoom the current pane | `Ctrl-b` then `z` |

The shipped `.tmux.conf` turns mouse support on and keeps 50,000 lines of scrollback.

## Phone apps that work

Any SSH client that accepts a private key works. For example:

- **iOS**: Termius, Blink Shell
- **Android**: Termius, or Termux with `pkg install openssh`

You type in a full terminal, so answering a permission prompt is one key. Longer prompts are easier with the phone's dictation.

<div class="vs-box">

**Compared with Remote Control.** Anthropic's Remote Control lets the Claude app drive a session on your computer, with no SSH app, but the computer has to stay on and it needs a claude.ai plan. The server route keeps working with the laptop closed, and you can combine the two by running `claude remote-control` in tmux on the server. [Claude Code Remote Control vs a server](/blog/claude-code-remote-control) compares them in detail.

</div>

## When you need a real screen

Some tasks want a browser or a GUI. The same server has a KDE Plasma desktop on RDP port 53389, and RDP clients exist for iOS and Android too. Open Konsole there and run `tmux attach -t claude` to see the same session on a bigger screen. See [Remote desktop](/guide/remote-desktop).

## Keeping SSH off the internet

The default setup leaves SSH open with key-only login. To close it to the internet, run `sudo claude-vps tailscale` on the server and install the Tailscale app on the phone. SSH and RDP then answer only over your tailnet.

## FAQ

<Faq />

## Read next

- [Claude Code over SSH](/blog/claude-code-ssh): keys, port forwarding, clipboard and image paste limits
- [Send push notifications with ntfy](/blog/ntfy-notifications): priorities and self-hosting
- [Run Claude Code on a remote server](/guide/claude-code): first login on a headless box
- [How to run Claude Code on a VPS](/guide/claude-code-vps): every step by hand
