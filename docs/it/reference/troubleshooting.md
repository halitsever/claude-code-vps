# Risoluzione dei problemi

Parti da qui:

```bash
claude-vps doctor
```

## RDP mostra uno schermo nero e si disconnette

Di solito manca `~/.xsession`, oppure Plasma è già in esecuzione per quell'utente.

```bash
cat ~/.xsession                      # should end with: exec startplasma-x11
loginctl list-sessions               # an old session for your user? terminate it:
loginctl terminate-user $USER
```

I log sono in `~/.xsession-errors` e `/var/log/xrdp-sesman.log`.

## "Authentication is required to create a color managed device"

Ci pensa la regola polkit del passaggio `rdp`. Controlla che il tuo utente sia nel gruppo `users` (`id`), poi ricollegati.

## Non riesco proprio a collegarmi via RDP

```bash
sudo ss -tlnp | grep xrdp      # listening on 53389?
sudo ufw status                # port allowed?
```

Anche il tuo provider cloud potrebbe avere un suo firewall davanti al server.

## Sono rimasto chiuso fuori da SSH

Il passaggio `ssh` disattiva il login con password solo se il tuo utente ha una chiave, ma se succede comunque, usa la console web del provider e poi:

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

L'installer nativo lo mette in `~/.local/bin`. Ubuntu aggiunge quella cartella al `PATH` al login, se esiste, quindi esci e rientra oppure lancia `source ~/.profile`.

## `claude-vps sync` dice "Not possible to fast-forward"

Il clone sul server ha modifiche locali. Il server dovrebbe solo fare pull:

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## Ripristinare un vecchio file

Ogni `apply` fa il backup di ciò che sovrascrive:

```bash
ls ~/.local/state/claude-vps/
```
