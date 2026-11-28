---
title: "claude-vps CLI: Befehle und Optionen"
description: "Referenz aller claude-vps-Befehle und Optionen für deinen Claude Code VPS: setup, sync, autosync, doctor, capture, publish, apply und die install.sh-Variablen."
---

# CLI

```text
claude-vps <command> [options]
```

| Befehl | Wo | Was er macht |
| --- | --- | --- |
| `setup` | Server, als root | Führt die Installationsschritte aus |
| `update` | Server, als root | Holt die neueste Version und führt setup erneut mit den Optionen der ersten Installation aus |
| `sync` | Server | `git pull`, danach `apply` |
| `autosync on\|off` | Server | systemd-Timer für den Benutzer, der alle 30 Minuten `sync` ausführt |
| `doctor` | Server | Prüft Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy und autosync |
| `capture` | dein Rechner | Kopiert die Dateien aus `dotfiles/manifest.txt` nach `dotfiles/home` |
| `publish` | dein Rechner | `capture`, Commit und Push |
| `release X.Y.Z` | dein Rechner | Schreibt `VERSION`, setzt den Tag `vX.Y.Z` und pusht. GitHub veröffentlicht das Release anhand von `CHANGELOG.md` |
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

## Aktualisieren

Wenn eine neue Version erscheint, führ das auf jedem Server aus:

```bash
sudo claude-vps update
```

Der Befehl holt den neuen Code, zeigt die Änderungen und führt alle setup-Schritte erneut aus. Schritte, die schon erledigt sind, werden übersprungen. xrdp und SSH starten nur neu, wenn sich ihre Konfiguration geändert hat. Eine offene RDP-Sitzung bleibt also verbunden. Die Optionen der ersten Installation (Benutzer, RDP-Port, übersprungene Schritte) liegen in `/etc/claude-vps.conf` und werden wieder verwendet.

`claude-vps sync` sagt dir außerdem Bescheid, wenn eine neue Version da ist.

## Eine Version veröffentlichen

Füg auf deinem Rechner in `CHANGELOG.md` einen Abschnitt `## X.Y.Z` hinzu, committe ihn und führ dann aus:

```bash
claude-vps release X.Y.Z
```

Der Release-Workflow prüft, ob der Tag zu `VERSION` passt, und veröffentlicht ein GitHub-Release. Als Release Notes dient der passende Abschnitt aus dem Changelog.

## Rechner als Konfigurationsquelle

`claude-vps capture` markiert den Rechner, auf dem es läuft, als Konfigurationsquelle (`~/.config/claude-vps/source`). Auf so einem Rechner lassen `apply` und `sync` deine Dateien in Ruhe, denn die Kopie im Repo kann älter sein als das, was du gerade nutzt. Mit `claude-vps apply --force` überschreibst du sie trotzdem.

## install.sh

Das Bootstrap-Skript liest drei Umgebungsvariablen:

| Variable | Standard |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Alles nach `bash -s --` wird an `setup` weitergegeben.
