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
| `update` | servidor, como root | Descarga la última versión y vuelve a ejecutar setup con las opciones de la primera instalación |
| `sync` | servidor | `git pull` y después `apply` |
| `autosync on\|off` | servidor | Timer de systemd del usuario que ejecuta `sync` cada 30 minutos |
| `doctor` | servidor | Revisa Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy y autosync |
| `capture` | tu ordenador | Copia los archivos de `dotfiles/manifest.txt` a `dotfiles/home` |
| `publish` | tu ordenador | `capture`, commit y push |
| `release X.Y.Z` | tu ordenador | Escribe `VERSION`, crea la etiqueta `vX.Y.Z` y hace push. GitHub publica la versión a partir de `CHANGELOG.md` |
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

## Actualizar

Cuando salga una versión nueva, ejecuta esto en cada servidor:

```bash
sudo claude-vps update
```

Descarga el código nuevo, te muestra qué ha cambiado y vuelve a ejecutar todos los pasos de setup. Los pasos que ya están hechos se saltan. xrdp y SSH solo se reinician si cambió su configuración, así que una sesión RDP abierta no se corta. Las opciones que elegiste en la primera instalación (usuario, puerto RDP, pasos omitidos) se guardan en `/etc/claude-vps.conf` y se vuelven a usar.

`claude-vps sync` también te avisa cuando llega una versión nueva.

## Publicar una versión

En tu ordenador, añade una sección `## X.Y.Z` a `CHANGELOG.md`, haz commit y después ejecuta:

```bash
claude-vps release X.Y.Z
```

El workflow de release comprueba que la etiqueta coincide con `VERSION` y publica una release en GitHub. Como notas usa esa sección del changelog.

## Máquinas de origen de la configuración

`claude-vps capture` marca la máquina donde se ejecuta como origen de la configuración (`~/.config/claude-vps/source`). En esa máquina, `apply` y `sync` no tocan tus archivos, porque la copia del repo puede ser más antigua que la que estás usando. Si aun así quieres sobrescribirlos, usa `claude-vps apply --force`.

## install.sh

El script de instalación lee tres variables de entorno:

| Variable | Por defecto |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Todo lo que pongas después de `bash -s --` se pasa a `setup`.
