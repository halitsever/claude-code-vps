---
description: "Gardez vos réglages KDE Plasma et Claude Code identiques sur votre ordinateur et votre VPS avec claude-vps publish, sync et autosync."
---

# Synchroniser la config

Tous les réglages du serveur sont stockés dans le dépôt. Vous faites vos changements sur votre propre ordinateur, puis le serveur les récupère.

```text
 your machine                  GitHub                     server
 ───────────                   ──────                     ──────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (or autosync, every 30 min)
```

## Sur votre ordinateur

Clonez le dépôt une fois et ajoutez la CLI à votre PATH :

```bash
git clone https://github.com/halitsever/claude-code-vps.git ~/claude-code-vps
ln -s ~/claude-code-vps/bin/claude-vps ~/.local/bin/claude-vps
```

Après avoir modifié un panneau, un raccourci, votre profil Konsole ou `~/.claude/settings.json`, lancez :

```bash
claude-vps publish
```

Cette commande lance `capture`, fait un commit de `dotfiles/` et le push. Si vous voulez d'abord voir ce qui a changé :

```bash
claude-vps capture
git -C ~/claude-code-vps diff
```

## Sur le serveur

```bash
claude-vps sync
```

Cette commande récupère les changements et lance `apply`. Avant d'écraser un fichier, elle en garde une copie dans `~/.local/state/claude-vps/backup-<timestamp>/`. Les fichiers qui n'ont pas changé ne sont pas touchés.

Vous pouvez aussi laisser le serveur le faire tout seul :

```bash
claude-vps autosync on     # timer systemd utilisateur, toutes les 30 minutes
claude-vps autosync        # affiche la prochaine exécution
claude-vps autosync off
```

::: warning Plasma et sessions ouvertes
Plasma garde certains réglages en mémoire et les réécrit quand vous vous déconnectez. Si une synchronisation arrive pendant que vous êtes connecté en RDP, déconnectez-vous puis reconnectez-vous pour voir les changements. En attendant, ne modifiez pas le même réglage sur le serveur.
:::

## Ce qui est copié

La liste se trouve dans [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/manifest.txt). Une barre oblique à la fin d'un chemin veut dire « tout le dossier ».

| Domaine | Fichiers |
| --- | --- |
| Plasma | `kdeglobals`, `kwinrc`, `kglobalshortcutsrc`, `plasmarc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kdedefaults/`, réglages d'alimentation et de notifications |
| Applications | `dolphinrc`, `konsolerc`, `katerc`, `~/.local/share/konsole/`, réglages du thème GTK, `mimeapps.list` |
| Apparence | `~/.local/share/color-schemes/`, `plasma/`, `aurorae/`, `wallpapers/` s'ils existent |
| Claude | `~/.claude/settings.json`, `hooks/` |
| Shell | `.tmux.conf`, `.xsession` |

Pour suivre un autre fichier, ajoutez une ligne au manifeste. Les chemins qui n'existent pas sur votre ordinateur sont ignorés.

## Ce qui n'est jamais copié

Votre dossier personnel est remplacé par `@HOME@` dans les fichiers, pour qu'ils marchent avec n'importe quel nom d'utilisateur. Les sections qui contiennent les fichiers récents ou l'historique sont supprimées. Les identifiants ne sont tout simplement pas dans la liste : `~/.claude/.credentials.json`, `~/.claude/ntfy-topic`, les clés SSH, `kwalletrc`, les profils de navigateur. Ne les ajoutez pas : le dépôt est public.
