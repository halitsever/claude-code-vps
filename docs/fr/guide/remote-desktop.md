---
title: "Bureau à distance"
description: "Connectez-vous en RDP au bureau KDE Plasma de votre VPS Claude Code depuis Windows, macOS, Linux, iOS ou Android, en direct ou par un tunnel SSH."
---

# Bureau à distance via RDP

Le serveur fait tourner une session KDE Plasma complète, accessible en RDP. Elle démarre quand vous vous connectez et continue de tourner après la déconnexion. À la connexion suivante, vos fenêtres sont toujours là où vous les avez laissées.

## Clients

| Plateforme | Client |
| --- | --- |
| Windows | Connexion Bureau à distance (`mstsc`), déjà installé |
| macOS, iOS, iPadOS | Windows App (l'ancien Microsoft Remote Desktop) |
| Android | Windows App ou aRDP |
| Linux | Remmina, ou KRDC sous KDE |

Connectez-vous à `<server-ip>:53389`. Si xrdp demande un type de session, choisissez **Xorg**. Entrez ensuite le nom et le mot de passe de votre utilisateur.

## Par un tunnel SSH

RDP est chiffré, mais un port ouvert sur Internet est quand même scanné en permanence. Si vous avez installé avec `--rdp-private`, ou si vous préférez simplement, passez par un tunnel :

```bash
ssh -N -L 3389:localhost:53389 dev@<server-ip>
```

Connectez ensuite votre client RDP à `localhost:3389`. Seul SSH est exposé sur Internet.

Pour fermer un port RDP déjà ouvert :

```bash
sudo ufw delete allow 53389/tcp
```

## Conseils d'affichage

- **Résolution** : elle suit la taille de la fenêtre du client. Redimensionnez, reconnectez-vous, c'est tout.
- **Écran haute résolution** : réglez l'échelle dans Configuration du système, Affichage. Le réglage est gardé pour chaque utilisateur.
- **Connexion lente** : passez la profondeur de couleur à 16 bits dans votre client, et désactivez les animations dans Configuration du système, Comportement de l'espace de travail.
- **Presse-papiers** : le copier-coller de texte marche dans les deux sens, sans rien configurer.

## Une session par utilisateur

xrdp vous reconnecte à votre session déjà ouverte. Avec Plasma, un même utilisateur ne peut pas être connecté en local et en RDP en même temps. Sur un serveur, ça n'arrive pas, puisqu'il n'y a pas d'écran local.
