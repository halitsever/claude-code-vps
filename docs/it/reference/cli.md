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
| `update` | server, come root | Scarica l'ultima versione e riesegue setup con le opzioni della prima installazione |
| `sync` | server | `git pull`, poi `apply` |
| `autosync on\|off` | server | Timer systemd dell'utente che esegue `sync` ogni 30 minuti |
| `doctor` | server | Controlla Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy e autosync |
| `capture` | il tuo computer | Copia i file elencati in `dotfiles/manifest.txt` in `dotfiles/home` |
| `publish` | il tuo computer | `capture`, poi commit e push |
| `release X.Y.Z` | il tuo computer | Scrive `VERSION`, crea il tag `vX.Y.Z` e fa push. GitHub pubblica la release a partire da `CHANGELOG.md` |
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

## Aggiornare

Quando esce una nuova versione, esegui questo su ogni server:

```bash
sudo claude-vps update
```

Il comando scarica il nuovo codice, mostra cosa è cambiato e riesegue tutti i passaggi di setup. I passaggi già fatti vengono saltati. xrdp e SSH si riavviano solo se la loro configurazione è cambiata, quindi una sessione RDP aperta resta collegata. Le opzioni scelte alla prima installazione (utente, porta RDP, passaggi saltati) restano salvate in `/etc/claude-vps.conf` e vengono riusate.

Anche `claude-vps sync` ti avvisa quando arriva una nuova versione.

## Pubblicare una versione

Sul tuo computer aggiungi una sezione `## X.Y.Z` a `CHANGELOG.md`, fai commit e poi esegui:

```bash
claude-vps release X.Y.Z
```

Il workflow di release controlla che il tag corrisponda a `VERSION` e pubblica una release su GitHub. Come note usa quella sezione del changelog.

## Macchine sorgente della configurazione

`claude-vps capture` segna la macchina su cui gira come sorgente della configurazione (`~/.config/claude-vps/source`). Su questa macchina `apply` e `sync` non toccano i tuoi file, perché la copia nel repo può essere più vecchia di quella che stai usando. Per sovrascriverli comunque, usa `claude-vps apply --force`.

## install.sh

Lo script di installazione legge tre variabili d'ambiente:

| Variabile | Predefinito |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Tutto quello che segue `bash -s --` viene passato a `setup`.
