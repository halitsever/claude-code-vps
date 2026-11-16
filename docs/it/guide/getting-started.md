---
description: "Installa claude-vps su un VPS Ubuntu 24.04 o 26.04 con un solo comando: Claude Code, KDE Plasma via RDP e SSH blindato in circa dieci minuti."
---

# Per iniziare

claude-vps trasforma un server Ubuntu appena installato nella macchina su cui faccio girare Claude Code: un utente sudo, SSH solo con chiave, un firewall, un desktop KDE Plasma raggiungibile via RDP, Docker, Chrome e Claude Code stesso, con le mie impostazioni, i miei hook e il mio layout KDE già applicati.

## Cosa serve

| | |
| --- | --- |
| **OS** | Ubuntu 24.04 LTS o successivo (io uso la 26.04) |
| **CPU / RAM** | 2 vCPU e 4 GB sono il minimo per Plasma. Con 4 vCPU / 8 GB sembra un vero desktop |
| **Disco** | 25 GB o più |
| **Accesso** | Root via SSH, meglio se la tua chiave SSH è già sul server |
| **Architettura** | Su amd64 c'è tutto. arm64 funziona, ma senza Chrome |

Ti serve anche un piano Claude Pro o Max, oppure una API key di Anthropic, per fare il login in Claude Code alla fine.

## Installazione

Entra via SSH come root (o con un utente sudo) e lancia:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Lo script clona questo repo in `/opt/claude-vps` ed esegue `claude-vps setup`. Ti vengono chieste due cose: il nome utente della workstation e la sua password (serve per sudo e per il login RDP). Se lasci la password vuota, ne viene generata una e te la mostra alla fine.

Per saltare le domande, passa le opzioni dopo `bash -s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

Tutte le opzioni sono nel [riferimento della CLI](/it/reference/cli).

::: tip Prima fai una prova
`--dry-run` stampa tutti i comandi senza eseguirli.
:::

## A fine installazione

Ottieni un riepilogo come questo:

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **Entra via SSH** con il nuovo utente. Le chiavi SSH di root sono state copiate, quindi funziona la stessa chiave.
2. **Avvia Claude Code** dentro tmux e fai il login. Vedi [Usare Claude Code](/it/guide/claude-code).
3. **Apri il desktop** con un qualsiasi client RDP. Vedi [Desktop remoto](/it/guide/remote-desktop).

## Usare la tua configurazione

Di default il server riceve la mia configurazione KDE e Claude da `dotfiles/home`. Per usare la tua, fai un fork del repo, lancia `claude-vps capture` sulla tua macchina, fai push e punta l'installer al tuo fork:

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

[Tenere la configurazione sincronizzata](/it/guide/sync) spiega tutto il giro.
