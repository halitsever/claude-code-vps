---
description: "Referencia de todos los comandos y opciones de claude-vps para tu servidor con Claude Code: setup, sync, autosync, doctor, capture, publish y apply."
---

# CLI

```text
claude-vps <command> [options]
```

| Comando | Dónde | Qué hace |
| --- | --- | --- |
| `setup` | servidor, como root | Ejecuta los pasos de instalación |
| `sync` | servidor | `git pull` y después `apply` |
| `autosync on\|off` | servidor | Timer de systemd del usuario que ejecuta `sync` cada 30 minutos |
| `doctor` | servidor | Revisa Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy y autosync |
| `capture` | tu ordenador | Copia los archivos de `dotfiles/manifest.txt` a `dotfiles/home` |
| `publish` | tu ordenador | `capture`, commit y push |
| `apply` | en cualquier sitio | Copia `dotfiles/home` a `$HOME` y guarda copia de lo que reemplaza |
| `version` | en cualquier sitio | Muestra la versión |

## setup

```bash
sudo claude-vps setup [options]
```

| Opción | Por defecto | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER`, o lo pregunta | Tu usuario. Se crea si no existe |
| `--rdp-port PORT` | `53389` | Puerto de xrdp |
| `--rdp-private` | desactivado | No abre el puerto de RDP en ufw |
| `--ntfy-topic NAME` | lo pregunta | Tema de ntfy.sh para las notificaciones |
| `--timezone TZ` | sin cambios | Por ejemplo `Europe/Istanbul` |
| `--no-desktop` | desactivado | Igual que `--skip desktop,rdp` |
| `--skip a,b` | | Pasos que se saltan |
| `--only a,b` | | Ejecuta solo estos pasos |
| `-y, --yes` | desactivado | Sin preguntas. El usuario será `dev` y la contraseña se genera |
| `-n, --dry-run` | desactivado | Muestra los comandos sin ejecutarlos |

Pasos, en orden: `base user ssh firewall desktop rdp apps claude dotfiles`.

## install.sh

El script de instalación lee tres variables de entorno:

| Variable | Por defecto |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Todo lo que pongas después de `bash -s --` se pasa a `setup`.
