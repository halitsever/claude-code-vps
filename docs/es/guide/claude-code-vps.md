---
title: "Cómo usar Claude Code en un VPS"
description: "Guía paso a paso para montar Claude Code en un VPS con Ubuntu: SSH seguro, sesiones de tmux que no se cierran, avisos al móvil y escritorio KDE por RDP."
---

# Cómo usar Claude Code en un VPS

Esta es mi instalación completa, hecha a mano. Un servidor Ubuntu barato que tiene Claude Code funcionando día y noche. Me conecto por SSH desde cualquier sitio y, cuando quiero una pantalla de verdad, entro a un escritorio KDE Plasma por RDP.

Cada comando de esta página es lo que [`claude-vps setup`](/es/guide/getting-started) ejecuta por ti. Léela para entender qué pasa, o para hacerlo todo a mano.

## Por qué usar Claude Code en un VPS

- **Sigue trabajando aunque tu portátil se suspenda.** Los refactors largos, los tests y las migraciones terminan mientras no estás.
- **Tu ordenador queda limpio.** Los agentes instalan paquetes, usan Docker y levantan servidores de desarrollo en una máquina que puedes borrar y volver a montar en diez minutos.
- **El mismo entorno desde cualquier sitio.** Portátil, sobremesa, tablet o móvil: te conectas a la misma sesión de tmux y al mismo escritorio.
- **Red rápida**, cerca de tu servidor de git y de los repositorios de paquetes.

## Elige un servidor

| Uso | vCPU | RAM | Disco |
| --- | --- | --- | --- |
| Solo terminal | 2 | 4 GB | 40 GB |
| Con escritorio KDE | 4 | 8 GB | 80 GB |
| Varios agentes y Docker | 8 | 16 GB | 160 GB |

Sirve cualquier proveedor que ofrezca Ubuntu 24.04 LTS o posterior: Hetzner, DigitalOcean, OVH, Vultr, Linode, AWS Lightsail o un ordenador que tengas libre en casa. Elige una región cercana para que RDP vaya más fluido. Añade tu clave pública SSH al crear el servidor, así nunca necesitarás la contraseña de root.

## 1. Primer acceso y actualizaciones

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades` instala los parches de seguridad por su cuenta. Es importante en una máquina que está siempre conectada.

En servidores pequeños conviene añadir swap. Así un agente con mucha carga no hace saltar el OOM killer:

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. Crea tu usuario

No ejecutes Claude Code como root. Crea un usuario normal con sudo:

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

Antes de seguir, abre otra terminal y comprueba que `ssh dev@<server-ip>` funciona.

## 3. Protege SSH

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd se queda con el primer valor que lee, y carga los archivos por orden alfabético. Por eso el nombre empieza por `10-`: tiene que cargarse antes que `50-cloud-init.conf`, que muchas imágenes de proveedores traen con `PasswordAuthentication yes`.

## 4. Firewall

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # solo si quieres RDP desde internet, mira más abajo
ufw --force enable
```

## 5. Instala Claude Code

Entra con tu usuario y usa el instalador nativo. No necesita Node.js y se actualiza solo:

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

Se instala en `~/.local/bin/claude`. Cierra la sesión y vuelve a entrar una vez para que esa carpeta esté en tu `PATH`, y compruébalo:

```bash
claude --version
```

## 6. Inicia sesión en un servidor sin pantalla

En el servidor no hay navegador, y no hace falta:

```bash
claude
```

Claude Code muestra una URL. Ábrela en tu ordenador o en tu móvil, acepta y pega el código en la terminal. La sesión se guarda en `~/.claude` en el servidor.

Si usas una clave de API de Anthropic en lugar de un plan Pro o Max, ponla en el perfil de tu shell:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## 7. Mantén las sesiones abiertas con tmux

Si Claude se ejecuta directamente en tu sesión SSH, al cerrar el portátil se detiene. Ejecútalo dentro de tmux:

```bash
tmux new -s claude
claude
# Ctrl-b y luego d para salir, el agente sigue trabajando
tmux attach -t claude   # más tarde, desde cualquier dispositivo
```

Un `~/.tmux.conf` pequeño lo hace más cómodo:

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Recibe un aviso cuando Claude te necesite

Claude Code lanza un hook `Notification` cuando espera tu respuesta. Puedes mandarlo a tu móvil con [ntfy.sh](https://ntfy.sh):

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude te está esperando"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
EOF
chmod +x ~/.claude/hooks/notify.sh
echo my-hard-to-guess-topic > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
```

Regístralo en `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

Suscríbete al mismo tema en la app de ntfy. Trata el nombre del tema como una contraseña.

## 9. Opcional: escritorio KDE Plasma por RDP

Con la terminal haces casi todo. El escritorio ayuda cuando quieres Chrome al lado del agente, un explorador de archivos o varias ventanas de Konsole en una pantalla grande.

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

En Ubuntu 24.04 no existen los paquetes `plasma-session-x11` y `kwin-x11` por separado. Quítalos del comando.

Indica a xrdp que arranque Plasma para tu usuario:

```bash
cat > ~/.xsession <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
sudo systemctl restart xrdp
```

Después quita la petición de contraseña sobre perfiles de color, que si no aparece en cada inicio de sesión:

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

Conéctate a `<server-ip>:53389` con cualquier cliente RDP. Tienes más detalles en [Escritorio remoto](/es/guide/remote-desktop), también cómo dejar el puerto cerrado y entrar por un túnel SSH.

## 10. Herramientas de desarrollo

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## Lista de seguridad

- SSH solo con clave, sin acceso de root con contraseña
- Firewall activado, solo con los puertos que necesitas
- Claude Code se ejecuta con un usuario normal, no como root
- `--dangerously-skip-permissions` solo en contenedores desechables, nunca en una máquina con tus tokens y claves SSH
- Los secretos (`~/.claude/.credentials.json`, claves de API, tema de ntfy) nunca van a un repo público
- Actualizaciones automáticas activadas

## Todo con un solo comando

claude-vps automatiza todo lo anterior y además aplica tu propia configuración de KDE y Claude:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Mira [Primeros pasos](/es/guide/getting-started).

## Preguntas frecuentes

### ¿Funciona Claude Code en un servidor sin interfaz gráfica?

Sí. Es una aplicación de terminal. El inicio de sesión se hace con un enlace que abres en otro dispositivo.

### ¿Qué plan de Claude necesito?

Cualquier plan que incluya Claude Code (Pro o Max), o una clave de API de Anthropic que se paga por uso.

### ¿Cuánto cuesta un VPS para Claude Code?

En proveedores económicos, un servidor con 4 a 8 GB de RAM suele costar entre 5 y 20 USD al mes. El uso de Claude se paga aparte, con tu plan o tu clave de API.

### ¿Claude sigue funcionando si cierro SSH?

Solo si está dentro de tmux (o screen). Arráncalo con `tmux new -s claude` y sal con `Ctrl-b d`.

### ¿Es seguro?

Tanto como cualquier servidor que administres tú. Sigue la lista de arriba y no le des al agente credenciales que no necesita.
