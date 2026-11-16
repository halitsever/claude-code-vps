# Tenere la configurazione sincronizzata

Il repo è l'unica fonte di verità su come il server appare e si comporta. Tu cambi le cose sulla tua macchina e il server si allinea.

```text
 la tua macchina               GitHub                     server
 ───────────────               ──────                     ──────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (o autosync, ogni 30 min)
```

## Sulla tua macchina

Clona il repo una volta e metti la CLI nel PATH:

```bash
git clone https://github.com/halitsever/claude-vps.git ~/claude-vps
ln -s ~/claude-vps/bin/claude-vps ~/.local/bin/claude-vps
```

Dopo aver cambiato un pannello, una scorciatoia, il profilo di Konsole o `~/.claude/settings.json`:

```bash
claude-vps publish
```

Il comando esegue `capture`, fa il commit di `dotfiles/` e il push. Se preferisci guardare prima il diff:

```bash
claude-vps capture
git -C ~/claude-vps diff
```

## Sul server

```bash
claude-vps sync
```

Fa il pull ed esegue `apply`. Ogni file che sta per sovrascrivere viene prima copiato in `~/.local/state/claude-vps/backup-<timestamp>/`, e i file che non sono cambiati non vengono toccati.

Oppure lascia che lo faccia da solo:

```bash
claude-vps autosync on     # systemd user timer, every 30 minutes
claude-vps autosync        # show when it runs next
claude-vps autosync off
```

::: warning Plasma e sessioni attive
Plasma tiene alcune impostazioni in memoria e le riscrive quando fai logout. Se una sync arriva mentre sei collegato via RDP, esci e rientra per vederla, e nel frattempo evita di cambiare la stessa impostazione sul server.
:::

## Cosa viene catturato

L'elenco si trova in [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-vps/blob/main/dotfiles/manifest.txt). Uno slash finale indica l'intera cartella.

| Area | File |
| --- | --- |
| Plasma | `kdeglobals`, `kwinrc`, `kglobalshortcutsrc`, `plasmarc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kdedefaults/`, impostazioni di risparmio energetico e notifiche |
| App | `dolphinrc`, `konsolerc`, `katerc`, `~/.local/share/konsole/`, impostazioni del tema GTK, `mimeapps.list` |
| Aspetto | `~/.local/share/color-schemes/`, `plasma/`, `aurorae/`, `wallpapers/` quando esistono |
| Claude | `~/.claude/CLAUDE.md`, `settings.json`, `hooks/` |
| Shell | `.tmux.conf`, `.xsession` |

Per tracciare qualcos'altro aggiungi una riga al manifest. I percorsi che non esistono sulla tua macchina vengono saltati.

## Cosa non viene mai catturato

Il percorso della tua home viene sostituito con `@HOME@`, così i file funzionano con qualsiasi nome utente, e le sezioni con file recenti o cronologia vengono scartate. Le credenziali semplicemente non sono nell'elenco: `~/.claude/.credentials.json`, `~/.claude/ntfy-topic`, chiavi SSH, `kwalletrc`, profili del browser. Lascia le cose così, il repo è pubblico.
