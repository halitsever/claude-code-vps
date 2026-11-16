# Synchroniser la config

Le dépôt est la source de vérité pour l'apparence et le comportement du serveur. Vous modifiez les choses sur votre propre machine, et le serveur suit.

```text
 votre machine                 GitHub                     serveur
 ─────────────                 ──────                     ───────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (ou autosync, toutes les 30 min)
```

## Sur votre machine

Clonez le dépôt une fois et mettez la CLI dans votre PATH :

```bash
git clone https://github.com/halitsever/claude-vps.git ~/claude-vps
ln -s ~/claude-vps/bin/claude-vps ~/.local/bin/claude-vps
```

Après avoir modifié un panneau, un raccourci, votre profil Konsole ou `~/.claude/settings.json` :

```bash
claude-vps publish
```

La commande lance `capture`, commit `dotfiles/` et pousse. Si vous préférez d'abord regarder le diff :

```bash
claude-vps capture
git -C ~/claude-vps diff
```

## Sur le serveur

```bash
claude-vps sync
```

Elle fait un pull puis lance `apply`. Chaque fichier sur le point d'être écrasé est d'abord copié dans `~/.local/state/claude-vps/backup-<timestamp>/`, et les fichiers inchangés ne sont pas touchés.

Ou laissez faire tout seul :

```bash
claude-vps autosync on     # systemd user timer, every 30 minutes
claude-vps autosync        # show when it runs next
claude-vps autosync off
```

::: warning Plasma et sessions ouvertes
Plasma garde certains réglages en mémoire et les réécrit à la déconnexion. Si une synchro arrive pendant que vous êtes connecté en RDP, déconnectez-vous puis reconnectez-vous pour la voir, et évitez de modifier le même réglage sur le serveur entre-temps.
:::

## Ce qui est capturé

La liste se trouve dans [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-vps/blob/main/dotfiles/manifest.txt). Une barre oblique finale signifie le dossier entier.

| Domaine | Fichiers |
| --- | --- |
| Plasma | `kdeglobals`, `kwinrc`, `kglobalshortcutsrc`, `plasmarc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kdedefaults/`, réglages d'énergie et de notifications |
| Applis | `dolphinrc`, `konsolerc`, `katerc`, `~/.local/share/konsole/`, réglages du thème GTK, `mimeapps.list` |
| Apparence | `~/.local/share/color-schemes/`, `plasma/`, `aurorae/`, `wallpapers/` s'ils existent |
| Claude | `~/.claude/CLAUDE.md`, `settings.json`, `hooks/` |
| Shell | `.tmux.conf`, `.xsession` |

Ajoutez une ligne au manifeste pour suivre autre chose. Les chemins absents de votre machine sont ignorés.

## Ce qui n'est jamais capturé

Le chemin de votre répertoire personnel est remplacé par `@HOME@` pour que les fichiers marchent avec n'importe quel nom d'utilisateur, et les sections qui contiennent des fichiers récents ou un historique sont supprimées. Les identifiants ne sont tout simplement pas dans la liste : `~/.claude/.credentials.json`, `~/.claude/ntfy-topic`, clés SSH, `kwalletrc`, profils de navigateur. Gardez-le ainsi, le dépôt est public.
