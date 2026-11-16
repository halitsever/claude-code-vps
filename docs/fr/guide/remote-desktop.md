---
description: "Connectez-vous au bureau KDE Plasma de votre VPS Claude Code via RDP depuis Windows, macOS, Linux, iOS ou Android, en direct ou via un tunnel SSH."
---

# Bureau à distance

Le serveur fait tourner une session KDE Plasma complète en RDP. Elle démarre à la connexion et continue de tourner après la déconnexion : vos fenêtres sont toujours là où vous les avez laissées.

## Clients

| Plateforme | Client |
| --- | --- |
| Windows | Connexion Bureau à distance (`mstsc`), intégré |
| macOS, iOS, iPadOS | Windows App (anciennement Microsoft Remote Desktop) |
| Android | Windows App ou aRDP |
| Linux | Remmina, ou KRDC sous KDE |

Connectez-vous à `<server-ip>:53389`, choisissez **Xorg** si xrdp demande un type de session, et identifiez-vous avec l'utilisateur et le mot de passe du poste de travail.

## Via un tunnel SSH

RDP est chiffré, mais un port ouvert sur Internet se fait quand même scanner. Si vous avez installé avec `--rdp-private`, ou si vous préférez simplement, passez par un tunnel :

```bash
ssh -N -L 3389:localhost:53389 dev@<server-ip>
```

Connectez ensuite votre client RDP à `localhost:3389`. Seul SSH est exposé.

Pour fermer un port RDP déjà ouvert :

```bash
sudo ufw delete allow 53389/tcp
```

## Conseils d'affichage

- **Résolution** : elle suit la fenêtre du client. Redimensionnez, reconnectez, c'est réglé.
- **HiDPI** : réglez la mise à l'échelle dans Configuration du système, Affichage. Le réglage est conservé par utilisateur.
- **Connexion lente** : passez la profondeur de couleur à 16 bits dans votre client et désactivez les animations dans Configuration du système, Comportement de l'espace de travail.
- **Presse-papiers** : le texte passe dans les deux sens sans rien configurer.

## Une session par utilisateur

xrdp vous reconnecte à votre session en cours. Avec Plasma, se connecter en local et en RDP en même temps avec le même utilisateur ne fonctionne pas. Sur un serveur, ça n'arrive jamais puisqu'il n'y a pas d'écran local.
