---
description: "Accedi a Claude Code su un server senza schermo, tieni gli agenti attivi in tmux anche se SSH cade e ricevi notifiche sul telefono con ntfy.sh."
---

# Usare Claude Code

## Primo accesso

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Claude Code mostra un link di accesso. Aprilo nel browser del tuo computer, conferma e incolla il codice nel terminale. Le credenziali restano in `~/.claude` sul server.

Preferisci una chiave API? Esportala prima di avviare Claude:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## Tenere Claude attivo con tmux

Un agente che lavora da un'ora non deve fermarsi perché il tuo portatile è andato in standby. Avvialo dentro tmux e poi staccati:

| | |
| --- | --- |
| Staccarsi | `Ctrl-b` e poi `d` |
| Ricollegarsi | `tmux attach -t claude` |
| Nuova finestra | `Ctrl-b` e poi `c` |
| Elenco sessioni | `tmux ls` |

Il `.tmux.conf` incluso attiva il mouse, una cronologia di 50.000 righe e i 256 colori.

Puoi anche aprire Konsole sul desktop ed eseguire `tmux attach -t claude`. Ritrovi la stessa sessione, su uno schermo più grande.

## Notifiche sul telefono

`~/.claude/settings.json` registra un hook `Notification`, `~/.claude/hooks/notify.sh`. Manda un messaggio a [ntfy.sh](https://ntfy.sh) ogni volta che Claude aspetta una tua risposta.

1. Installa l'app ntfy sul telefono e iscriviti a un topic che nessuno possa indovinare, per esempio `claude-7f3k9q2m`.
2. Salva lo stesso topic sul server:

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   In alternativa passa `--ntfy-topic` durante l'installazione.

Il topic è un segreto: chiunque lo conosca può leggere le tue notifiche. Per questo sta in un file separato e non viene mai copiato nel repository.

## Cosa è già configurato

Da `dotfiles/home/.claude`:

- **`settings.json`**: tema scuro, interfaccia a schermo intero, una barra di stato con modello, cartella, branch git e uso del contesto, i plugin che uso e l'hook delle notifiche
- **`CLAUDE.md`**: un file vuoto per le tue istruzioni globali. Viene creato solo se non esiste, quindi quello che ci scrivi non viene mai sovrascritto
- **`hooks/notify.sh`**: l'hook ntfy descritto sopra

Modifica uno di questi file sul tuo computer ed esegui `claude-vps publish`. Vedi [Sincronizzare la config](/it/guide/sync).

## Aggiornare Claude Code

L'installazione ufficiale si aggiorna da sola in background. Per forzare l'aggiornamento:

```bash
claude update
```
