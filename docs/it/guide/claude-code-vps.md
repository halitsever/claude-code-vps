---
title: "Installare Claude Code su un VPS: la guida completa"
description: "Guida passo passo per installare Claude Code su un VPS Ubuntu: SSH sicuro, sessioni tmux che restano attive, notifiche sul telefono e desktop KDE in RDP."
---

# Installare Claude Code su un VPS

Questa pagina descrive la mia installazione completa, passo per passo, a mano. Uso un server Ubuntu economico che fa girare Claude Code giorno e notte. Mi collego in SSH da qualsiasi posto. Quando mi serve uno schermo vero, apro un desktop KDE Plasma in RDP.

Tutti i comandi qui sotto sono quelli che [`claude-vps setup`](/it/guide/getting-started) esegue per te. Leggi questa pagina per capire cosa succede, oppure per fare tutto da solo.

## Perché usare Claude Code su un VPS

- **Il lavoro va avanti anche quando il portatile è in standby.** Refactoring lunghi, test e migrazioni finiscono mentre sei via.
- **Il tuo computer resta pulito.** Gli agenti installano pacchetti, avviano Docker e server di sviluppo su una macchina che puoi cancellare e reinstallare in dieci minuti.
- **Lo stesso ambiente ovunque.** Da portatile, PC, tablet o telefono ritrovi la stessa sessione tmux e lo stesso desktop.
- **Una rete veloce**, vicina al tuo hosting git e ai registri dei pacchetti.

## Scegliere un server

| Uso | vCPU | RAM | Disco |
| --- | --- | --- | --- |
| Solo terminale | 2 | 4 GB | 40 GB |
| Con il desktop KDE | 4 | 8 GB | 80 GB |
| Più agenti e Docker | 8 | 16 GB | 160 GB |

Va bene qualsiasi provider che offre Ubuntu 24.04 LTS o successivo: Hetzner, DigitalOcean, OVH, Vultr, Linode, AWS Lightsail, oppure un computer inutilizzato a casa. Scegli una regione vicina a te, così il desktop RDP risponde più in fretta. Aggiungi la tua chiave SSH pubblica quando crei il server: non ti servirà mai la password di root.

## 1. Primo accesso e aggiornamenti

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades` installa da solo le patch di sicurezza. È importante su una macchina sempre online.

Su un server piccolo aggiungi lo swap. Altrimenti un agente che usa molta memoria può far scattare l'OOM killer:

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. Creare il tuo utente

Non eseguire Claude Code come root. Crea un utente normale con sudo:

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

Prima di andare avanti, apri un secondo terminale e controlla che `ssh dev@<server-ip>` funzioni.

## 3. Mettere in sicurezza SSH

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd usa il primo valore che legge, e legge i file in ordine alfabetico. Per questo il nome inizia con `10-`: deve venire prima di `50-cloud-init.conf`. Molte immagini cloud includono quel file con `PasswordAuthentication yes`.

## 4. Firewall

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # solo se vuoi RDP da internet, vedi sotto
ufw --force enable
```

## 5. Installare Claude Code

Accedi con il tuo utente e usa l'installer ufficiale. Non richiede Node.js e si aggiorna da solo:

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

Il programma viene installato in `~/.local/bin/claude`. Esci e rientra una volta, così quella cartella finisce nel tuo `PATH`. Poi controlla:

```bash
claude --version
```

## 6. Accedere da un server senza schermo

Sul server non c'è un browser, e non ti serve:

```bash
claude
```

Claude Code mostra un URL. Aprilo sul tuo computer o sul telefono, conferma e incolla il codice nel terminale. La sessione viene salvata in `~/.claude` sul server.

Se usi una chiave API Anthropic invece di un piano Pro o Max, aggiungila al profilo della shell:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

Con una chiave API Claude Code funziona, ma [Remote Control](https://code.claude.com/docs/it/remote-control), cioè guidare la sessione dall'app Claude o da claude.ai, richiede l'accesso con claude.ai.

## 7. Tenere attive le sessioni con tmux

Se Claude gira direttamente nella sessione SSH, si ferma quando chiudi il portatile. Avvialo dentro tmux:

```bash
tmux new -s claude
claude
# Ctrl-b e poi d per staccarti, l'agente continua a lavorare
tmux attach -t claude   # più tardi, da qualsiasi dispositivo
```

Un piccolo `~/.tmux.conf` rende tmux più comodo:

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Ricevere un avviso quando Claude ha bisogno di te

Quando Claude Code aspetta una risposta, attiva un hook `Notification`. Mandalo al telefono con [ntfy.sh](https://ntfy.sh):

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude aspetta una tua risposta"')
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

Iscriviti allo stesso topic nell'app ntfy. Tieni segreto il nome del topic, come una password.

## 9. Facoltativo: un desktop KDE Plasma in RDP

Per quasi tutto basta il terminale. Un desktop è comodo quando vuoi Chrome accanto all'agente, un file manager o più finestre di Konsole su uno schermo grande.

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

Su Ubuntu 24.04, `plasma-session-x11` e `kwin-x11` non esistono come pacchetti separati. Toglili dal comando.

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

Poi elimina la richiesta di password per i profili colore. Senza questo passaggio, compare a ogni accesso:

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

Collega qualsiasi client RDP a `<server-ip>:53389`. Nella pagina [Desktop remoto](/it/guide/remote-desktop) trovi altri dettagli, anche su come tenere chiusa la porta e passare da un tunnel SSH.

## 10. Strumenti di sviluppo

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## Checklist di sicurezza

- SSH solo con chiave, accesso root con password disattivato
- Firewall attivo, solo con le porte che servono
- Claude Code gira con un utente normale, non come root
- `--dangerously-skip-permissions` solo in container usa e getta, mai su una macchina con i tuoi token e le tue chiavi SSH
- I segreti (`~/.claude/.credentials.json`, chiavi API, topic ntfy) non finiscono mai in un repository pubblico
- Aggiornamenti automatici attivi

## Tutto con un solo comando

claude-vps automatizza tutto quello che hai letto sopra e applica anche le tue impostazioni di KDE e Claude:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Vedi [Per iniziare](/it/guide/getting-started).

## Domande frequenti

### Claude Code funziona su un server senza interfaccia grafica?

Sì. È un programma da terminale. Per l'accesso apri un link su un qualsiasi altro dispositivo.

### Quale piano Claude serve?

Un piano che includa Claude Code (Pro o Max), oppure una chiave API Anthropic pagata a consumo.

### Quanto costa un VPS per Claude Code?

Dai provider economici, un server con 4-8 GB di RAM costa di solito tra 5 e 20 USD al mese. L'uso di Claude si paga a parte, con il tuo piano o la tua chiave API.

### Claude continua a girare dopo che chiudo SSH?

Solo dentro tmux (o screen). Avvialo con `tmux new -s claude` e staccati con `Ctrl-b d`.

### È sicuro?

Quanto qualsiasi altro server che gestisci da solo. Segui la checklist qui sopra e non dare all'agente accessi che non gli servono.
