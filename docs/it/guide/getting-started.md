---
description: "Installa claude-vps su un VPS Ubuntu 24.04 o 26.04 con un solo comando. Claude Code, KDE Plasma in RDP e SSH sicuro sono pronti in circa dieci minuti."
---

# Per iniziare

claude-vps prende un server Ubuntu appena creato e lo trasforma nella macchina su cui uso Claude Code. Installa un utente con sudo, SSH solo con chiave, un firewall, un desktop KDE Plasma a cui ti colleghi in RDP, Docker, Chrome e Claude Code. Le mie impostazioni, i miei hook e il mio layout KDE sono già applicati.

## Cosa ti serve

| | |
| --- | --- |
| **Sistema** | Ubuntu 24.04 LTS o successivo (io uso la 26.04) |
| **CPU / RAM** | Almeno 2 vCPU e 4 GB per Plasma. Con 4 vCPU e 8 GB lavori come su un vero computer |
| **Disco** | 25 GB o più |
| **Accesso** | root via SSH, meglio se la tua chiave SSH è già sul server |
| **Architettura** | Su amd64 e su arm64 viene installato tutto |

Ti serve anche un piano Claude Pro o Max, oppure una chiave API Anthropic, per accedere poi a Claude Code.

## Installazione

Collegati in SSH come root (o con un utente che ha sudo) ed esegui:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Lo script clona questo repository in `/opt/claude-vps` ed esegue `claude-vps setup`. Ti fa due domande: il nome del tuo utente e la sua password. La password serve per sudo e per l'accesso RDP. Se la lasci vuota, ne viene generata una che vedi alla fine.

Per saltare le domande, passa le opzioni dopo `bash -s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

Trovi tutte le opzioni nel [riferimento CLI](/it/reference/cli).

::: tip Prova prima
`--dry-run` mostra ogni comando senza eseguirlo.
:::

## Quando ha finito

Vedi un riepilogo come questo:

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **Collegati in SSH** con il nuovo utente. Le chiavi SSH di root sono state copiate, quindi funziona la stessa chiave.
2. **Avvia Claude Code** dentro tmux e fai l'accesso. Vedi [Usare Claude Code](/it/guide/claude-code).
3. **Apri il desktop** con un qualsiasi client RDP. Vedi [Desktop remoto](/it/guide/remote-desktop).

## Usare le tue impostazioni

Di base il server riceve la mia configurazione di KDE e Claude da `dotfiles/home`. Per usare la tua, fai un fork del repository, esegui `claude-vps capture` sul tuo computer, fai push e indica il tuo fork all'installazione:

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

La pagina [Sincronizzare la config](/it/guide/sync) spiega tutto il processo.
