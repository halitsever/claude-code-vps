---
description: "claude-vps mit einem Befehl auf einem frischen Ubuntu-VPS installieren: Claude Code, KDE Plasma über RDP und abgesichertes SSH in etwa zehn Minuten."
---

# Erste Schritte

claude-vps macht aus einem frischen Ubuntu-Server den Rechner, auf dem ich Claude Code nutze. Du bekommst einen Benutzer mit sudo-Rechten, SSH nur mit Schlüssel, eine Firewall, einen KDE-Plasma-Desktop über RDP, Docker und Chrome. Dazu kommt Claude Code selbst, mit meinen Einstellungen, Hooks und meinem KDE-Layout.

## Was du brauchst

| | |
| --- | --- |
| **Betriebssystem** | Ubuntu 24.04 LTS oder neuer (ich nutze 26.04) |
| **CPU / RAM** | Mindestens 2 vCPU und 4 GB für Plasma. Mit 4 vCPU / 8 GB fühlt es sich wie ein richtiger Desktop an |
| **Festplatte** | 25 GB oder mehr |
| **Zugang** | root per SSH, am besten mit deinem SSH-Schlüssel schon auf dem Server |
| **Architektur** | Auf amd64 wird alles installiert. arm64 geht auch, nur ohne Chrome |

Für die Anmeldung bei Claude Code brauchst du danach einen Claude-Pro- oder Max-Plan oder einen Anthropic-API-Schlüssel.

## Installation

Melde dich per SSH als root an (oder als Benutzer mit sudo) und führe aus:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Das Skript klont das Repo nach `/opt/claude-vps` und startet `claude-vps setup`. Es fragt zwei Dinge: den Benutzernamen für deinen Arbeitsrechner und ein Passwort dafür. Das Passwort brauchst du für sudo und die RDP-Anmeldung. Lässt du es leer, wird eins erzeugt und am Ende angezeigt.

Ohne Rückfragen geht es, wenn du die Optionen nach `bash -s --` angibst:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

Alle Optionen stehen in der [CLI-Referenz](/de/reference/cli).

::: tip Erst ausprobieren
`--dry-run` zeigt jeden Befehl an, ohne ihn auszuführen.
:::

## Nach der Installation

Am Ende siehst du eine Zusammenfassung wie diese:

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **Per SSH anmelden** mit dem neuen Benutzer. Die SSH-Schlüssel von root wurden übernommen, dein Schlüssel funktioniert also auch hier.
2. **Claude Code starten**, und zwar in tmux, dann anmelden. Siehe [Claude Code nutzen](/de/guide/claude-code).
3. **Den Desktop öffnen** mit einem beliebigen RDP-Client. Siehe [Remote-Desktop](/de/guide/remote-desktop).

## Eigene Einstellungen nutzen

Standardmäßig bekommt der Server meine KDE- und Claude-Einstellungen aus `dotfiles/home`. Für deine eigenen forkst du das Repo, führst auf deinem Rechner `claude-vps capture` aus, pushst und lässt den Installer auf deinen Fork zeigen:

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

Wie der ganze Ablauf funktioniert, steht unter [Einstellungen synchronisieren](/de/guide/sync).
