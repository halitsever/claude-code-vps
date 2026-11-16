---
title: "Come installare Claude Code su un VPS, guida completa"
description: "Guida passo passo per usare Claude Code su un VPS Ubuntu. SSH sicuro, sessioni tmux che non muoiono, notifiche sul telefono e desktop KDE Plasma via RDP."
---

# Come usare Claude Code su un VPS

Questa è la versione completa e manuale del mio setup: un server Ubuntu economico che fa girare Claude Code giorno e notte. Mi ci collego via SSH da ovunque e, quando mi serve uno schermo vero, tramite un desktop KDE Plasma in RDP.

Ogni comando qui sotto è quello che [`claude-vps setup`](/it/guide/getting-started) esegue al posto tuo. Leggi questa pagina per capire cosa succede, o per fare tutto a mano.

## Perché usare Claude Code su un VPS

- **Continua a lavorare quando il portatile va in standby.** Refactoring lunghi, test e migrazioni finiscono mentre sei via.
- **La tua macchina resta pulita.** Gli agenti installano pacchetti, avviano Docker e tirano su server di sviluppo su una macchina che puoi cancellare e ricostruire in dieci minuti.
- **Lo stesso ambiente ovunque.** Portatile, fisso, tablet o telefono: ti colleghi alla stessa sessione tmux e allo stesso desktop.
- **Rete veloce**, vicina al tuo host git e ai registri dei pacchetti.

## Scegli un server

| Uso | vCPU | RAM | Disco |
| --- | --- | --- | --- |
| Solo terminale | 2 | 4 GB | 40 GB |
| Con desktop KDE | 4 | 8 GB | 80 GB |
| Più agenti più Docker | 8 | 16 GB | 160 GB |

Va bene qualsiasi provider che offra Ubuntu 24.04 LTS o successivo: Hetzner, DigitalOcean, OVH, Vultr, Linode, AWS Lightsail, oppure una macchina inutilizzata a casa. Scegli una regione vicina a te per un RDP più reattivo. Aggiungi la tua chiave SSH pubblica quando crei il server, così non ti servirà mai la password di root.

## 1. Primo accesso e aggiornamenti

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades` installa da solo le patch di sicurezza, cosa importante su una macchina sempre online.

Sui server piccoli aggiungi lo swap, così un agente impegnato non fa scattare l'OOM killer:

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. Crea il tuo utente

Non far girare Claude Code come root. Dagli un utente normale con sudo:

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

Apri un secondo terminale e verifica che `ssh dev@<server-ip>` funzioni prima di proseguire.

## 3. Blinda SSH

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd usa il primo valore che legge, e i file vengono caricati in ordine di nome. Per questo il nome inizia con `10-`: deve venire prima del `50-cloud-init.conf` che molte immagini cloud includono con `PasswordAuthentication yes`.

## 4. Firewall

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # solo se vuoi l'RDP da internet, vedi sotto
ufw --force enable
```

## 5. Installa Claude Code

Accedi con il tuo utente e usa l'installer nativo. Non richiede Node.js e si aggiorna da solo:

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

Finisce in `~/.local/bin/claude`. Esci e rientra una volta perché quella cartella sia nel `PATH`, poi verifica:

```bash
claude --version
```

## 6. Accedere su un server senza schermo

Sul server non c'è un browser, e non serve:

```bash
claude
```

Claude Code stampa un URL. Aprilo sul tuo computer o sul telefono, approva e incolla il codice nel terminale. La sessione viene salvata in `~/.claude` sul server.

Se usi una chiave API Anthropic invece di un piano Pro o Max, mettila nel profilo della shell:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## 7. Tieni vive le sessioni con tmux

Se Claude gira direttamente nella sessione SSH, chiudere il portatile lo uccide. Avvialo dentro tmux:

```bash
tmux new -s claude
claude
# Ctrl-b poi d per staccarti, l'agente continua
tmux attach -t claude   # più tardi, da qualsiasi dispositivo
```

Un piccolo `~/.tmux.conf` lo rende più comodo:

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Ricevi un avviso quando Claude ha bisogno di te

Claude Code lancia un hook `Notification` quando aspetta un tuo input. Mandalo al telefono con [ntfy.sh](https://ntfy.sh):

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude ti sta aspettando"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
EOF
chmod +x ~/.claude/hooks/notify.sh
echo my-hard-to-guess-topic > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
```

Registralo in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

Iscriviti allo stesso topic nell'app ntfy. Tratta il topic come una password.

## 9. Facoltativo: un desktop KDE Plasma via RDP

Il terminale copre quasi tutto il lavoro. Un desktop aiuta quando vuoi Chrome accanto all'agente, un file manager o più finestre di Konsole su uno schermo grande.

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

Su Ubuntu 24.04 `plasma-session-x11` e `kwin-x11` non esistono come pacchetti separati. Toglili dal comando.

Di' a xrdp di avviare Plasma per il tuo utente:

```bash
cat > ~/.xsession <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
sudo systemctl restart xrdp
```

Poi elimina la richiesta di password sui profili colore, che altrimenti compare a ogni accesso:

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

Collega qualsiasi client RDP a `<server-ip>:53389`. Trovi di più in [Desktop remoto](/it/guide/remote-desktop), compreso come tenere chiusa la porta e passare da un tunnel SSH.

## 10. Strumenti di sviluppo

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## Checklist di sicurezza

- SSH solo con chiave, login root con password disattivato
- Firewall attivo, solo le porte che servono
- Claude Code gira con un utente normale, non root
- `--dangerously-skip-permissions` solo in container usa e getta, mai su una macchina con i tuoi token e le tue chiavi SSH
- I segreti (`~/.claude/.credentials.json`, chiavi API, topic ntfy) non finiscono mai in un repository pubblico
- Aggiornamenti automatici attivi

## Fai tutto con un comando

Tutto quanto sopra, più l'applicazione della tua configurazione KDE e Claude, è ciò che claude-vps automatizza:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Vedi [Per iniziare](/it/guide/getting-started).

## FAQ

### Claude Code può girare su un server senza interfaccia grafica?

Sì. È un'app da terminale. L'accesso passa da un link che apri su qualsiasi altro dispositivo.

### Quale piano Claude serve?

Qualsiasi piano che includa Claude Code (Pro o Max), oppure una chiave API Anthropic a consumo.

### Quanto costa un VPS per Claude Code?

Il server costa di solito da 5 a 20 USD al mese per 4 o 8 GB di RAM presso i provider economici. L'uso di Claude si paga a parte, in base al piano o alla chiave API.

### Claude continua a girare se chiudo SSH?

Solo dentro tmux (o screen). Avvialo con `tmux new -s claude`, staccati con `Ctrl-b d`.

### È sicuro?

Quanto qualsiasi server che gestisci da solo. Segui la checklist qui sopra e tieni l'agente lontano dalle credenziali che non gli servono.
