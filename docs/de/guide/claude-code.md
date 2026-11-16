---
description: "Claude Code auf einem Server ohne Bildschirm anmelden, Agenten in tmux nach SSH-Abbrüchen weiterlaufen lassen und per ntfy.sh Nachrichten aufs Handy bekommen."
---

# Claude Code nutzen

## Erste Anmeldung

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Claude Code zeigt einen Anmeldelink an. Öffne ihn in deinem eigenen Browser, bestätige und füge den Code im Terminal ein. Die Zugangsdaten bleiben auf dem Server in `~/.claude`.

Lieber mit API-Schlüssel? Exportiere ihn vor dem Start:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## Mit tmux weiterlaufen lassen

Ein Agent, der eine Stunde arbeitet, soll nicht abbrechen, nur weil dein Laptop in den Ruhezustand geht. Starte ihn in tmux und trenne dich dann:

| | |
| --- | --- |
| Trennen | `Strg-b`, dann `d` |
| Wieder verbinden | `tmux attach -t claude` |
| Neues Fenster | `Strg-b`, dann `c` |
| Sitzungen anzeigen | `tmux ls` |

Die mitgelieferte `.tmux.conf` schaltet Mausbedienung, 50.000 Zeilen Verlauf und 256 Farben ein.

Du kannst auch auf dem Desktop Konsole öffnen und dort `tmux attach -t claude` ausführen. Gleiche Sitzung, größerer Bildschirm.

## Benachrichtigungen aufs Handy

`~/.claude/settings.json` registriert einen `Notification`-Hook, `~/.claude/hooks/notify.sh`. Er schickt eine Nachricht an [ntfy.sh](https://ntfy.sh), sobald Claude auf dich wartet.

1. Installiere die ntfy-App auf dem Handy und abonniere ein Topic, das niemand errät, z. B. `claude-7f3k9q2m`.
2. Trag dasselbe Topic auf dem Server ein:

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   Oder gib bei der Installation `--ntfy-topic` an.

Das Topic ist geheim: Wer es kennt, kann deine Benachrichtigungen mitlesen. Deshalb steht es in einer eigenen Datei und landet nie im Repo.

## Was schon eingerichtet ist

Aus `dotfiles/home/.claude`:

- **`settings.json`**: dunkles Theme, Vollbild-TUI, eine Statuszeile mit Modell, Ordner, Git-Branch und Kontextverbrauch, die Plugins, die ich nutze, und der Benachrichtigungs-Hook
- **`CLAUDE.md`**: eine leere Datei für deine eigenen globalen Anweisungen. Sie wird nur angelegt, wenn sie fehlt. Was du hineinschreibst, wird also nie überschrieben
- **`hooks/notify.sh`**: der ntfy-Hook von oben

Ändere davon, was du willst, auf deinem eigenen Rechner und führe `claude-vps publish` aus. Siehe [Einstellungen synchronisieren](/de/guide/sync).

## Claude Code aktualisieren

Die native Installation aktualisiert sich im Hintergrund selbst. Von Hand geht es so:

```bash
claude update
```
