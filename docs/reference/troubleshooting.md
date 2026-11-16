---
description: "Fix common Claude Code VPS problems: black RDP screen, xrdp color profile prompts, SSH lockout, claude not found and sync errors."
---

# Troubleshooting

Start with:

```bash
claude-vps doctor
```

## RDP shows a black screen and disconnects

Usually `~/.xsession` is missing or Plasma is already running for that user.

```bash
cat ~/.xsession                      # should end with: exec startplasma-x11
loginctl list-sessions               # an old session for your user? terminate it:
loginctl terminate-user $USER
```

Logs are in `~/.xsession-errors` and `/var/log/xrdp-sesman.log`.

## "Authentication is required to create a color managed device"

The polkit rule from the `rdp` step handles this. Make sure your user is in the `users` group (`id`), then reconnect.

## Can't connect to RDP at all

```bash
sudo ss -tlnp | grep xrdp      # listening on 53389?
sudo ufw status                # port allowed?
```

Your cloud provider may also have its own firewall in front of the server.

## Locked out of SSH

The `ssh` step only turns off password login when your user has a key, but if it happens anyway, use your provider's web console, then:

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

The native installer puts it in `~/.local/bin`. Ubuntu adds that to `PATH` at login once the folder exists, so log out and back in, or run `source ~/.profile`.

## `claude-vps sync` says "Not possible to fast-forward"

The clone on the server has local changes. The server is meant to only pull:

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## Restoring an old file

Every `apply` backs up what it overwrites:

```bash
ls ~/.local/state/claude-vps/
```
