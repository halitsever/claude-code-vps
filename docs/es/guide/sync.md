---
description: "Mantén sincronizada tu configuración de KDE Plasma y Claude Code entre tu ordenador y tu VPS con claude-vps publish, sync y autosync."
---

# Sincronizar la configuración

Toda la configuración del servidor vive en el repo. Tú haces los cambios en tu ordenador y el servidor los recibe después.

```text
 tu ordenador                  GitHub                     servidor
 ────────────                  ──────                     ────────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (o autosync, cada 30 min)
```

## En tu ordenador

Clona el repo una vez y pon la CLI en tu PATH:

```bash
git clone https://github.com/halitsever/claude-code-vps.git ~/claude-code-vps
ln -s ~/claude-code-vps/bin/claude-vps ~/.local/bin/claude-vps
```

Cuando cambies un panel, un atajo, tu perfil de Konsole o `~/.claude/settings.json`:

```bash
claude-vps publish
```

Esto ejecuta `capture`, hace commit de `dotfiles/` y hace push. Si prefieres revisar los cambios antes:

```bash
claude-vps capture
git -C ~/claude-code-vps diff
```

## En el servidor

```bash
claude-vps sync
```

Hace pull y ejecuta `apply`. Antes de sobrescribir un archivo, lo copia en `~/.local/state/claude-vps/backup-<timestamp>/`. Los archivos que no han cambiado no se tocan.

También puede hacerlo solo:

```bash
claude-vps autosync on     # timer de systemd del usuario, cada 30 minutos
claude-vps autosync        # muestra cuándo se ejecuta la próxima vez
claude-vps autosync off
```

::: warning Plasma y las sesiones abiertas
Plasma guarda algunos ajustes en memoria y los escribe al cerrar sesión. Si llega una sincronización mientras estás conectado por RDP, cierra sesión y vuelve a entrar para ver los cambios. Mientras tanto, no cambies ese mismo ajuste en el servidor.
:::

## Qué se copia

La lista está en [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/manifest.txt). Una barra al final significa la carpeta entera.

| Área | Archivos |
| --- | --- |
| Plasma | `kdeglobals`, `kwinrc`, `kglobalshortcutsrc`, `plasmarc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kdedefaults/`, ajustes de energía y notificaciones |
| Aplicaciones | `dolphinrc`, `konsolerc`, `katerc`, `~/.local/share/konsole/`, ajustes del tema GTK, `mimeapps.list` |
| Apariencia | `~/.local/share/color-schemes/`, `plasma/`, `aurorae/`, `wallpapers/` si existen |
| Claude | `~/.claude/settings.json`, `hooks/` |
| Shell | `.tmux.conf`, `.xsession` |

Para seguir otro archivo, añade una línea al manifest. Las rutas que no existen en tu ordenador se saltan.

## Qué no se copia nunca

Tu ruta personal se cambia por `@HOME@` para que los archivos funcionen con cualquier nombre de usuario, y se quitan las secciones con archivos recientes o historial. Las credenciales no están en la lista: `~/.claude/.credentials.json`, `~/.claude/ntfy-topic`, claves SSH, `kwalletrc` y perfiles del navegador. No las añadas, el repo es público.
