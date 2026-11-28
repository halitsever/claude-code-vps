---
title: "CLI claude-vps : commandes et options"
description: "Toutes les commandes et options de claude-vps : setup, sync, autosync, doctor, capture, publish et apply, avec les variables d'install.sh."
---

# CLI

```text
claude-vps <command> [options]
```

| Commande | Où | Ce qu'elle fait |
| --- | --- | --- |
| `setup` | serveur, en root | Lance les étapes d'installation |
| `update` | serveur, en root | Récupère la dernière version et relance setup avec les options de la première installation |
| `sync` | serveur | `git pull`, puis `apply` |
| `autosync on\|off` | serveur | Timer systemd utilisateur qui lance `sync` toutes les 30 minutes |
| `doctor` | serveur | Vérifie Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy et autosync |
| `capture` | votre ordinateur | Copie les fichiers listés dans `dotfiles/manifest.txt` vers `dotfiles/home` |
| `publish` | votre ordinateur | `capture`, puis commit et push |
| `release X.Y.Z` | votre ordinateur | Écrit `VERSION`, crée le tag `vX.Y.Z` et fait un push. GitHub publie la release à partir de `CHANGELOG.md` |
| `apply` | partout | Copie `dotfiles/home` dans `$HOME`, en gardant une copie de ce qu'il remplace |
| `version` | partout | Affiche la version |

## setup

```bash
sudo claude-vps setup [options]
```

| Option | Par défaut | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER`, sinon demandé | Votre utilisateur, créé s'il n'existe pas |
| `--rdp-port PORT` | `53389` | Port de xrdp |
| `--rdp-private` | désactivé | N'ouvre pas le port RDP dans ufw |
| `--ntfy-topic NAME` | demandé | Sujet ntfy.sh pour les notifications |
| `--timezone TZ` | inchangé | Par exemple `Europe/Istanbul` |
| `--no-desktop` | désactivé | Équivaut à `--skip desktop,rdp` |
| `--skip a,b` | | Étapes à sauter |
| `--only a,b` | | Lance seulement ces étapes |
| `-y, --yes` | désactivé | Aucune question. L'utilisateur est `dev` et le mot de passe est généré |
| `-n, --dry-run` | désactivé | Affiche les commandes au lieu de les lancer |

Les étapes, dans l'ordre : `base user ssh firewall desktop rdp apps claude dotfiles`.

## Mettre à jour

Quand une nouvelle version sort, lancez ceci sur chaque serveur :

```bash
sudo claude-vps update
```

La commande récupère le nouveau code, affiche ce qui a changé et relance toutes les étapes de setup. Les étapes déjà faites sont sautées. xrdp et SSH ne redémarrent que si leur configuration a changé : une session RDP ouverte reste donc connectée. Les options choisies à la première installation (utilisateur, port RDP, étapes ignorées) sont gardées dans `/etc/claude-vps.conf` et réutilisées.

`claude-vps sync` vous prévient aussi quand une nouvelle version est arrivée.

## Publier une version

Sur votre ordinateur, ajoutez une section `## X.Y.Z` dans `CHANGELOG.md`, faites un commit, puis :

```bash
claude-vps release X.Y.Z
```

Le workflow de release vérifie que le tag correspond à `VERSION` et publie une release GitHub. Ses notes reprennent cette section du changelog.

## Machines sources de la configuration

`claude-vps capture` marque la machine où il tourne comme source de la configuration (`~/.config/claude-vps/source`). Sur cette machine, `apply` et `sync` ne touchent pas à vos fichiers, car la copie du repo peut être plus ancienne que ce que vous utilisez. Pour les écraser quand même, lancez `claude-vps apply --force`.

## install.sh

Le script d'installation lit trois variables d'environnement :

| Variable | Par défaut |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Tout ce qui suit `bash -s --` est transmis à `setup`.
