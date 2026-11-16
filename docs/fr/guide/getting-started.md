---
description: "Installez claude-vps sur un VPS Ubuntu 24.04 ou 26.04 en une commande : Claude Code, KDE Plasma via RDP et SSH durci en une dizaine de minutes."
---

# Bien démarrer

claude-vps transforme un serveur Ubuntu tout neuf en la machine sur laquelle je fais tourner Claude Code : un utilisateur sudo, SSH par clé uniquement, un pare-feu, un bureau KDE Plasma accessible en RDP, Docker, Chrome, et Claude Code lui-même avec mes réglages, mes hooks et ma disposition KDE déjà en place.

## Prérequis

| | |
| --- | --- |
| **OS** | Ubuntu 24.04 LTS ou plus récent (j'utilise la 26.04) |
| **CPU / RAM** | 2 vCPU et 4 Go au minimum pour Plasma. Avec 4 vCPU / 8 Go, on a un vrai bureau |
| **Disque** | 25 Go ou plus |
| **Accès** | root en SSH, idéalement avec votre clé SSH déjà présente sur la machine |
| **Arch** | amd64 a tout. arm64 fonctionne mais sans Chrome |

Il vous faudra aussi un abonnement Claude Pro ou Max, ou une clé API Anthropic, pour vous connecter à Claude Code ensuite.

## Installation

Connectez-vous en SSH en root (ou avec un utilisateur sudo) et lancez :

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Le script clone ce dépôt dans `/opt/claude-vps` puis lance `claude-vps setup`. Deux questions vous sont posées : le nom d'utilisateur de votre poste de travail et son mot de passe (utilisé pour sudo et la connexion RDP). Laissez le mot de passe vide et un mot de passe est généré puis affiché à la fin.

Pour éviter les questions, passez les options après `bash -s --` :

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

Toutes les options sont décrites dans la [référence CLI](/fr/reference/cli).

::: tip Testez d'abord
`--dry-run` affiche chaque commande sans l'exécuter.
:::

## Une fois terminé

Vous obtenez un récapitulatif de ce genre :

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **Connectez-vous en SSH** avec le nouvel utilisateur. Les clés SSH de root ont été copiées, la même clé fonctionne donc.
2. **Lancez Claude Code** dans tmux et connectez-vous. Voir [Utiliser Claude Code](/fr/guide/claude-code).
3. **Ouvrez le bureau** avec n'importe quel client RDP. Voir [Bureau à distance](/fr/guide/remote-desktop).

## Utiliser votre propre config

Par défaut, le serveur reçoit ma config KDE et Claude depuis `dotfiles/home`. Pour utiliser la vôtre, forkez le dépôt, lancez `claude-vps capture` sur votre machine, pushez, puis pointez l'installeur vers votre fork :

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

La page [Synchroniser la config](/fr/guide/sync) décrit toute la boucle.
