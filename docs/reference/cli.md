# CLI

```text
claude-vps <command> [options]
```

| Command | Where | What it does |
| --- | --- | --- |
| `setup` | server, as root | Runs the install steps |
| `sync` | server | `git pull`, then `apply` |
| `autosync on\|off` | server | systemd user timer that runs `sync` every 30 minutes |
| `doctor` | server | Checks Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy and autosync |
| `capture` | your machine | Copies the files in `dotfiles/manifest.txt` into `dotfiles/home` |
| `publish` | your machine | `capture`, commit and push |
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

## install.sh

The bootstrap script reads three environment variables:

| Variable | Default |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Anything after `bash -s --` is passed to `setup`.
