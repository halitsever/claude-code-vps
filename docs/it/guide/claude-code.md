---
description: "Accedi a Claude Code su un server senza schermo, tieni gli agenti attivi in tmux dopo la disconnessione SSH e ricevi notifiche con ntfy.sh."
---

# Usare Claude Code

## Primo login

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Claude Code stampa un link di login. Aprilo nel tuo browser, approva e incolla il codice nel terminale. Le credenziali restano in `~/.claude` sul server.

Preferisci una API key? Esportala prima di partire:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## Tenerlo attivo con tmux

Un agente che lavora per un'ora non deve morire perché il tuo portatile è andato in standby. Fallo girare dentro tmux e staccati:

| | |
| --- | --- |
| Staccarsi | `Ctrl-b` poi `d` |
| Ricollegarsi | `tmux attach -t claude` |
| Nuova finestra | `Ctrl-b` poi `c` |
| Elenco sessioni | `tmux ls` |

Il `.tmux.conf` incluso attiva il mouse, uno scrollback di 50k righe e i 256 colori.

Puoi anche aprire Konsole sul desktop e lanciare lì `tmux attach -t claude`. Stessa sessione, schermo più grande.

## Notifiche sul telefono

`~/.claude/settings.json` registra un hook `Notification`, `~/.claude/hooks/notify.sh`, che invia un messaggio a [ntfy.sh](https://ntfy.sh) ogni volta che Claude ti sta aspettando.

1. Installa l'app ntfy sul telefono e iscriviti a un topic che nessuno possa indovinare, per esempio `claude-7f3k9q2m`.
2. Metti lo stesso topic sul server:

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   Oppure passa `--ntfy-topic` durante il setup.

Il topic va trattato come un segreto: chi lo conosce può leggere le tue notifiche. Per questo sta in un file a parte e non finisce mai nel repo.

## Cosa trovi già configurato

Da `dotfiles/home/.claude`:

- **`settings.json`**: tema scuro, TUI a schermo intero, una status line con modello, cartella, branch git e uso del contesto, i plugin che uso e l'hook di notifica
- **`CLAUDE.md`**: un file vuoto per le tue istruzioni globali. Viene creato solo se manca, quindi quello che ci scrivi non viene mai sovrascritto
- **`hooks/notify.sh`**: l'hook ntfy descritto sopra

Modifica uno qualsiasi di questi file sulla tua macchina e lancia `claude-vps publish`. Vedi [Tenere la configurazione sincronizzata](/it/guide/sync).

## Aggiornare Claude Code

L'installazione nativa si aggiorna da sola in background. Per forzare l'aggiornamento:

```bash
claude update
```
