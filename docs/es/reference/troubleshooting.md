---
title: "Solución de problemas"
description: "Soluciona problemas de Claude Code en un VPS: pantalla negra en RDP, aviso de perfil de color, sin acceso SSH, claude no encontrado y fallos de sync."
---

# Cómo resolver los problemas más comunes

Empieza por aquí:

```bash
claude-vps doctor
```

## RDP muestra una pantalla negra y se desconecta

Normalmente falta `~/.xsession` o Plasma ya está abierto para ese usuario.

```bash
cat ~/.xsession                      # debería terminar en: exec startplasma-x11
loginctl list-sessions               # ¿hay una sesión antigua de tu usuario? ciérrala:
loginctl terminate-user $USER
```

Los logs están en `~/.xsession-errors` y `/var/log/xrdp-sesman.log`.

## "Authentication is required to create a color managed device"

La regla de polkit del paso `rdp` resuelve esto. Comprueba que tu usuario está en el grupo `users` (`id`) y vuelve a conectarte.

## No puedo conectarme por RDP

```bash
sudo ss -tlnp | grep xrdp      # ¿escucha en 53389?
sudo ufw status                # ¿está permitido el puerto?
```

Puede que tu proveedor también tenga su propio firewall delante del servidor.

## Me he quedado sin acceso por SSH

El paso `ssh` solo desactiva el acceso con contraseña si tu usuario tiene una clave. Si aun así te pasa, entra por la consola web de tu proveedor y ejecuta:

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

El instalador nativo lo pone en `~/.local/bin`. Ubuntu añade esa carpeta al `PATH` al iniciar sesión, siempre que exista. Cierra sesión y vuelve a entrar, o ejecuta `source ~/.profile`.

## `claude-vps sync` dice "Not possible to fast-forward"

El clon del servidor tiene cambios locales. En el servidor solo se debería hacer pull:

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## Recuperar un archivo antiguo

Cada `apply` guarda una copia de lo que sobrescribe:

```bash
ls ~/.local/state/claude-vps/
```
