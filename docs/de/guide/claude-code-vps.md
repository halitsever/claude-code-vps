---
title: "Claude Code auf einem VPS betreiben"
description: "Anleitung Schritt für Schritt: Claude Code auf einem Ubuntu-VPS mit sicherem SSH, dauerhaften tmux-Sitzungen, Handy-Benachrichtigungen und KDE über RDP."
---

# Claude Code auf einem VPS betreiben

Hier steht mein Setup komplett zum Nachbauen von Hand. Ein günstiger Ubuntu-Server lässt Claude Code rund um die Uhr laufen. Ich verbinde mich von überall per SSH. Wenn ich einen richtigen Bildschirm brauche, nutze ich einen KDE-Plasma-Desktop über RDP.

Jeden Befehl auf dieser Seite führt [`claude-vps setup`](/de/guide/getting-started) auch automatisch aus. Lies die Seite, um zu verstehen, was passiert, oder um alles selbst zu machen.

## Warum Claude Code auf einem VPS

- **Es arbeitet weiter, wenn dein Laptop schläft.** Lange Refactorings, Testläufe und Migrationen laufen durch, während du weg bist.
- **Dein eigener Rechner bleibt sauber.** Agenten installieren Pakete, starten Docker und Dev-Server. Das passiert auf einer Maschine, die du in zehn Minuten neu aufsetzen kannst.
- **Überall dieselbe Umgebung.** Ob Laptop, PC, Tablet oder Handy: Du landest in derselben tmux-Sitzung und auf demselben Desktop.
- **Schnelles Netz**, nah an deinem Git-Hoster und den Paketquellen.

## Den Server wählen

| Einsatz | vCPU | RAM | Festplatte |
| --- | --- | --- | --- |
| Nur Terminal | 2 | 4 GB | 40 GB |
| Mit KDE-Desktop | 4 | 8 GB | 80 GB |
| Mehrere Agenten und Docker | 8 | 16 GB | 160 GB |

Jeder Anbieter mit Ubuntu 24.04 LTS oder neuer funktioniert: Hetzner, DigitalOcean, OVH, Vultr, Linode, AWS Lightsail oder ein freier Rechner zu Hause. Wähle ein Rechenzentrum in deiner Nähe, dann reagiert RDP schneller. Hinterlege beim Anlegen des Servers deinen öffentlichen SSH-Schlüssel, dann brauchst du nie ein root-Passwort.

## 1. Erste Anmeldung und Updates

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades` spielt Sicherheitsupdates selbst ein. Das ist wichtig, weil der Server ständig online ist.

Kleine Server brauchen Swap. Sonst beendet der OOM-Killer Prozesse, wenn ein Agent viel Speicher braucht:

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. Eigenen Benutzer anlegen

Lass Claude Code nicht als root laufen. Lege einen normalen Benutzer mit sudo-Rechten an:

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

Öffne ein zweites Terminal und prüfe, ob `ssh dev@<server-ip>` klappt, bevor du weitermachst.

## 3. SSH absichern

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd nimmt den ersten Wert, den es liest, und lädt die Dateien in alphabetischer Reihenfolge. Deshalb beginnt der Name mit `10-`. Die Datei muss vor `50-cloud-init.conf` kommen, denn viele Cloud-Images setzen dort `PasswordAuthentication yes`.

## 4. Firewall

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # nur wenn RDP aus dem Internet erreichbar sein soll, siehe unten
ufw --force enable
```

## 5. Claude Code installieren

Melde dich als dein Benutzer an und nutze den nativen Installer. Er braucht kein Node.js und aktualisiert sich selbst:

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

Claude Code landet in `~/.local/bin/claude`. Melde dich einmal ab und wieder an, damit der Ordner im `PATH` steht. Dann prüfe:

```bash
claude --version
```

## 6. Anmelden ohne Browser auf dem Server

Auf dem Server gibt es keinen Browser, und du brauchst auch keinen:

```bash
claude
```

Claude Code zeigt eine URL an. Öffne sie auf deinem eigenen Rechner oder Handy, bestätige und füge den Code im Terminal ein. Die Anmeldung wird auf dem Server in `~/.claude` gespeichert.

Nutzt du statt eines Pro- oder Max-Plans einen Anthropic-API-Schlüssel, trag ihn in dein Shell-Profil ein:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## 7. Sitzungen mit tmux am Leben halten

