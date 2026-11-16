---
description: "Tutti i comandi e le opzioni di claude-vps: setup, sync, autosync, doctor, capture, publish e apply, con le variabili di install.sh."
---

# CLI

```text
claude-vps <command> [options]
```

| Comando | Dove | Cosa fa |
| --- | --- | --- |
| `setup` | server, come root | Esegue i passaggi di installazione |
| `sync` | server | `git pull`, poi `apply` |
| `autosync on\|off` | server | Timer systemd dell'utente che esegue `sync` ogni 30 minuti |
| `doctor` | server | Controlla Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy e autosync |
| `capture` | il tuo computer | Copia i file elencati in `dotfiles/manifest.txt` in `dotfiles/home` |
| `publish` | il tuo computer | `capture`, poi commit e push |
| `apply` | ovunque | Copia `dotfiles/home` in `$HOME`, salvando una copia di quello che sostituisce |
| `version` | ovunque | Mostra la versione |

## setup

```bash
sudo claude-vps setup [options]
```

| Opzione | Predefinito | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER`, altrimenti lo chiede | Il tuo utente, creato se non esiste |
| `--rdp-port PORT` | `53389` | Porta di xrdp |
| `--rdp-private` | disattivato | Non apre la porta RDP in ufw |
| `--ntfy-topic NAME` | lo chiede | Topic ntfy.sh per le notifiche |
| `--timezone TZ` | invariato | Per esempio `Europe/Istanbul` |
| `--no-desktop` | disattivato | Come `--skip desktop,rdp` |
| `--skip a,b` | | Passaggi da saltare |
| `--only a,b` | | Esegue solo questi passaggi |
| `-y, --yes` | disattivato | Nessuna domanda. L'utente è `dev` e la password viene generata |
| `-n, --dry-run` | disattivato | Mostra i comandi invece di eseguirli |

I passaggi, in ordine: `base user ssh firewall desktop rdp apps claude dotfiles`.

## install.sh

Lo script di installazione legge tre variabili d'ambiente:

| Variabile | Predefinito |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Tutto quello che segue `bash -s --` viene passato a `setup`.
