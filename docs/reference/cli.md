---
title: "claude-vps CLI: Commands and Options"
description: "Reference for every claude-vps command and option: setup, sync, autosync, doctor, capture, publish and apply, plus install.sh variables."
---

# CLI

```text
claude-vps <command> [options]
```

| Command | Where | What it does |
| --- | --- | --- |
| `setup` | server, as root | Runs the install steps |
| `update` | server, as root | Pulls the latest release and runs setup again with the options from the first install |
| `sync` | server | `git pull`, then `apply` |
| `autosync on\|off` | server | systemd user timer that runs `sync` every 30 minutes |
| `doctor` | server | Checks Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy and autosync |
| `capture` | your machine | Copies the files in `dotfiles/manifest.txt` into `dotfiles/home` |
| `publish` | your machine | `capture`, commit and push |
| `release X.Y.Z` | your machine | Writes `VERSION`, tags `vX.Y.Z` and pushes. GitHub publishes the release from `CHANGELOG.md` |
| `apply` | anywhere | Writes `dotfiles/home` into `$HOME`, backing up what it replaces |
| `version` | anywhere | Prints the version |

## setup

```bash
sudo claude-vps setup [options]
```

| Option | Default | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER`, or asks | Workstation user, created if missing |
| `--rdp-port PORT` | `53389` | xrdp port |
| `--rdp-private` | off | Don't open the RDP port in ufw |
| `--ntfy-topic NAME` | asks | ntfy.sh topic for notifications |
| `--timezone TZ` | unchanged | e.g. `Europe/Istanbul` |
| `--no-desktop` | off | Same as `--skip desktop,rdp` |
| `--skip a,b` | | Steps to skip |
| `--only a,b` | | Run only these steps |
| `-y, --yes` | off | No questions. User defaults to `dev`, password is generated |
| `-n, --dry-run` | off | Print commands instead of running them |

Steps, in order: `base user ssh firewall desktop rdp apps claude dotfiles`.

## Updating

When a new version is out, run this on each server:

```bash
sudo claude-vps update
```

It pulls the new code, shows what changed, and runs every setup step again. Steps that are already done are skipped, and xrdp and SSH are only restarted if their config changed, so an open RDP session stays connected. The options you chose on the first install (user, RDP port, skipped steps) are kept in `/etc/claude-vps.conf` and reused.

`claude-vps sync` also tells you when a new version has arrived.

## Releasing a version

On your own machine, add a `## X.Y.Z` section to `CHANGELOG.md`, commit it, then:

```bash
claude-vps release X.Y.Z
```

The release workflow checks that the tag matches `VERSION` and publishes a GitHub release with that changelog section as notes.

## Config source machines

`claude-vps capture` marks the machine it runs on as a config source (`~/.config/claude-vps/source`). On such a machine `apply` and `sync` leave your files alone, because the repo copy can be older than what you are using. Use `claude-vps apply --force` to override.

## install.sh

The bootstrap script reads three environment variables:

| Variable | Default |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Anything after `bash -s --` is passed to `setup`.
