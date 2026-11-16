---
description: "Toutes les commandes et options de claude-vps : setup, sync, autosync, doctor, capture, publish et apply, avec les variables d'install.sh."
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
| `capture` | votre ordinateur | Copie les fichiers listés dans `dotfiles/manifest.txt` vers `dotfiles/home` |
| `publish` | votre ordinateur | `capture`, puis commit et push |
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

## install.sh

Le script d'installation lit trois variables d'environnement :

| Variable | Par défaut |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Tout ce qui suit `bash -s --` est transmis à `setup`.
