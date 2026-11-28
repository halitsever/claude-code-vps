---
title: "Claude Code over SSH: A Working Setup"
titleTemplate: false
description: "Run Claude Code over SSH on a remote server: key-only login, sessions that survive a dropped connection, port forwarding and clipboard limits."
date: 2026-11-28
faq:
  - q: "Can I run Claude Code over SSH?"
    a: "Yes. Install Claude Code on the remote machine, SSH in and run claude. Log in by copying the login URL to a browser on your own device and pasting the code back."
  - q: "How do I keep Claude Code running after SSH disconnects?"
    a: "Start it inside tmux or screen. The session lives on the server, so a dropped connection or a closed laptop does not stop the agent. Reattach later with tmux attach."
  - q: "Can I paste an image into Claude Code over SSH?"
    a: "Image paste reads a clipboard that Claude Code can reach, and over SSH that is the server, not your laptop. Copy the file to the server with scp and mention its path in the prompt instead."
  - q: "Why does copying text from Claude Code over SSH not work?"
    a: "Over SSH Claude Code sends copied text as an OSC 52 escape sequence and your terminal decides what to do with it. iTerm2 needs a setting turned on, and macOS Terminal.app does not support OSC 52."
---

# Running Claude Code over SSH without the rough edges

<p class="post-meta">Halit Sever · 28 November 2026</p>

Running Claude Code on a remote machine and reaching it over SSH is the simplest way to let an agent work while your own computer is off. It also has a few rough edges: the login wants a browser, a dropped connection can kill the session, and the clipboard does not cross the wire the way you expect.

This is the setup claude-code-vps builds, written out so you can do it on any server.

## 1. Key-only SSH

Create a key on your own machine if you do not have one, and copy it to the server:

```bash
ssh-keygen -t ed25519
ssh-copy-id dev@<server-ip>
```

Then turn password logins off. claude-code-vps writes this file:

```text
# /etc/ssh/sshd_config.d/10-claude-vps.conf
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

The `10-` prefix matters. sshd keeps the first value it reads for each option, and cloud images often ship their own file in `sshd_config.d` that turns passwords back on. A name that sorts first wins. Test and reload:

```bash
sudo sshd -t && sudo systemctl reload ssh
```

Keep your current session open and try a new `ssh dev@<server-ip>` in a second terminal before you log out. The script itself skips this step when the user has no key yet, so it cannot lock you out.

## 2. A short host alias

On your own machine, `~/.ssh/config`:

```text
Host claude
  HostName 203.0.113.7
  User dev
  ServerAliveInterval 30
```

Now `ssh claude` is enough. `ServerAliveInterval` sends a keepalive every 30 seconds, which helps on networks that drop idle connections.

## 3. Install and log in

Install Claude Code on the server with the native installer (see [How to install Claude Code on Linux](/blog/install-claude-code-linux)), then run `claude`. There is no browser on the server, so:

1. Press `c` to copy the login URL, or select it in your terminal.
2. Open it on your laptop or phone and sign in.
3. Paste the code at the `Paste code here if prompted` prompt.

Credentials stay in `~/.claude` on the server.

## 4. Sessions that survive a disconnect

If you run `claude` straight in the SSH shell, closing the laptop ends the shell and the agent with it. Run it inside tmux:

```bash
tmux new -s claude
claude
# Ctrl-b d to detach, the agent keeps working
tmux attach -t claude
```

claudegrid's [tmux guide](https://projects.halit.org/claudegrid/guide/tmux) covers running several agents this way. claude-code-vps installs tmux and a `.tmux.conf` with mouse support, a 50,000 line scrollback and 256 colors.

Two lines from [Anthropic's terminal docs](https://code.claude.com/docs/en/terminal-config) are worth adding to `~/.tmux.conf` for Claude Code:

```bash
set -s extended-keys on
set -as terminal-features 'xterm*:extkeys'
```

Without them, Shift+Enter submits the prompt inside tmux instead of adding a new line.

## 5. Reaching dev servers

Agents start dev servers on the remote machine. Forward the port to your laptop instead of opening it in the firewall:

```bash
ssh -L 3000:localhost:3000 claude
```

`http://localhost:3000` on your laptop now reaches port 3000 on the server. For anything that needs a real browser on the server side, claude-code-vps also gives you a KDE desktop over RDP; see [Remote desktop](/guide/remote-desktop).

## Clipboard and image paste limits

**Copying out.** Claude Code on a remote machine cannot run a clipboard tool on your laptop. Outside tmux, `/copy` and text selection send an OSC 52 escape sequence, and the terminal decides whether to accept it. iTerm2 ignores OSC 52 until you enable **Settings > General > Selection > Applications in terminal may access clipboard**. macOS Terminal.app does not support it at all, per the [troubleshooting docs](https://code.claude.com/docs/en/troubleshooting).

**Pasting images in.** Ctrl+V pastes an image from a clipboard Claude Code can reach, which over SSH is the server's, not yours. The dependable route is to copy the file over and name it:

```bash
scp screenshot.png claude:~/projects/my-app/
```

Then in the prompt: `look at screenshot.png`.

## Closing SSH to the internet

`sudo claude-vps tailscale` joins the server to a Tailscale network, then closes public SSH and RDP in ufw so both are reachable only over the tailnet. It asks first, and leaves both open when it sees no connection from the tailnet yet, so you cannot lock yourself out.

## FAQ

<Faq />

## Related

- [Control Claude Code from your phone](/claude-code-on-your-phone): the same setup from an SSH app
- [Claude Code Remote Control vs a server](/blog/claude-code-remote-control): when the Claude app is enough
- [Claude Code notifications](/blog/claude-code-notifications): a push when the agent waits
- [How to run Claude Code on a VPS](/guide/claude-code-vps): the full manual setup
- [Resume a Claude Code session](/blog/claude-code-resume-session): when the process ended and tmux cannot help
