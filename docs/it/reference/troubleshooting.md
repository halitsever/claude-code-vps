---
title: "Risoluzione problemi"
description: "Risolvi i problemi più comuni di un VPS con Claude Code: schermo RDP nero, richiesta di colord, SSH bloccato, claude non trovato ed errori di sincronizzazione."
---

# Risolvere i problemi più comuni

Inizia con:

```bash
claude-vps doctor
```

## RDP mostra uno schermo nero e si scollega

Di solito manca `~/.xsession`, oppure Plasma è già in esecuzione per quell'utente.

```bash
cat ~/.xsession                      # deve finire con: exec startplasma-x11
loginctl list-sessions               # c'è una vecchia sessione del tuo utente? chiudila:
loginctl terminate-user $USER
```

I log sono in `~/.xsession-errors` e `/var/log/xrdp-sesman.log`.

## "Authentication is required to create a color managed device"

La regola polkit del passaggio `rdp` risolve questo problema. Controlla che il tuo utente sia nel gruppo `users` (con `id`), poi ricollegati.

## Non riesco a collegarmi in RDP

```bash
sudo ss -tlnp | grep xrdp      # in ascolto sulla 53389?
sudo ufw status                # porta permessa?
```

Anche il tuo provider potrebbe avere un suo firewall davanti al server.

## Non riesco più ad accedere in SSH

Il passaggio `ssh` disattiva l'accesso con password solo se il tuo utente ha una chiave. Se resti comunque chiuso fuori, usa la console web del provider ed esegui:

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

L'installer ufficiale mette `claude` in `~/.local/bin`. Ubuntu aggiunge quella cartella al `PATH` all'accesso, se esiste. Esci e rientra, oppure esegui `source ~/.profile`.

## `claude-vps sync` mostra "Not possible to fast-forward"

La copia del repository sul server ha modifiche locali. Il server deve solo scaricare le modifiche, non crearne:

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## Recuperare un vecchio file

Ogni `apply` salva una copia di quello che sovrascrive:

```bash
ls ~/.local/state/claude-vps/
```