Läuft Claude direkt in deiner SSH-Sitzung, ist es weg, sobald du den Laptop zuklappst. Starte es deshalb in tmux:

```bash
tmux new -s claude
claude
# Strg-b, dann d zum Trennen. Der Agent läuft weiter
tmux attach -t claude   # später, von jedem Gerät aus
```

Eine kleine `~/.tmux.conf` macht die Arbeit angenehmer:

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Nachricht bekommen, wenn Claude dich braucht

Wartet Claude Code auf eine Eingabe, löst es den Hook `Notification` aus. Den kannst du mit [ntfy.sh](https://ntfy.sh) aufs Handy schicken:

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude wartet auf dich"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
EOF
chmod +x ~/.claude/hooks/notify.sh
echo my-hard-to-guess-topic > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
```

Trag den Hook in `~/.claude/settings.json` ein:

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

Abonniere in der ntfy-App dasselbe Topic. Behandle das Topic wie ein Passwort.

## 9. Optional: KDE-Plasma-Desktop über RDP

Für die meiste Arbeit reicht das Terminal. Ein Desktop hilft, wenn du Chrome neben dem Agenten offen haben willst, einen Dateimanager brauchst oder mehrere Konsole-Fenster auf einem großen Bildschirm.

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

Unter Ubuntu 24.04 gibt es `plasma-session-x11` und `kwin-x11` nicht als eigene Pakete. Lass sie dort einfach weg.

Sag xrdp, dass es für deinen Benutzer Plasma starten soll:

```bash
cat > ~/.xsession <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
sudo systemctl restart xrdp
```

Ohne den nächsten Schritt fragt Plasma bei jeder Anmeldung nach einem Passwort für Farbprofile. So schaltest du das ab:

```bash
sudo tee /etc/polkit-1/rules.d/45-colord.rules >/dev/null <<'EOF'
polkit.addRule(function (action, subject) {
  if (action.id.indexOf("org.freedesktop.color-manager.") === 0 && subject.isInGroup("users")) {
    return polkit.Result.YES;
  }
});
EOF
sudo usermod -aG users dev
```

Verbinde dich mit einem beliebigen RDP-Client mit `<server-ip>:53389`. Mehr dazu unter [Remote-Desktop](/de/guide/remote-desktop), auch wie du den Port geschlossen lässt und über einen SSH-Tunnel gehst.

## 10. Entwickler-Tools

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## Sicherheits-Checkliste

- SSH nur mit Schlüssel, keine Passwort-Anmeldung für root
- Firewall an, nur die nötigen Ports offen
- Claude Code läuft als normaler Benutzer, nicht als root
- `--dangerously-skip-permissions` nur in Wegwerf-Containern, nie auf einem Server mit deinen Tokens und SSH-Schlüsseln
- Geheimnisse (`~/.claude/.credentials.json`, API-Schlüssel, ntfy-Topic) kommen nie in ein öffentliches Repo
- Automatische Updates an

## Alles mit einem Befehl

Alles oben, plus deine eigenen KDE- und Claude-Einstellungen, erledigt claude-vps automatisch:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Siehe [Erste Schritte](/de/guide/getting-started).

## FAQ

### Läuft Claude Code auf einem Server ohne grafische Oberfläche?

Ja. Es ist ein Terminal-Programm. Die Anmeldung läuft über einen Link, den du auf einem anderen Gerät öffnest.

### Welchen Claude-Plan brauche ich?

Jeden Plan, der Claude Code enthält (Pro oder Max), oder einen Anthropic-API-Schlüssel, der nach Verbrauch abgerechnet wird.

### Was kostet ein VPS für Claude Code?

Bei günstigen Anbietern kostet ein Server mit 4 bis 8 GB RAM meist 5 bis 20 USD im Monat. Die Nutzung von Claude zahlst du getrennt über deinen Plan oder API-Schlüssel.

### Läuft Claude weiter, wenn ich SSH schließe?

Nur in tmux (oder screen). Starte es mit `tmux new -s claude` und trenne dich mit `Strg-b d`.

### Ist das sicher?

So sicher wie jeder Server, den du selbst betreibst. Halte dich an die Checkliste oben und gib dem Agenten keinen Zugriff auf Zugangsdaten, die er nicht braucht.
