# CLI

```text
claude-vps <command> [options]
```

| Comando | Dove | Cosa fa |
| --- | --- | --- |
| `setup` | server, come root | Esegue i passaggi di installazione |
| `sync` | server | `git pull`, poi `apply` |
| `autosync on\|off` | server | Timer utente di systemd che esegue `sync` ogni 30 minuti |
| `doctor` | server | Controlla Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy e autosync |
| `capture` | la tua macchina | Copia i file elencati in `dotfiles/manifest.txt` dentro `dotfiles/home` |
| `publish` | la tua macchina | `capture`, commit e push |
| `apply` | ovunque | Scrive `dotfiles/home` in `$HOME`, con backup di ciò che sostituisce |
| `version` | ovunque | Stampa la versione |

## setup

```bash
sudo claude-vps setup [options]
```

| Opzione | Default | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER`, oppure lo chiede | Utente della workstation, creato se manca |
| `--rdp-port PORT` | `53389` | Porta di xrdp |
| `--rdp-private` | off | Non apre la porta RDP in ufw |
| `--ntfy-topic NAME` | lo chiede | Topic ntfy.sh per le notifiche |
| `--timezone TZ` | invariato | per esempio `Europe/Istanbul` |
| `--no-desktop` | off | Equivale a `--skip desktop,rdp` |
| `--skip a,b` | | Passaggi da saltare |
| `--only a,b` | | Esegue solo questi passaggi |
| `-y, --yes` | off | Nessuna domanda. L'utente di default è `dev`, la password viene generata |
| `-n, --dry-run` | off | Stampa i comandi invece di eseguirli |

Passaggi, in ordine: `base user ssh firewall desktop rdp apps claude dotfiles`.

## install.sh

Lo script di bootstrap legge tre variabili d'ambiente:

| Variabile | Default |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Tutto quello che viene dopo `bash -s --` viene passato a `setup`.
