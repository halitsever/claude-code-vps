---
description: "Chaque étape que claude-vps lance sur votre serveur Ubuntu : paquets, swap, SSH, ufw, KDE Plasma, xrdp, Docker, Chrome, Claude Code et vos dotfiles."
---

# Ce qui est installé

`claude-vps setup` lance neuf étapes, dans l'ordre. Chaque étape est une simple fonction bash dans [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh). Vous pouvez donc lire exactement ce qui s'exécute sur votre serveur. Pour sauter une étape, utilisez `--skip`. Pour n'en lancer que quelques-unes, utilisez `--only`.

## 1. base

- `apt upgrade` sur tout le système
- `git curl jq ripgrep fd-find tmux htop build-essential python3` et quelques autres outils
- Node.js 20 ou plus récent. Sur Ubuntu 24.04, apt ne propose que la 18, il vient donc du dépôt NodeSource
- `unattended-upgrades` activé : les correctifs de sécurité s'installent sans vous
- un fichier swap de 4 Go si le serveur n'a pas de swap et moins de 8 Go de RAM. Ainsi, Plasma et plusieurs agents ne déclenchent pas l'OOM killer
- le fuseau horaire, si vous passez `--timezone`

## 2. user

Crée votre utilisateur, l'ajoute au groupe `sudo` et lui copie `/root/.ssh/authorized_keys` s'il n'a pas encore de clé. Le mot de passe choisi est celui que vous tapez à la connexion RDP.

## 3. ssh

Écrit le fichier `/etc/ssh/sshd_config.d/10-claude-vps.conf` :

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd garde la première valeur qu'il lit. Le nom du fichier commence donc par `10-` pour passer avant `50-cloud-init.conf`, présent sur la plupart des images cloud. Si votre utilisateur n'a pas encore de clé SSH, l'étape est sautée avec un avertissement. Vous ne pouvez donc pas vous retrouver bloqué dehors.

## 4. firewall

`ufw` autorise OpenSSH et le port RDP, et ferme tout le reste. Avec `--rdp-private`, le port RDP reste fermé et vous passez par un tunnel SSH.

## 5. desktop

Installe `kde-plasma-desktop` et la session X11 (`plasma-session-x11` et `kwin-x11` sur Ubuntu 25.10 et plus récent), Konsole, Dolphin, Kate, Spectacle, et les polices Noto et JetBrains Mono. SDDM est désactivé et la cible par défaut devient `multi-user`. Personne n'est assis devant un serveur : il démarre donc sur une console, et Plasma ne se lance que quand vous vous connectez.

::: info Pourquoi X11
xrdp pilote une session Xorg. Plasma 6 fournit encore une session X11 sur Ubuntu 24.04 à 26.04, et c'est celle que j'utilise tous les jours en RDP.
:::

## 6. rdp

- `xrdp` et `xorgxrdp`, sur le port **53389** (modifiable avec `--rdp-port`)
- un fichier `~/.xsession` qui lance `startplasma-x11` avec les bonnes variables `XDG_*`
- une règle polkit qui supprime la demande « authentication is required to create a color managed device ». Sans elle, cette demande apparaît à chaque connexion

## 7. apps

- Docker (`docker.io`, compose v2, buildx), avec votre utilisateur dans le groupe `docker`
- GitHub CLI (`gh`)
- Google Chrome depuis le dépôt apt de Google (amd64 seulement). Utile quand Claude a besoin d'un vrai navigateur

## 8. claude

- Claude Code avec l'installateur officiel, dans `~/.local/bin/claude`. Il se met à jour tout seul
- [claudegrid](https://github.com/halitsever/claudegrid) depuis sa dernière release `.deb`, pour ouvrir une grille d'agents Claude Code dans Konsole ou tmux en une commande. Il ajoute aussi un profil Konsole et une entrée dans le menu des applications
- votre sujet ntfy.sh dans `~/.claude/ntfy-topic` si vous en donnez un. Le hook de notification le lit à cet endroit

## 9. dotfiles

Donne `/opt/claude-vps` à votre utilisateur, crée un lien vers `claude-vps` dans `/usr/local/bin` et lance `claude-vps apply` avec votre utilisateur. Cette commande copie tout le contenu de `dotfiles/home` dans votre dossier personnel : config KDE, profils Konsole, `~/.claude/settings.json`, `CLAUDE.md`, hooks, `.tmux.conf`.

## Relancer des étapes

Chaque étape vérifie d'abord ce qui est déjà en place. Vous pouvez donc les relancer sans risque :

```bash
sudo claude-vps setup --only desktop,rdp     # par exemple après une mise à niveau d'Ubuntu
sudo claude-vps setup --skip apps            # tout sauf Docker et Chrome
sudo claude-vps setup --no-desktop           # serveur sans bureau, terminal seul
```
