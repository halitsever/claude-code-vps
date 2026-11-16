---
description: "Typische Probleme mit Claude Code auf dem VPS lösen: schwarzer RDP-Bildschirm, Farbprofil-Abfragen, SSH-Aussperrung, claude nicht gefunden, Sync-Fehler."
---

# Fehlerbehebung

Fang hiermit an:

```bash
claude-vps doctor
```

## RDP zeigt einen schwarzen Bildschirm und trennt die Verbindung

Meistens fehlt `~/.xsession`, oder Plasma läuft für diesen Benutzer schon.

```bash
cat ~/.xsession                      # letzte Zeile sollte sein: exec startplasma-x11
loginctl list-sessions               # alte Sitzung deines Benutzers? Dann beenden:
loginctl terminate-user $USER
```

Die Logs stehen in `~/.xsession-errors` und `/var/log/xrdp-sesman.log`.

## "Authentication is required to create a color managed device"

Darum kümmert sich die polkit-Regel aus dem Schritt `rdp`. Prüfe mit `id`, ob dein Benutzer in der Gruppe `users` ist, und verbinde dich neu.

## RDP-Verbindung klappt überhaupt nicht

```bash
sudo ss -tlnp | grep xrdp      # lauscht xrdp auf 53389?
sudo ufw status                # ist der Port freigegeben?
```

Auch dein Cloud-Anbieter hat vielleicht eine eigene Firewall vor dem Server.

## Aus SSH ausgesperrt

Der Schritt `ssh` schaltet die Passwort-Anmeldung nur ab, wenn dein Benutzer einen Schlüssel hat. Passiert es trotzdem, geh über die Web-Konsole deines Anbieters auf den Server und führe aus:

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

Der native Installer legt das Programm in `~/.local/bin` ab. Ubuntu nimmt den Ordner beim Anmelden in den `PATH` auf, sobald er existiert. Melde dich also ab und wieder an, oder führe `source ~/.profile` aus.

## `claude-vps sync` meldet "Not possible to fast-forward"

Der Klon auf dem Server hat lokale Änderungen. Der Server soll aber nur Änderungen holen:

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## Alte Datei wiederherstellen

Jedes `apply` sichert die Dateien, die es überschreibt:

```bash
ls ~/.local/state/claude-vps/
```
