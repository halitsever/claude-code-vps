---
description: "Chaque étape lancée par claude-vps sur votre serveur Ubuntu : paquets, swap, SSH durci, ufw, KDE Plasma, xrdp, Docker, Chrome, Claude Code et dotfiles."
---

# Ce qui est installé

`claude-vps setup` exécute neuf étapes dans l'ordre. Chacune est une simple fonction bash dans [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh) : vous pouvez lire exactement ce qui tourne sur votre machine. Sautez-en avec `--skip`, ou n'en lancez que certaines avec `--only`.

## 1. base

- `apt upgrade` sur tout le système
- `git curl jq ripgrep fd-find tmux htop build-essential nodejs npm python3` et compagnie
- `unattended-upgrades` activé, pour que les correctifs de sécurité s'installent sans vous
- un fichier d'échange de 4 Go si la machine n'a pas de swap et moins de 8 Go de RAM, ce qui évite à Plasma et à quelques agents de se faire tuer par l'OOM killer
- le fuseau horaire, si vous passez `--timezone`

## 2. user

Crée l'utilisateur du poste de travail, l'ajoute au groupe `sudo` et lui copie `/root/.ssh/authorized_keys` s'il n'en a pas. Le mot de passe choisi est celui que vous tapez à l'écran de connexion RDP.

## 3. ssh

Écrit `/etc/ssh/sshd_config.d/10-claude-vps.conf` :

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd garde la première valeur qu'il lit, d'où le préfixe `10-` dans le nom du fichier : il passe avant le `50-cloud-init.conf` fourni par la plupart des images cloud. L'étape est ignorée avec un avertissement si votre utilisateur n'a pas encore de clé SSH, pour que vous ne vous retrouviez jamais enfermé dehors.

## 4. firewall

`ufw` avec OpenSSH et le port RDP autorisés, tout le reste fermé. Passez `--rdp-private` pour garder le RDP fermé et y accéder via un tunnel SSH.

## 5. desktop

`kde-plasma-desktop` plus la session X11 (`plasma-session-x11`, `kwin-x11` sur Ubuntu 25.10+), Konsole, Dolphin, Kate, Spectacle, les polices Noto et JetBrains Mono. SDDM est désactivé et la cible par défaut passe à `multi-user` : personne n'est assis devant un serveur, il démarre donc directement sur une console et Plasma ne se lance qu'à la connexion.

::: info Pourquoi X11
xrdp pilote une session Xorg. Plasma 6 fournit toujours une session X11 sur Ubuntu 24.04 à 26.04, et c'est ce que j'utilise au quotidien en RDP.
:::

## 6. rdp

- `xrdp` et `xorgxrdp`, en écoute sur le port **53389** (modifiable avec `--rdp-port`)
- un `~/.xsession` qui lance `startplasma-x11` avec les bonnes variables `XDG_*`
- une règle polkit qui supprime la demande « authentication is required to create a color managed device » qui apparaît sinon à chaque connexion

## 7. apps

- Docker (`docker.io`, compose v2, buildx), avec votre utilisateur dans le groupe `docker`
- GitHub CLI (`gh`)
- Google Chrome depuis le dépôt apt de Google (amd64 uniquement), pratique quand Claude a besoin d'un vrai navigateur

## 8. claude

- Claude Code via l'installeur natif officiel, dans `~/.local/bin/claude`. Il se met à jour tout seul
- votre topic ntfy.sh dans `~/.claude/ntfy-topic` si vous en donnez un, lu par le hook de notification

## 9. dotfiles

Donne `/opt/claude-vps` à votre utilisateur, crée le lien `claude-vps` dans `/usr/local/bin` et lance `claude-vps apply` en votre nom. Tout ce qui se trouve dans `dotfiles/home` est alors écrit dans votre répertoire personnel : config KDE, profils Konsole, `~/.claude/settings.json`, `CLAUDE.md`, hooks, `.tmux.conf`.

## Relancer des étapes

Chaque étape vérifie ce qui est déjà en place, on peut donc relancer sans risque :

```bash
sudo claude-vps setup --only desktop,rdp     # e.g. after a release upgrade
sudo claude-vps setup --skip apps            # everything except Docker and Chrome
sudo claude-vps setup --no-desktop           # terminal-only box
```
