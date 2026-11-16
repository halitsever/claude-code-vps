# Utiliser Claude Code

## Première connexion

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Claude Code affiche un lien de connexion. Ouvrez-le dans votre propre navigateur, validez, puis recollez le code. Les identifiants restent dans `~/.claude` sur le serveur.

Vous préférez une clé API ? Exportez-la avant de lancer :

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## Le garder en vie avec tmux

Un agent qui travaille pendant une heure ne doit pas mourir parce que votre portable s'est mis en veille. Lancez-le dans tmux et détachez-vous :

| | |
| --- | --- |
| Se détacher | `Ctrl-b` puis `d` |
| Se rattacher | `tmux attach -t claude` |
| Nouvelle fenêtre | `Ctrl-b` puis `c` |
| Lister les sessions | `tmux ls` |

Le `.tmux.conf` fourni active la souris, un historique de 50 000 lignes et les 256 couleurs.

Vous pouvez aussi ouvrir Konsole sur le bureau et y lancer `tmux attach -t claude`. Même session, écran plus grand.

## Notifications sur le téléphone

`~/.claude/settings.json` enregistre un hook `Notification`, `~/.claude/hooks/notify.sh`, qui publie sur [ntfy.sh](https://ntfy.sh) dès que Claude vous attend.

1. Installez l'appli ntfy sur votre téléphone et abonnez-vous à un topic que personne ne devinera, par exemple `claude-7f3k9q2m`.
2. Mettez le même topic sur le serveur :

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   Ou passez `--ntfy-topic` pendant l'installation.

Le topic est un secret : quiconque le connaît peut lire vos notifications. C'est pour ça qu'il vit dans son propre fichier et n'est jamais capturé dans le dépôt.

## Ce qui est déjà configuré

Depuis `dotfiles/home/.claude` :

- **`settings.json`** : thème sombre, TUI plein écran, une barre d'état avec le modèle, le dossier, la branche git et l'usage du contexte, les plugins que j'utilise et le hook de notification
- **`CLAUDE.md`** : mes instructions globales pour tous les projets
- **`hooks/notify.sh`** : le hook ntfy décrit plus haut

Modifiez-les sur votre propre machine puis lancez `claude-vps publish`. Voir [Synchroniser la config](/fr/guide/sync).

## Mettre à jour Claude Code

L'installation native se met à jour toute seule en arrière-plan. Pour forcer :

```bash
claude update
```
