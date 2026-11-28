---
description: "Ogni passaggio che claude-vps esegue sul tuo server Ubuntu: pacchetti, swap, SSH, ufw, KDE Plasma, xrdp, Docker, Chrome, Claude Code e i tuoi dotfile."
---

# Cosa viene installato

`claude-vps setup` esegue nove passaggi, in ordine. Ogni passaggio è una semplice funzione bash in [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh). Puoi quindi leggere esattamente cosa viene eseguito sul tuo server. Per saltare un passaggio usa `--skip`. Per eseguirne solo alcuni usa `--only`.

## 1. base

- `apt upgrade` su tutto il sistema
- `git curl jq ripgrep fd-find tmux htop build-essential python3` e qualche altro strumento
- Node.js 20 o più recente. Su Ubuntu 24.04 apt ha solo la 18, quindi lì arriva dal repository NodeSource
- `unattended-upgrades` attivo: le patch di sicurezza si installano senza di te
- un file di swap da 4 GB se il server non ha swap e ha meno di 8 GB di RAM. Così Plasma e qualche agente non fanno scattare l'OOM killer
- il fuso orario, se passi `--timezone`

## 2. user

Crea il tuo utente, lo aggiunge al gruppo `sudo` e gli copia `/root/.ssh/authorized_keys` se non ha ancora una chiave. La password che scegli è quella che inserisci all'accesso RDP.

## 3. ssh

Scrive il file `/etc/ssh/sshd_config.d/10-claude-vps.conf`:

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd tiene il primo valore che legge. Per questo il nome del file inizia con `10-`: così viene prima di `50-cloud-init.conf`, presente nella maggior parte delle immagini cloud. Se il tuo utente non ha ancora una chiave SSH, il passaggio viene saltato con un avviso. Così non resti mai chiuso fuori.

## 4. firewall

`ufw` permette OpenSSH e la porta RDP e chiude tutto il resto. Con `--rdp-private` la porta RDP resta chiusa e ti colleghi tramite un tunnel SSH.

## 5. desktop

Installa `kde-plasma-desktop` e la sessione X11 (`plasma-session-x11` e `kwin-x11` su Ubuntu 25.10 e successivi), Konsole, Dolphin, Kate, Spectacle e i font Noto e JetBrains Mono. SDDM viene disattivato e il target predefinito diventa `multi-user`. Nessuno sta seduto davanti a un server: si avvia quindi su una console, e Plasma parte solo quando ti colleghi.

::: info Perché X11
xrdp gestisce una sessione Xorg. Plasma 6 offre ancora una sessione X11 su Ubuntu da 24.04 a 26.04, ed è quella che uso ogni giorno in RDP.
:::

## 6. rdp

- `xrdp` e `xorgxrdp`, sulla porta **53389** (si cambia con `--rdp-port`)
- un file `~/.xsession` che avvia `startplasma-x11` con le variabili `XDG_*` giuste
- una regola polkit che elimina la richiesta "authentication is required to create a color managed device". Senza questa regola, la richiesta compare a ogni accesso

## 7. apps

- Docker (`docker.io`, compose v2, buildx), con il tuo utente nel gruppo `docker`
- GitHub CLI (`gh`)
- Google Chrome dal repository apt di Google (amd64 e arm64). Utile quando Claude ha bisogno di un browser vero

## 8. claude

- Claude Code con l'installer ufficiale, in `~/.local/bin/claude`. Si aggiorna da solo
- [claudegrid](https://github.com/halitsever/claudegrid) dall'ultima release `.deb`, per aprire una griglia di agenti Claude Code in Konsole o tmux con un solo comando. Aggiunge anche un profilo Konsole e una voce nel menu delle applicazioni
- il tuo topic ntfy.sh in `~/.claude/ntfy-topic`, se ne indichi uno. L'hook delle notifiche lo legge da lì

## 9. dotfiles

Assegna `/opt/claude-vps` al tuo utente, crea un link a `claude-vps` in `/usr/local/bin` ed esegue `claude-vps apply` con il tuo utente. Questo comando copia tutto il contenuto di `dotfiles/home` nella tua cartella home: configurazione di KDE, profili Konsole, `~/.claude/settings.json`, `CLAUDE.md`, hook, `.tmux.conf`.

## Rieseguire i passaggi

Ogni passaggio controlla prima cosa c'è già. Puoi quindi rieseguirli senza rischi:

```bash
sudo claude-vps setup --only desktop,rdp     # per esempio dopo un aggiornamento di versione di Ubuntu
sudo claude-vps setup --skip apps            # tutto tranne Docker e Chrome
sudo claude-vps setup --no-desktop           # server senza desktop, solo terminale
```
