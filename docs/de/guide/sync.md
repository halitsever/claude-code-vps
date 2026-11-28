---
title: "Einstellungen synchronisieren"
description: "KDE-Plasma- und Claude-Code-Einstellungen zwischen deinem Rechner und dem VPS abgleichen, mit claude-vps publish, sync und autosync."
---

# Einstellungen zwischen deinem Rechner und dem Server synchronisieren

Wie der Server aussieht und sich verhält, steht komplett im Repo. Du änderst etwas auf deinem eigenen Rechner, und der Server übernimmt es.

```text
 dein Rechner                  GitHub                     Server
 ────────────                  ──────                     ──────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (oder autosync, alle 30 Min.)
```

## Auf deinem Rechner

Klone das Repo einmal und leg die CLI in deinen PATH:

```bash
git clone https://github.com/halitsever/claude-code-vps.git ~/claude-code-vps
ln -s ~/claude-code-vps/bin/claude-vps ~/.local/bin/claude-vps
```

Hast du eine Leiste, ein Tastenkürzel, dein Konsole-Profil oder `~/.claude/settings.json` geändert, führe aus:

```bash
claude-vps publish
```

Das startet `capture`, macht einen Commit von `dotfiles/` und pusht. Willst du vorher den Diff sehen:

```bash
claude-vps capture
git -C ~/claude-code-vps diff
```

## Auf dem Server

```bash
claude-vps sync
```

Der Befehl macht einen Pull und führt `apply` aus. Jede Datei, die überschrieben wird, kopiert er vorher nach `~/.local/state/claude-vps/backup-<timestamp>/`. Unveränderte Dateien bleiben unberührt.

Oder lass es automatisch laufen:

```bash
claude-vps autosync on     # systemd-Timer für den Benutzer, alle 30 Minuten
claude-vps autosync        # zeigt, wann der nächste Lauf ist
claude-vps autosync off
```

::: warning Plasma und laufende Sitzungen
Plasma hält einige Einstellungen im Speicher und schreibt sie beim Abmelden zurück. Kommt ein Sync, während du per RDP verbunden bist, melde dich ab und wieder an, um die Änderung zu sehen. Ändere in der Zwischenzeit nicht dieselbe Einstellung auf dem Server.
:::

## Was gesichert wird

Die Liste steht in [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/manifest.txt). Ein Schrägstrich am Ende bedeutet den ganzen Ordner.

| Bereich | Dateien |
| --- | --- |
| Plasma | `kdeglobals`, `kwinrc`, `kglobalshortcutsrc`, `plasmarc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kdedefaults/`, Energie- und Benachrichtigungseinstellungen |
| Programme | `dolphinrc`, `konsolerc`, `katerc`, `~/.local/share/konsole/`, GTK-Theme-Einstellungen, `mimeapps.list` |
| Aussehen | `~/.local/share/color-schemes/`, `plasma/`, `aurorae/`, `wallpapers/`, falls vorhanden |
| Claude | `~/.claude/settings.json`, `hooks/` |
| Shell | `.tmux.conf`, `.xsession` |

Willst du noch etwas anderes mitnehmen, füge eine Zeile ins Manifest ein. Pfade, die es auf deinem Rechner nicht gibt, werden übersprungen.

## Was nie gesichert wird

Dein Home-Pfad wird durch `@HOME@` ersetzt, damit die Dateien mit jedem Benutzernamen funktionieren. Abschnitte mit zuletzt geöffneten Dateien oder Verlauf fallen weg. Zugangsdaten stehen gar nicht erst auf der Liste: `~/.claude/.credentials.json`, `~/.claude/ntfy-topic`, SSH-Schlüssel, `kwalletrc`, Browserprofile. Lass das so, denn das Repo ist öffentlich.
