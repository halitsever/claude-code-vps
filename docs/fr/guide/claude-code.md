---
title: "Utiliser Claude Code"
description: "Connectez Claude Code sur un serveur sans écran, gardez vos agents actifs dans tmux après une coupure SSH et recevez des notifications sur mobile avec ntfy.sh."
---

# Utiliser Claude Code sur le serveur distant

## Première connexion

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Claude Code affiche un lien de connexion. Ouvrez-le dans le navigateur de votre ordinateur, validez, puis collez le code dans le terminal. Les identifiants restent dans `~/.claude` sur le serveur.

Vous préférez une clé API ? Exportez-la avant de lancer Claude :

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

Avec une clé API, Claude Code fonctionne, mais [Remote Control](https://code.claude.com/docs/fr/remote-control), qui permet de piloter la session depuis l'app Claude ou claude.ai, exige la connexion via claude.ai.

## Garder Claude actif avec tmux

Un agent qui travaille depuis une heure ne doit pas s'arrêter parce que votre portable s'est mis en veille. Lancez-le dans tmux, puis détachez-vous :

| | |
| --- | --- |
| Se détacher | `Ctrl-b` puis `d` |
| Se rattacher | `tmux attach -t claude` |
| Nouvelle fenêtre | `Ctrl-b` puis `c` |
| Lister les sessions | `tmux ls` |

Le `.tmux.conf` fourni active la souris, un historique de 50 000 lignes et les 256 couleurs.

Vous pouvez aussi ouvrir Konsole sur le bureau et lancer `tmux attach -t claude`. Vous retrouvez la même session, sur un plus grand écran.

## Notifications sur le téléphone

`~/.claude/settings.json` déclare un hook `Notification`, `~/.claude/hooks/notify.sh`. Il envoie un message sur [ntfy.sh](https://ntfy.sh) chaque fois que Claude attend votre réponse.

1. Installez l'application ntfy sur votre téléphone et abonnez-vous à un sujet que personne ne devinera, par exemple `claude-7f3k9q2m`.
2. Enregistrez le même sujet sur le serveur :

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   Vous pouvez aussi passer `--ntfy-topic` pendant l'installation.

Le sujet est un secret : toute personne qui le connaît peut lire vos notifications. C'est pour ça qu'il est dans un fichier à part et qu'il n'est jamais copié dans le dépôt.

## Ce qui est déjà configuré

Depuis `dotfiles/home/.claude` :

- **`settings.json`** : thème sombre, interface en plein écran, une barre d'état avec le modèle, le dossier, la branche git et l'utilisation du contexte, les plugins que j'utilise et le hook de notification
- **`CLAUDE.md`** : un fichier vide pour vos propres instructions globales. Il n'est créé que s'il n'existe pas, donc ce que vous y écrivez n'est jamais écrasé
- **`hooks/notify.sh`** : le hook ntfy décrit plus haut

Modifiez l'un de ces fichiers sur votre ordinateur, puis lancez `claude-vps publish`. Voir [Synchroniser la config](/fr/guide/sync).

## Mettre à jour Claude Code

L'installation officielle se met à jour toute seule en arrière-plan. Pour forcer une mise à jour :

```bash
claude update
```
