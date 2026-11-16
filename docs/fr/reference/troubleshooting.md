---
description: "Résoudre les problèmes courants d'un VPS Claude Code : écran RDP noir, invites colord, blocage SSH, claude introuvable et erreurs de sync."
---

# Dépannage

Commencez par :

```bash
claude-vps doctor
```

## Le RDP affiche un écran noir puis se déconnecte

En général, `~/.xsession` est absent ou Plasma tourne déjà pour cet utilisateur.

```bash
cat ~/.xsession                      # should end with: exec startplasma-x11
loginctl list-sessions               # an old session for your user? terminate it:
loginctl terminate-user $USER
```

Les logs se trouvent dans `~/.xsession-errors` et `/var/log/xrdp-sesman.log`.

## « Authentication is required to create a color managed device »

La règle polkit de l'étape `rdp` s'en occupe. Vérifiez que votre utilisateur est dans le groupe `users` (`id`), puis reconnectez-vous.

## Impossible de se connecter en RDP

```bash
sudo ss -tlnp | grep xrdp      # listening on 53389?
sudo ufw status                # port allowed?
```

Votre hébergeur cloud a peut-être aussi son propre pare-feu devant le serveur.

## Bloqué hors de SSH

L'étape `ssh` ne désactive la connexion par mot de passe que si votre utilisateur a une clé. Si ça arrive quand même, passez par la console web de votre hébergeur, puis :

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

L'installeur natif le place dans `~/.local/bin`. Ubuntu ajoute ce dossier au `PATH` à la connexion dès qu'il existe : déconnectez-vous puis reconnectez-vous, ou lancez `source ~/.profile`.

## `claude-vps sync` affiche « Not possible to fast-forward »

Le clone sur le serveur a des modifications locales. Le serveur est censé ne faire que des pulls :

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## Restaurer un ancien fichier

Chaque `apply` sauvegarde ce qu'il écrase :

```bash
ls ~/.local/state/claude-vps/
```
