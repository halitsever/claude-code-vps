---
title: "Installer Claude Code sur un VPS : le guide complet"
description: "Guide pas à pas pour installer Claude Code sur un VPS Ubuntu : SSH sécurisé, sessions tmux qui restent actives, notifications sur mobile et bureau KDE en RDP."
---

# Installer Claude Code sur un VPS

Cette page décrit mon installation complète, étape par étape, à la main. J'utilise un serveur Ubuntu pas cher qui fait tourner Claude Code jour et nuit. Je m'y connecte en SSH depuis n'importe où. Quand j'ai besoin d'un vrai écran, j'ouvre un bureau KDE Plasma en RDP.

Toutes les commandes ci-dessous sont celles que [`claude-vps setup`](/fr/guide/getting-started) lance pour vous. Lisez cette page pour comprendre ce qui se passe, ou pour tout faire vous-même.

## Pourquoi faire tourner Claude Code sur un VPS

- **Le travail continue quand votre portable est en veille.** Les gros refactorings, les tests et les migrations se terminent pendant votre absence.
- **Votre ordinateur reste propre.** Les agents installent des paquets, lancent Docker et des serveurs de dev sur une machine que vous pouvez effacer et réinstaller en dix minutes.
- **Le même environnement partout.** Depuis un portable, un PC, une tablette ou un téléphone, vous retrouvez la même session tmux et le même bureau.
- **Un réseau rapide**, proche de votre hébergeur git et des registres de paquets.

## Choisir un serveur

| Usage | vCPU | RAM | Disque |
| --- | --- | --- | --- |
| Terminal seul | 2 | 4 Go | 40 Go |
| Avec le bureau KDE | 4 | 8 Go | 80 Go |
| Plusieurs agents et Docker | 8 | 16 Go | 160 Go |

Tout hébergeur qui propose Ubuntu 24.04 LTS ou plus récent fait l'affaire : Hetzner, DigitalOcean, OVH, Vultr, Linode, AWS Lightsail, ou une machine inutilisée chez vous. Choisissez une région proche de vous, le bureau RDP sera plus réactif. Ajoutez votre clé SSH publique à la création du serveur : vous n'aurez jamais besoin du mot de passe root.

## 1. Première connexion et mises à jour

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades` installe les correctifs de sécurité tout seul. C'est important sur une machine connectée en permanence.

Sur un petit serveur, ajoutez du swap. Sinon, un agent qui consomme beaucoup de mémoire peut déclencher l'OOM killer :

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. Créer votre utilisateur

Ne lancez pas Claude Code en root. Créez un utilisateur normal avec sudo :

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

Avant de continuer, ouvrez un second terminal et vérifiez que `ssh dev@<server-ip>` fonctionne.

## 3. Sécuriser SSH

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd garde la première valeur qu'il lit, et il lit les fichiers par ordre alphabétique. Le nom commence donc par `10-` pour passer avant `50-cloud-init.conf`. Beaucoup d'images cloud fournissent ce fichier avec `PasswordAuthentication yes`.

## 4. Pare-feu

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # seulement si vous voulez RDP depuis Internet, voir plus bas
ufw --force enable
```

## 5. Installer Claude Code

Connectez-vous avec votre utilisateur et utilisez l'installateur officiel. Il n'a pas besoin de Node.js et se met à jour tout seul :

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

Le programme est installé dans `~/.local/bin/claude`. Déconnectez-vous et reconnectez-vous une fois pour que ce dossier soit dans votre `PATH`, puis vérifiez :

```bash
claude --version
```

## 6. Se connecter sur un serveur sans écran

Le serveur n'a pas de navigateur, et vous n'en avez pas besoin :

```bash
claude
```

Claude Code affiche une URL. Ouvrez-la sur votre ordinateur ou votre téléphone, validez, puis collez le code dans le terminal. La session est enregistrée dans `~/.claude` sur le serveur.

Si vous utilisez une clé API Anthropic au lieu d'un abonnement Pro ou Max, ajoutez-la à votre profil shell :

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## 7. Garder les sessions actives avec tmux

