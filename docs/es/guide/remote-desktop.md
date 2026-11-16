---
description: "Conéctate por RDP al escritorio KDE Plasma de tu VPS con Claude Code desde Windows, macOS, Linux, iOS o Android, directamente o por un túnel SSH."
---

# Escritorio remoto

El servidor tiene una sesión completa de KDE Plasma a la que entras por RDP. Se inicia cuando te conectas y sigue abierta cuando te desconectas, así que la próxima vez encuentras las ventanas donde las dejaste.

## Clientes

| Plataforma | Cliente |
| --- | --- |
| Windows | Conexión a Escritorio remoto (`mstsc`), viene con el sistema |
| macOS, iOS, iPadOS | Windows App (antes Microsoft Remote Desktop) |
| Android | Windows App o aRDP |
| Linux | Remmina, o KRDC en KDE |

Conéctate a `<server-ip>:53389`. Si xrdp te pide un tipo de sesión, elige **Xorg**, y entra con tu usuario y contraseña.

## Por un túnel SSH

RDP va cifrado, pero un puerto abierto a internet recibe escaneos igualmente. Si instalaste con `--rdp-private`, o simplemente lo prefieres, usa un túnel:

```bash
ssh -N -L 3389:localhost:53389 dev@<server-ip>
```

Después conecta tu cliente RDP a `localhost:3389`. Lo único expuesto a internet es SSH.

Para cerrar un puerto RDP que ya abriste:

```bash
sudo ufw delete allow 53389/tcp
```

## Consejos de pantalla

- **Resolución**: se ajusta a la ventana del cliente. Cambia el tamaño y vuelve a conectarte.
- **HiDPI**: ajusta la escala en Preferencias del sistema, Pantalla. Se guarda para cada usuario.
- **Conexión lenta**: baja la profundidad de color a 16 bits en el cliente y desactiva las animaciones en Preferencias del sistema, Comportamiento del espacio de trabajo.
- **Portapapeles**: el texto se copia en los dos sentidos sin configurar nada.

## Una sesión por usuario

xrdp te vuelve a conectar a la sesión que ya tienes abierta. Con Plasma no se puede entrar a la vez en local y por RDP con el mismo usuario. En un servidor eso no pasa, porque no tiene pantalla local.
