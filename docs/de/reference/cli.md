---
description: "Referenz aller claude-vps-Befehle und Optionen für deinen Claude Code VPS: setup, sync, autosync, doctor, capture, publish, apply und die install.sh-Variablen."
---

# CLI

```text
claude-vps <command> [options]
```

| Befehl | Wo | Was er macht |
| --- | --- | --- |
| `setup` | Server, als root | Führt die Installationsschritte aus |
| `sync` | Server | `git pull`, danach `apply` |
| `autosync on\|off` | Server | systemd-Timer für den Benutzer, der alle 30 Minuten `sync` ausführt |
| `doctor` | Server | Prüft Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy und autosync |
| `capture` | dein Rechner | Kopiert die Dateien aus `dotfiles/manifest.txt` nach `dotfiles/home` |
| `publish` | dein Rechner | `capture`, Commit und Push |
| `apply` | überall | Schreibt `dotfiles/home` nach `$HOME` und sichert vorher, was ersetzt wird |
| `version` | überall | Zeigt die Version an |

## setup

```bash
sudo claude-vps setup [options]
```

| Option | Standard | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER`, sonst Rückfrage | Benutzer für den Arbeitsrechner, wird bei Bedarf angelegt |
| `--rdp-port PORT` | `53389` | Port für xrdp |
| `--rdp-private` | aus | RDP-Port in ufw nicht öffnen |
| `--ntfy-topic NAME` | Rückfrage | ntfy.sh-Topic für Benachrichtigungen |
| `--timezone TZ` | unverändert | z. B. `Europe/Istanbul` |
| `--no-desktop` | aus | Wie `--skip desktop,rdp` |
| `--skip a,b` | | Diese Schritte auslassen |
| `--only a,b` | | Nur diese Schritte ausführen |
| `-y, --yes` | aus | Keine Rückfragen. Benutzer ist dann `dev`, das Passwort wird erzeugt |
| `-n, --dry-run` | aus | Befehle nur anzeigen, nicht ausführen |

Schritte in dieser Reihenfolge: `base user ssh firewall desktop rdp apps claude dotfiles`.

## install.sh

Das Bootstrap-Skript liest drei Umgebungsvariablen:

| Variable | Standard |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Alles nach `bash -s --` wird an `setup` weitergegeben.
