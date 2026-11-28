---
title: "Dépannage"
description: "Résoudre les problèmes courants d'un VPS Claude Code : écran RDP noir, demande colord, accès SSH bloqué, claude introuvable et erreurs de synchronisation."
---

# Résoudre les problèmes courants

Commencez par :

```bash
claude-vps doctor
```

## RDP affiche un écran noir puis se déconnecte

En général, `~/.xsession` manque, ou Plasma tourne déjà pour cet utilisateur.

```bash
cat ~/.xsession                      # doit finir par : exec startplasma-x11
loginctl list-sessions               # une ancienne session pour votre utilisateur ? fermez-la :
loginctl terminate-user $USER
```

Les logs sont dans `~/.xsession-errors` et `/var/log/xrdp-sesman.log`.

## « Authentication is required to create a color managed device »

La règle polkit de l'étape `rdp` règle ce problème. Vérifiez que votre utilisateur est dans le groupe `users` (avec `id`), puis reconnectez-vous.

## Impossible de se connecter en RDP

```bash
sudo ss -tlnp | grep xrdp      # écoute sur 53389 ?
sudo ufw status                # port autorisé ?
```

Votre hébergeur a peut-être aussi son propre pare-feu devant le serveur.

## Plus d'accès SSH

L'étape `ssh` ne désactive la connexion par mot de passe que si votre utilisateur a une clé. Si vous êtes quand même bloqué, passez par la console web de votre hébergeur, puis lancez :

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

L'installateur officiel place `claude` dans `~/.local/bin`. Ubuntu ajoute ce dossier au `PATH` à la connexion, une fois qu'il existe. Déconnectez-vous puis reconnectez-vous, ou lancez `source ~/.profile`.

## `claude-vps sync` affiche « Not possible to fast-forward »

La copie du dépôt sur le serveur contient des modifications locales. Le serveur doit seulement récupérer les changements, jamais en créer :

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## Récupérer un ancien fichier

Chaque `apply` garde une copie de ce qu'il écrase :

```bash
ls ~/.local/state/claude-vps/
```
