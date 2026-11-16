# Cosa viene installato

`claude-vps setup` esegue nove passaggi in ordine. Ognuno è una semplice funzione bash in [`lib/setup.sh`](https://github.com/halitsever/claude-vps/blob/main/lib/setup.sh), così puoi leggere esattamente cosa gira sul tuo server. Puoi saltarne qualcuno con `--skip`, o eseguirne solo alcuni con `--only`.

## 1. base

- `apt upgrade` di tutto
- `git curl jq ripgrep fd-find tmux htop build-essential nodejs npm python3` e compagnia
- `unattended-upgrades` attivo, così le patch di sicurezza arrivano senza di te
- uno swapfile da 4 GB se il server non ha swap e ha meno di 8 GB di RAM, così Plasma e qualche agente non finiscono sotto l'OOM killer
- il fuso orario, se passi `--timezone`

## 2. user

Crea l'utente della workstation, lo aggiunge a `sudo` e gli copia `/root/.ssh/authorized_keys` se non ne ha già uno. La password che scegli è quella da inserire nella schermata di login RDP.

## 3. ssh

Scrive `/etc/ssh/sshd_config.d/10-claude-vps.conf`:

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd tiene il primo valore che legge, ed è per questo che il nome del file inizia con `10-`: vince sul `50-cloud-init.conf` che quasi tutte le immagini cloud includono. Se il tuo utente non ha ancora una chiave SSH, il passaggio viene saltato con un avviso, così non resti mai chiuso fuori.

## 4. firewall

`ufw` con OpenSSH e la porta RDP aperte, tutto il resto chiuso. Passa `--rdp-private` per tenere chiusa la porta RDP e raggiungerla tramite un tunnel SSH.

## 5. desktop

`kde-plasma-desktop` più la sessione X11 (`plasma-session-x11`, `kwin-x11` su Ubuntu 25.10+), Konsole, Dolphin, Kate, Spectacle, i font Noto e JetBrains Mono. SDDM viene disattivato e il target di default impostato su `multi-user`: davanti a un server non si siede nessuno, quindi si avvia direttamente in console e Plasma parte solo quando ti colleghi.

::: info Perché X11
xrdp gestisce una sessione Xorg. Plasma 6 offre ancora una sessione X11 da Ubuntu 24.04 a 26.04, ed è quella che uso tutti i giorni via RDP.
:::

## 6. rdp

- `xrdp` e `xorgxrdp`, in ascolto sulla porta **53389** (la cambi con `--rdp-port`)
- un `~/.xsession` che avvia `startplasma-x11` con le variabili `XDG_*` giuste
- una regola polkit che elimina la richiesta "authentication is required to create a color managed device" che altrimenti compare a ogni login

## 7. apps

- Docker (`docker.io`, compose v2, buildx), con il tuo utente nel gruppo `docker`
- GitHub CLI (`gh`)
- Google Chrome dal repository apt di Google (solo amd64), comodo quando Claude ha bisogno di un browser vero

## 8. claude

- Claude Code tramite l'installer nativo ufficiale, in `~/.local/bin/claude`. Si aggiorna da solo
- il tuo topic ntfy.sh in `~/.claude/ntfy-topic` se ne indichi uno, letto dall'hook di notifica

## 9. dotfiles

Assegna `/opt/claude-vps` al tuo utente, crea il link di `claude-vps` in `/usr/local/bin` ed esegue `claude-vps apply` con il tuo utente. Questo scrive tutto quello che c'è sotto `dotfiles/home` nella tua home: configurazione KDE, profili di Konsole, `~/.claude/settings.json`, `CLAUDE.md`, hook, `.tmux.conf`.

## Rieseguire i passaggi

Ogni passaggio controlla prima cosa c'è già, quindi rilanciarlo è sicuro:

```bash
sudo claude-vps setup --only desktop,rdp     # e.g. after a release upgrade
sudo claude-vps setup --skip apps            # everything except Docker and Chrome
sudo claude-vps setup --no-desktop           # terminal-only box
```
