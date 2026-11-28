---
title: "How to run Claude Code on a VPS"
description: "Step-by-step guide to running Claude Code on an Ubuntu VPS. Secure SSH, tmux sessions that never die, phone notifications and a full KDE Plasma desktop over RDP."
---

# How to run Claude Code on a VPS

This is the full, manual version of my setup: a cheap Ubuntu server that runs Claude Code around the clock, which I reach over SSH from anywhere and, when I want a real screen, through a KDE Plasma desktop over RDP.

Every command below is what [`claude-vps setup`](/guide/getting-started) runs for you. Read this page to understand it, or to do it by hand.

## Why run Claude Code on a VPS

- **It keeps working when your laptop sleeps.** Long refactors, test runs and migrations finish while you are away.
- **Your machine stays clean.** Agents install packages, run Docker and spin up dev servers on a box you can wipe and rebuild in ten minutes.
- **One environment everywhere.** Laptop, desktop, tablet or phone: you attach to the same tmux session and the same desktop.
- **Fast network, close to your git host and package registries.**

## Pick a server

| Use | vCPU | RAM | Disk |
| --- | --- | --- | --- |
| Terminal only | 2 | 4 GB | 40 GB |
| With KDE desktop | 4 | 8 GB | 80 GB |
| Several agents plus Docker | 8 | 16 GB | 160 GB |

Any provider that offers Ubuntu 24.04 LTS or newer works: Hetzner, DigitalOcean, OVH, Vultr, Linode, AWS Lightsail, or a spare machine at home. Pick a region close to you for a snappier RDP session. Add your SSH public key when you create the server so you never need a root password.

## 1. First login and updates

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades` installs security patches by itself, which matters on a box that is online all the time.

Small servers should get swap, so a busy agent does not trigger the OOM killer:

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. Create your user

Don't run Claude Code as root. Give it a normal user with sudo:

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

Open a second terminal and check `ssh dev@<server-ip>` works before you continue.

## 3. Lock down SSH

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd uses the first value it reads, and files load in name order. That is why the name starts with `10-`: it has to come before the `50-cloud-init.conf` that many cloud images ship with `PasswordAuthentication yes`.

## 4. Firewall

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # only if you want RDP from the internet, see below
ufw --force enable
```

## 5. Install Claude Code on Ubuntu

Log in as your user and use the native installer. It needs no Node.js and updates itself:

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

It lands in `~/.local/bin/claude`. Log out and back in once so that folder is on your `PATH`, then check:

```bash
claude --version
```

## 6. Log in on a headless server

There is no browser on the server, and you don't need one:

```bash
claude
```

Claude Code prints a URL. Open it on your own computer or phone, approve, and paste the code back into the terminal. The session is stored in `~/.claude` on the server.

With an Anthropic API key instead of a Pro or Max plan, put it in your shell profile:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

Claude Code works with an API key, but [Remote Control](https://code.claude.com/docs/en/remote-control) (driving the session from the Claude app or claude.ai) needs the claude.ai login. [Remote Control vs a server](/blog/claude-code-remote-control) covers the setup.

## 7. Keep sessions alive with tmux

If Claude runs straight in your SSH session, closing the laptop kills it. Run it in tmux:

```bash
tmux new -s claude
claude
# Ctrl-b then d to detach, the agent keeps going
tmux attach -t claude   # later, from any device
```

A small `~/.tmux.conf` makes it nicer:

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Get a ping when Claude needs you

Claude Code fires a `Notification` hook when it is waiting for input. Send that to your phone with [ntfy.sh](https://ntfy.sh):

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude is waiting"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
EOF
chmod +x ~/.claude/hooks/notify.sh
echo my-hard-to-guess-topic > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
```

Register it in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

Subscribe to the same topic in the ntfy app. Treat the topic like a password.

## 9. Optional: a KDE Plasma desktop over RDP

A terminal covers most of the work. A desktop helps when you want Chrome next to the agent, a file manager, or several Konsole windows on a big screen.

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

On Ubuntu 24.04, `plasma-session-x11` and `kwin-x11` don't exist as separate packages. Leave them out.

Tell xrdp to start Plasma for your user:

```bash
cat > ~/.xsession <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
sudo systemctl restart xrdp
```

Then stop the password prompt about color profiles that otherwise appears on every login:

```bash
sudo tee /etc/polkit-1/rules.d/45-colord.rules >/dev/null <<'EOF'
polkit.addRule(function (action, subject) {
  if (action.id.indexOf("org.freedesktop.color-manager.") === 0 && subject.isInGroup("users")) {
    return polkit.Result.YES;
  }
});
EOF
sudo usermod -aG users dev
```

Connect any RDP client to `<server-ip>:53389`. More in [Remote desktop](/guide/remote-desktop), including how to keep the port closed and tunnel it over SSH.

## 10. Dev tools

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## Security checklist

- SSH by key only, root password login off
- Firewall on, only the ports you need
- Claude Code runs as a normal user, not root
- `--dangerously-skip-permissions` only in throwaway containers, never on a box with your tokens and SSH keys
- Secrets (`~/.claude/.credentials.json`, API keys, ntfy topic) never go into a public repo
- Unattended upgrades on

## Do it all with one command

Everything above, plus applying your own KDE and Claude config, is what claude-vps automates:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

See [Getting started](/guide/getting-started).

## FAQ

### Can Claude Code run on a server without a GUI?

Yes. It is a terminal app. Login works through a link you open on any other device.

### Which Claude plan do I need?

Any plan that includes Claude Code (Pro or Max), or an Anthropic API key billed per use.

### How much does a Claude Code VPS cost?

The server is usually 5 to 20 USD a month for 4 to 8 GB RAM at budget providers. Claude usage is billed separately by your plan or API key.

### Does Claude keep running after I close SSH?

Only inside tmux (or screen). Start it with `tmux new -s claude`, detach with `Ctrl-b d`.

### Is it safe?

As safe as any server you run yourself. Follow the checklist above and keep the agent away from credentials it doesn't need.
