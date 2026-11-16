---
description: "Référence de toutes les commandes et options de claude-vps : setup, sync, autosync, doctor, capture, publish, apply et variables d'install.sh."
---

# CLI

```text
claude-vps <command> [options]
```

| Commande | Où | Ce qu'elle fait |
| --- | --- | --- |
| `setup` | serveur, en root | Lance les étapes d'installation |
| `sync` | serveur | `git pull`, puis `apply` |
| `autosync on\|off` | serveur | Timer systemd utilisateur qui lance `sync` toutes les 30 minutes |
| `doctor` | serveur | Vérifie Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy et autosync |
| `capture` | votre machine | Copie les fichiers listés dans `dotfiles/manifest.txt` vers `dotfiles/home` |
| `publish` | votre machine | `capture`, commit et push |
| `apply` | partout | Écrit `dotfiles/home` dans `$HOME`, en sauvegardant ce qu'elle remplace |
| `version` | partout | Affiche la version |

## setup

```bash
sudo claude-vps setup [options]
```

| Option | Défaut | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER`, ou demandé | Utilisateur du poste de travail, créé s'il n'existe pas |
| `--rdp-port PORT` | `53389` | Port xrdp |
| `--rdp-private` | désactivé | N'ouvre pas le port RDP dans ufw |
| `--ntfy-topic NAME` | demandé | Topic ntfy.sh pour les notifications |
| `--timezone TZ` | inchangé | par ex. `Europe/Istanbul` |
| `--no-desktop` | désactivé | Équivaut à `--skip desktop,rdp` |
| `--skip a,b` | | Étapes à sauter |
| `--only a,b` | | Ne lance que ces étapes |
| `-y, --yes` | désactivé | Aucune question. L'utilisateur par défaut est `dev`, le mot de passe est généré |
| `-n, --dry-run` | désactivé | Affiche les commandes au lieu de les exécuter |

Étapes, dans l'ordre : `base user ssh firewall desktop rdp apps claude dotfiles`.

## install.sh

Le script d'amorçage lit trois variables d'environnement :

| Variable | Défaut |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Tout ce qui suit `bash -s --` est transmis à `setup`.
