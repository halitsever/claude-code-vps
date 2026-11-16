---
description: "Install claude-vps on a fresh Ubuntu 24.04 or 26.04 VPS with one command and get Claude Code, KDE Plasma over RDP and hardened SSH in about ten minutes."
---

# Getting started

claude-vps turns a fresh Ubuntu server into the machine I run Claude Code on: a sudo user, key-only SSH, a firewall, a KDE Plasma desktop you reach over RDP, Docker, Chrome, and Claude Code itself with my settings, hooks and KDE layout already applied.

## What you need

| | |
| --- | --- |
| **OS** | Ubuntu 24.04 LTS or newer (26.04 is what I run) |
| **CPU / RAM** | 2 vCPU and 4 GB is the floor for Plasma. 4 vCPU / 8 GB feels like a real desktop |
| **Disk** | 25 GB or more |
| **Access** | Root over SSH, ideally with your SSH key already on the box |
| **Arch** | amd64 gets everything. arm64 works but skips Chrome |

A Claude Pro or Max plan, or an Anthropic API key, for logging in to Claude Code afterwards.

## Install

SSH in as root (or a user with sudo) and run:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

It clones this repo to `/opt/claude-vps` and runs `claude-vps setup`. You get asked two things: the username for your workstation and a password for it (used for sudo and the RDP login). Leave the password empty and one is generated and shown at the end.

To skip the questions, pass options after `bash -s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

Every option is listed in the [CLI reference](/reference/cli).

::: tip Try it first
`--dry-run` prints every command without running it.
:::

## When it finishes

You get a summary like this:

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **Log in over SSH** as the new user. Root's SSH keys were copied over, so the same key works.
2. **Start Claude Code** inside tmux and log in. See [Running Claude Code](/guide/claude-code).
3. **Open the desktop** with any RDP client. See [Remote desktop](/guide/remote-desktop).

## Using your own config

Out of the box the server gets my KDE and Claude config from `dotfiles/home`. To use yours, fork the repo, run `claude-vps capture` on your own machine, push, and point the installer at the fork:

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

[Keeping config in sync](/guide/sync) covers the whole loop.
