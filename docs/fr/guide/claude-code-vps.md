---
title: "Installer Claude Code sur un VPS, le guide complet"
description: "Guide pas à pas pour faire tourner Claude Code sur un VPS Ubuntu. SSH sécurisé, sessions tmux persistantes, notifications sur mobile et bureau KDE Plasma via RDP."
---

# Installer Claude Code sur un VPS

Voici la version complète et manuelle de mon setup : un serveur Ubuntu bon marché qui fait tourner Claude Code jour et nuit. Je m'y connecte en SSH depuis n'importe où et, quand je veux un vrai écran, via un bureau KDE Plasma en RDP.

Chaque commande ci-dessous est ce que [`claude-vps setup`](/fr/guide/getting-started) exécute pour vous. Lisez cette page pour comprendre ce qui se passe, ou pour tout faire à la main.

## Pourquoi faire tourner Claude Code sur un VPS

- **Il continue de travailler quand votre portable est en veille.** Les longs refactorings, les suites de tests et les migrations se terminent pendant votre absence.
- **Votre machine reste propre.** Les agents installent des paquets, lancent Docker et démarrent des serveurs de dev sur une machine que vous pouvez effacer et reconstruire en dix minutes.
- **Le même environnement partout.** Portable, fixe, tablette ou téléphone : vous retrouvez la même session tmux et le même bureau.
- **Un réseau rapide**, proche de votre hébergeur git et des registres de paquets.

## Choisir un serveur

| Usage | vCPU | RAM | Disque |
| --- | --- | --- | --- |
| Terminal uniquement | 2 | 4 Go | 40 Go |
| Avec le bureau KDE | 4 | 8 Go | 80 Go |
| Plusieurs agents plus Docker | 8 | 16 Go | 160 Go |

N'importe quel hébergeur proposant Ubuntu 24.04 LTS ou plus récent fait l'affaire : Hetzner, DigitalOcean, OVH, Vultr, Linode, AWS Lightsail, ou une machine qui traîne à la maison. Choisissez une région proche de chez vous pour une session RDP plus réactive. Ajoutez votre clé SSH publique à la création du serveur pour ne jamais avoir besoin du mot de passe root.

## 1. Première connexion et mises à jour

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades` installe les correctifs de sécurité tout seul, ce qui compte sur une machine connectée en permanence.

Sur un petit serveur, ajoutez du swap pour qu'un agent chargé ne déclenche pas l'OOM killer :

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. Créer votre utilisateur

Ne lancez pas Claude Code en root. Donnez-lui un utilisateur normal avec sudo :

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

Ouvrez un second terminal et vérifiez que `ssh dev@<server-ip>` fonctionne avant de continuer.

## 3. Verrouiller SSH

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd retient la première valeur qu'il lit, et les fichiers sont chargés par ordre alphabétique. D'où le préfixe `10-` : le fichier doit passer avant le `50-cloud-init.conf` que beaucoup d'images cloud livrent avec `PasswordAuthentication yes`.

## 4. Pare-feu

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # seulement si vous voulez le RDP depuis internet, voir plus bas
ufw --force enable
```

## 5. Installer Claude Code

Connectez-vous avec votre utilisateur et utilisez l'installeur natif. Il n'a pas besoin de Node.js et se met à jour tout seul :

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

Il s'installe dans `~/.local/bin/claude`. Déconnectez-vous puis reconnectez-vous une fois pour que ce dossier soit dans votre `PATH`, puis vérifiez :

```bash
claude --version
```

## 6. Se connecter sur un serveur sans écran

Il n'y a pas de navigateur sur le serveur, et vous n'en avez pas besoin :

```bash
claude
```

Claude Code affiche une URL. Ouvrez-la sur votre ordinateur ou votre téléphone, validez, et recollez le code dans le terminal. La session est stockée dans `~/.claude` sur le serveur.

Avec une clé API Anthropic plutôt qu'un abonnement Pro ou Max, mettez-la dans votre profil shell :

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## 7. Garder les sessions en vie avec tmux

Si Claude tourne directement dans votre session SSH, fermer le portable le tue. Lancez-le dans tmux :

```bash
tmux new -s claude
claude
# Ctrl-b puis d pour se détacher, l'agent continue
tmux attach -t claude   # plus tard, depuis n'importe quel appareil
```

Un petit `~/.tmux.conf` rend le tout plus agréable :

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Être prévenu quand Claude a besoin de vous

Claude Code déclenche un hook `Notification` quand il attend une réponse. Envoyez-le sur votre téléphone avec [ntfy.sh](https://ntfy.sh) :

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude vous attend"')
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

Abonnez-vous au même topic dans l'application ntfy. Traitez ce topic comme un mot de passe.

## 9. En option : un bureau KDE Plasma via RDP

Le terminal couvre l'essentiel du travail. Un bureau est utile quand vous voulez Chrome à côté de l'agent, un gestionnaire de fichiers, ou plusieurs fenêtres Konsole sur un grand écran.

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

Puis supprimez la demande de mot de passe liée aux profils de couleur, qui apparaît sinon à chaque connexion :

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

Connectez n'importe quel client RDP à `<server-ip>:53389`. Plus de détails dans [Bureau à distance](/fr/guide/remote-desktop), y compris comment garder le port fermé et passer par un tunnel SSH.

## 10. Outils de dev

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## Check-list sécurité

- SSH par clé uniquement, connexion root par mot de passe désactivée
- Pare-feu actif, seulement les ports nécessaires
- Claude Code tourne sous un utilisateur normal, pas en root
- `--dangerously-skip-permissions` uniquement dans des conteneurs jetables, jamais sur une machine qui contient vos tokens et vos clés SSH
- Les secrets (`~/.claude/.credentials.json`, clés API, topic ntfy) ne vont jamais dans un dépôt public
- Mises à jour automatiques activées

## Tout faire en une commande

Tout ce qui précède, plus l'application de votre propre config KDE et Claude, c'est ce que claude-vps automatise :

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Voir [Bien démarrer](/fr/guide/getting-started).

## FAQ

### Claude Code peut-il tourner sur un serveur sans interface graphique ?

Oui. C'est une application en terminal. La connexion passe par un lien que vous ouvrez sur n'importe quel autre appareil.

### Quel abonnement Claude faut-il ?

N'importe quel abonnement qui inclut Claude Code (Pro ou Max), ou une clé API Anthropic facturée à l'usage.

### Combien coûte un VPS pour Claude Code ?

Le serveur coûte en général 5 à 20 USD par mois pour 4 à 8 Go de RAM chez les hébergeurs économiques. L'utilisation de Claude est facturée à part, selon votre abonnement ou votre clé API.

### Claude continue-t-il de tourner quand je ferme SSH ?

Seulement dans tmux (ou screen). Lancez-le avec `tmux new -s claude`, détachez-vous avec `Ctrl-b d`.

### Est-ce sûr ?

Autant que n'importe quel serveur que vous gérez vous-même. Suivez la check-list ci-dessus et tenez l'agent à l'écart des identifiants dont il n'a pas besoin.
