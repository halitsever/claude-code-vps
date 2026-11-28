---
title: "Installer claude-vps sur Ubuntu : prérequis et étapes"
titleTemplate: false
description: "Installez claude-vps sur un VPS Ubuntu 24.04 ou 26.04 en une commande. Claude Code, KDE Plasma en RDP et SSH sécurisé sont prêts en dix minutes environ."
---

# Bien démarrer

claude-vps prend un serveur Ubuntu tout neuf et en fait la machine sur laquelle je fais tourner Claude Code. Il installe un utilisateur sudo, SSH par clé uniquement, un pare-feu, un bureau KDE Plasma accessible en RDP, Docker, Chrome et Claude Code. Mes réglages, mes hooks et ma disposition KDE sont déjà appliqués.

## Ce qu'il vous faut

| | |
| --- | --- |
| **Système** | Ubuntu 24.04 LTS ou plus récent (j'utilise la 26.04) |
| **CPU / RAM** | 2 vCPU et 4 Go au minimum pour Plasma. Avec 4 vCPU et 8 Go, on travaille comme sur un vrai PC |
| **Disque** | 25 Go ou plus |
| **Accès** | root en SSH, idéalement avec votre clé SSH déjà sur le serveur |
| **Architecture** | En amd64 comme en arm64, tout est installé |

Il vous faut aussi un abonnement Claude Pro ou Max, ou une clé API Anthropic, pour vous connecter ensuite à Claude Code.

## Installation

Connectez-vous en SSH en root (ou avec un utilisateur qui a sudo) et lancez :

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Le script clone ce dépôt dans `/opt/claude-vps` et lance `claude-vps setup`. Il vous pose deux questions : le nom de votre utilisateur et son mot de passe. Ce mot de passe sert pour sudo et pour la connexion RDP. Si vous le laissez vide, un mot de passe est généré et affiché à la fin.

Pour éviter les questions, passez les options après `bash -s --` :

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

Toutes les options sont dans la [référence CLI](/fr/reference/cli).

::: tip Tester d'abord
`--dry-run` affiche chaque commande sans l'exécuter.
:::

## À la fin de l'installation

Vous voyez un résumé comme celui-ci :

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **Connectez-vous en SSH** avec le nouvel utilisateur. Les clés SSH de root ont été copiées, donc la même clé fonctionne.
2. **Lancez Claude Code** dans tmux et connectez-vous. Voir [Utiliser Claude Code](/fr/guide/claude-code).
3. **Ouvrez le bureau** avec n'importe quel client RDP. Voir [Bureau à distance](/fr/guide/remote-desktop).

## Utiliser vos propres réglages

Par défaut, le serveur reçoit ma configuration KDE et Claude depuis `dotfiles/home`. Pour utiliser la vôtre, faites un fork du dépôt, lancez `claude-vps capture` sur votre ordinateur, faites un push, puis indiquez votre fork à l'installation :

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

La page [Synchroniser la config](/fr/guide/sync) explique tout le fonctionnement.
