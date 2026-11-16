---
description: "Cada paso que claude-vps ejecuta en tu servidor Ubuntu: paquetes, swap, SSH, ufw, KDE Plasma, xrdp, Docker, Chrome, Claude Code y tus dotfiles."
---

# Qué se instala

`claude-vps setup` ejecuta nueve pasos en orden. Cada uno es una función de bash normal en [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh), así que puedes leer exactamente qué se ejecuta en tu servidor. Puedes saltarte cualquiera con `--skip`, o ejecutar solo algunos con `--only`.

## 1. base

- `apt upgrade` de todo el sistema
- `git curl jq ripgrep fd-find tmux htop build-essential python3` y otras herramientas parecidas
- Node.js 20 o más reciente. En Ubuntu 24.04 apt solo tiene la 18, así que ahí se instala desde el repositorio de NodeSource
- `unattended-upgrades` activado, para que los parches de seguridad se instalen sin que hagas nada
- un archivo de swap de 4 GB si el servidor no tiene swap y tiene menos de 8 GB de RAM. Así Plasma y varios agentes no hacen saltar el OOM killer
- la zona horaria, si pasas `--timezone`

## 2. user

Crea tu usuario, lo añade al grupo `sudo` y le copia `/root/.ssh/authorized_keys` si todavía no tiene claves. La contraseña que elijas es la que escribirás en la pantalla de inicio de sesión de RDP.

## 3. ssh

Escribe `/etc/ssh/sshd_config.d/10-claude-vps.conf`:

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd se queda con el primer valor que lee. Por eso el nombre del archivo empieza por `10-`: así se aplica antes que el `50-cloud-init.conf` que traen la mayoría de imágenes de proveedores. Si tu usuario todavía no tiene clave SSH, el paso se salta con un aviso, para que nunca te quedes sin acceso.

## 4. firewall

`ufw` deja pasar OpenSSH y el puerto de RDP, y cierra todo lo demás. Con `--rdp-private` el puerto de RDP queda cerrado y entras por un túnel SSH.

## 5. desktop

`kde-plasma-desktop` y la sesión X11 (`plasma-session-x11`, `kwin-x11` en Ubuntu 25.10 o posterior), Konsole, Dolphin, Kate, Spectacle y las fuentes Noto y JetBrains Mono. SDDM se desactiva y el arranque se configura en `multi-user`. Nadie se sienta delante de un servidor, así que arranca directamente en consola y Plasma solo se inicia cuando te conectas.

::: info Por qué X11
xrdp funciona con una sesión de Xorg. Plasma 6 sigue incluyendo una sesión X11 en Ubuntu 24.04 a 26.04, y es la que uso a diario por RDP.
:::

## 6. rdp

- `xrdp` y `xorgxrdp`, escuchando en el puerto **53389** (se cambia con `--rdp-port`)
- un `~/.xsession` que arranca `startplasma-x11` con las variables `XDG_*` correctas
- una regla de polkit que quita el aviso "authentication is required to create a color managed device", que si no aparece en cada inicio de sesión

## 7. apps

- Docker (`docker.io`, compose v2, buildx), con tu usuario en el grupo `docker`
- GitHub CLI (`gh`)
- Google Chrome desde el repositorio apt de Google (solo amd64). Viene bien cuando Claude necesita un navegador de verdad

## 8. claude

- Claude Code con el instalador nativo oficial, en `~/.local/bin/claude`. Se actualiza solo
- [claudegrid](https://github.com/halitsever/claudegrid) desde su último release `.deb`, para abrir una cuadrícula de agentes de Claude Code en Konsole o tmux con un solo comando. También añade un perfil de Konsole y una entrada en el menú de aplicaciones
- tu tema de ntfy.sh en `~/.claude/ntfy-topic`, si lo indicas. El hook de notificaciones lo lee de ahí

## 9. dotfiles

Da a tu usuario la propiedad de `/opt/claude-vps`, enlaza `claude-vps` en `/usr/local/bin` y ejecuta `claude-vps apply` con tu usuario. Eso copia todo lo que hay en `dotfiles/home` a tu carpeta personal: configuración de KDE, perfiles de Konsole, `~/.claude/settings.json`, `CLAUDE.md`, hooks y `.tmux.conf`.

## Volver a ejecutar pasos

Cada paso comprueba lo que ya está instalado, así que puedes ejecutarlo otra vez sin problema:

```bash
sudo claude-vps setup --only desktop,rdp     # por ejemplo, después de actualizar de versión
sudo claude-vps setup --skip apps            # todo menos Docker y Chrome
sudo claude-vps setup --no-desktop           # servidor solo con terminal
```