Si Claude tourne directement dans votre session SSH, il s'arrête quand vous fermez votre portable. Lancez-le dans tmux :

```bash
tmux new -s claude
claude
# Ctrl-b puis d pour se détacher, l'agent continue de travailler
tmux attach -t claude   # plus tard, depuis n'importe quel appareil
```

Un petit `~/.tmux.conf` rend tmux plus agréable :

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Être prévenu quand Claude a besoin de vous

Quand Claude Code attend une réponse, il déclenche un hook `Notification`. Envoyez-le sur votre téléphone avec [ntfy.sh](https://ntfy.sh) :

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude attend votre réponse"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
EOF
chmod +x ~/.claude/hooks/notify.sh
echo my-hard-to-guess-topic > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
```

Déclarez-le dans `~/.claude/settings.json` :

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

Abonnez-vous au même sujet dans l'application ntfy. Gardez ce nom de sujet secret, comme un mot de passe.

## 9. En option : un bureau KDE Plasma en RDP

Le terminal suffit pour la plupart des tâches. Un bureau est pratique quand vous voulez Chrome à côté de l'agent, un gestionnaire de fichiers ou plusieurs fenêtres Konsole sur un grand écran.

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

Sur Ubuntu 24.04, `plasma-session-x11` et `kwin-x11` n'existent pas en paquets séparés. Retirez-les de la commande.

Indiquez à xrdp de lancer Plasma pour votre utilisateur :

```bash
cat > ~/.xsession <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
sudo systemctl restart xrdp
```

Supprimez ensuite la demande de mot de passe pour les profils de couleur. Sans ça, elle apparaît à chaque connexion :

```bash
sudo tee /etc/polkit-1/rules.d/45-colord.rules >/dev/null <<'EOF'
polkit.addRule(function (action, subject) {
  if (action.id.indexOf("org.freedesktop.color-manager.") === 0 && subject.isInGroup("users")) {
    return polkit.Result.YES;
  }
});
EOF
sudo usermod -aG users dev
```

Connectez n'importe quel client RDP à `<server-ip>:53389`. La page [Bureau à distance](/fr/guide/remote-desktop) donne plus de détails, notamment pour garder le port fermé et passer par un tunnel SSH.

## 10. Outils de développement

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## Liste de vérification sécurité

- SSH uniquement par clé, connexion root par mot de passe désactivée
- Pare-feu actif, avec seulement les ports nécessaires
- Claude Code tourne avec un utilisateur normal, pas en root
- `--dangerously-skip-permissions` seulement dans des conteneurs jetables, jamais sur une machine qui contient vos tokens et vos clés SSH
- Les secrets (`~/.claude/.credentials.json`, clés API, sujet ntfy) ne vont jamais dans un dépôt public
- Mises à jour automatiques actives

## Tout faire en une commande

claude-vps automatise tout ce qui précède, et applique en plus vos propres réglages KDE et Claude :

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Voir [Bien démarrer](/fr/guide/getting-started).

## Questions fréquentes

### Claude Code fonctionne-t-il sur un serveur sans interface graphique ?

Oui. C'est un programme en ligne de commande. Pour la connexion, vous ouvrez un lien sur n'importe quel autre appareil.

### Quel abonnement Claude faut-il ?

Un abonnement qui inclut Claude Code (Pro ou Max), ou une clé API Anthropic facturée à l'usage.

### Combien coûte un VPS pour Claude Code ?

Chez les hébergeurs pas chers, un serveur avec 4 à 8 Go de RAM coûte en général entre 5 et 20 USD par mois. L'utilisation de Claude est facturée à part, selon votre abonnement ou votre clé API.

### Claude continue-t-il de tourner après la fermeture de SSH ?

Seulement dans tmux (ou screen). Lancez-le avec `tmux new -s claude` et détachez-vous avec `Ctrl-b d`.

### Est-ce sûr ?

Autant que n'importe quel serveur que vous gérez vous-même. Suivez la liste de vérification ci-dessus et ne donnez pas à l'agent des accès dont il n'a pas besoin.
