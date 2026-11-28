---
title: "Sincronizzare la config"
description: "Tieni allineate le impostazioni di KDE Plasma e Claude Code tra il tuo computer e il VPS con claude-vps publish, sync e autosync."
---

# Sincronizzare la config tra il tuo computer e il server

Tutte le impostazioni del server stanno nel repository. Fai le modifiche sul tuo computer, poi il server le scarica.

```text
 your machine                  GitHub                     server
 ───────────                   ──────                     ──────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (or autosync, every 30 min)
```

## Sul tuo computer

Clona il repository una volta e aggiungi la CLI al PATH:

```bash
git clone https://github.com/halitsever/claude-code-vps.git ~/claude-code-vps
ln -s ~/claude-code-vps/bin/claude-vps ~/.local/bin/claude-vps
```

Dopo aver cambiato un pannello, una scorciatoia, il profilo di Konsole o `~/.claude/settings.json`, esegui:

```bash
claude-vps publish
```

Il comando esegue `capture`, fa commit di `dotfiles/` e poi push. Se prima vuoi vedere cosa è cambiato:

```bash
claude-vps capture
git -C ~/claude-code-vps diff
```

## Sul server

```bash
claude-vps sync
```

Il comando scarica le modifiche ed esegue `apply`. Prima di sovrascrivere un file ne salva una copia in `~/.local/state/claude-vps/backup-<timestamp>/`. I file che non sono cambiati restano come sono.

Oppure lascia che il server lo faccia da solo:

```bash
claude-vps autosync on     # timer systemd dell'utente, ogni 30 minuti
claude-vps autosync        # mostra la prossima esecuzione
claude-vps autosync off
```

::: warning Plasma e sessioni aperte
Plasma tiene alcune impostazioni in memoria e le riscrive quando esci. Se una sincronizzazione arriva mentre sei collegato in RDP, esci e rientra per vedere le modifiche. Nel frattempo non cambiare la stessa impostazione sul server.
:::

## Cosa viene copiato

L'elenco sta in [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/manifest.txt). Una barra alla fine di un percorso vuol dire "tutta la cartella".

| Area | File |
| --- | --- |
| Plasma | `kdeglobals`, `kwinrc`, `kglobalshortcutsrc`, `plasmarc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kdedefaults/`, impostazioni di alimentazione e notifiche |
| App | `dolphinrc`, `konsolerc`, `katerc`, `~/.local/share/konsole/`, impostazioni del tema GTK, `mimeapps.list` |
| Aspetto | `~/.local/share/color-schemes/`, `plasma/`, `aurorae/`, `wallpapers/` se esistono |
| Claude | `~/.claude/settings.json`, `hooks/` |
| Shell | `.tmux.conf`, `.xsession` |

Per seguire un altro file, aggiungi una riga al manifest. I percorsi che non esistono sul tuo computer vengono saltati.

## Cosa non viene mai copiato

Nei file il percorso della tua home viene sostituito con `@HOME@`, così funzionano con qualsiasi nome utente. Le sezioni con i file recenti o la cronologia vengono rimosse. Le credenziali semplicemente non sono nell'elenco: `~/.claude/.credentials.json`, `~/.claude/ntfy-topic`, le chiavi SSH, `kwalletrc`, i profili del browser. Non aggiungerle: il repository è pubblico.
