---
description: "Jeder Schritt, den claude-vps auf deinem Ubuntu-Server ausführt: Pakete, Swap, SSH, ufw, KDE Plasma, xrdp, Docker, Chrome, Claude Code und Dotfiles."
---

# Was installiert wird

`claude-vps setup` führt neun Schritte nacheinander aus. Jeder ist eine einfache Bash-Funktion in [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh). Du kannst also genau nachlesen, was auf deinem Server läuft. Mit `--skip` lässt du Schritte aus, mit `--only` führst du nur bestimmte aus.

## 1. base

- `apt upgrade` für alle Pakete
- `git curl jq ripgrep fd-find tmux htop build-essential nodejs npm python3` und ein paar weitere
- `unattended-upgrades` wird aktiviert, damit Sicherheitsupdates ohne dein Zutun eingespielt werden
- eine Swap-Datei mit 4 GB, wenn der Server keinen Swap und weniger als 8 GB RAM hat. So beendet der OOM-Killer weder Plasma noch deine Agenten
- die Zeitzone, wenn du `--timezone` angibst

## 2. user

Legt deinen Benutzer an, fügt ihn zur Gruppe `sudo` hinzu und kopiert `/root/.ssh/authorized_keys` zu ihm, falls er noch keine Schlüssel hat. Das Passwort, das du wählst, gibst du später beim RDP-Login ein.

## 3. ssh

Schreibt `/etc/ssh/sshd_config.d/10-claude-vps.conf`:

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd nimmt den ersten Wert, den es liest. Deshalb beginnt der Dateiname mit `10-`: So hat die Datei Vorrang vor der `50-cloud-init.conf`, die die meisten Cloud-Images mitbringen. Hat dein Benutzer noch keinen SSH-Schlüssel, wird der Schritt mit einer Warnung übersprungen. So sperrst du dich nie selbst aus.

## 4. firewall

`ufw` lässt OpenSSH und den RDP-Port durch und blockiert alles andere. Mit `--rdp-private` bleibt auch RDP zu, und du erreichst es über einen SSH-Tunnel.

## 5. desktop

`kde-plasma-desktop` mit der X11-Sitzung (`plasma-session-x11`, `kwin-x11` ab Ubuntu 25.10), dazu Konsole, Dolphin, Kate, Spectacle und die Schriften Noto und JetBrains Mono. SDDM wird abgeschaltet und das Standard-Target auf `multi-user` gesetzt. Vor einem Server sitzt niemand, er startet also direkt in die Konsole. Plasma startet erst, wenn du dich verbindest.

::: info Warum X11
xrdp steuert eine Xorg-Sitzung. Plasma 6 hat unter Ubuntu 24.04 bis 26.04 noch eine X11-Sitzung, und die nutze ich jeden Tag über RDP.
:::

## 6. rdp

- `xrdp` und `xorgxrdp` auf Port **53389** (änderbar mit `--rdp-port`)
- eine `~/.xsession`, die `startplasma-x11` mit den passenden `XDG_*`-Variablen startet
- eine polkit-Regel, die die Abfrage "authentication is required to create a color managed device" abstellt. Ohne sie kommt sie bei jeder Anmeldung

## 7. apps

- Docker (`docker.io`, compose v2, buildx), dein Benutzer kommt in die Gruppe `docker`
- GitHub CLI (`gh`)
- Google Chrome aus Googles apt-Quelle (nur amd64). Praktisch, wenn Claude einen echten Browser braucht

## 8. claude

- Claude Code über den offiziellen nativen Installer nach `~/.local/bin/claude`. Es aktualisiert sich selbst
- dein ntfy.sh-Topic in `~/.claude/ntfy-topic`, falls du eins angibst. Der Benachrichtigungs-Hook liest es von dort

## 9. dotfiles

Übergibt `/opt/claude-vps` an deinen Benutzer, verlinkt `claude-vps` nach `/usr/local/bin` und führt `claude-vps apply` als dein Benutzer aus. Dabei landet alles aus `dotfiles/home` in deinem Home-Verzeichnis: KDE-Einstellungen, Konsole-Profile, `~/.claude/settings.json`, `CLAUDE.md`, Hooks und `.tmux.conf`.

## Schritte erneut ausführen

Jeder Schritt prüft zuerst, was schon da ist. Du kannst ihn also gefahrlos noch einmal starten:

```bash
sudo claude-vps setup --only desktop,rdp     # z. B. nach einem Release-Upgrade
sudo claude-vps setup --skip apps            # alles außer Docker und Chrome
sudo claude-vps setup --no-desktop           # Server nur mit Terminal
```
