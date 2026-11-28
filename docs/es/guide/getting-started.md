---
title: "Primeros pasos"
description: "Instala claude-vps en un VPS con Ubuntu 24.04 o 26.04 con un solo comando. En unos diez minutos tienes Claude Code, KDE Plasma por RDP y SSH seguro."
---

# Primeros pasos con claude-vps

claude-vps convierte un servidor Ubuntu recién creado en la máquina donde uso Claude Code. Crea un usuario con sudo, deja SSH solo con clave, activa un firewall e instala un escritorio KDE Plasma al que entras por RDP, Docker, Chrome y el propio Claude Code con mi configuración, mis hooks y mi distribución de KDE ya aplicados.

## Qué necesitas

| | |
| --- | --- |
| **Sistema** | Ubuntu 24.04 LTS o posterior (yo uso la 26.04) |
| **CPU / RAM** | 2 vCPU y 4 GB es el mínimo para Plasma. Con 4 vCPU / 8 GB va como un escritorio de verdad |
| **Disco** | 25 GB o más |
| **Acceso** | root por SSH, mejor si tu clave SSH ya está en el servidor |
| **Arquitectura** | En amd64 y en arm64 se instala todo |

Para iniciar sesión en Claude Code después, necesitas un plan Claude Pro o Max, o una clave de API de Anthropic.

## Instalación

Entra por SSH como root (o con un usuario con sudo) y ejecuta:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

El script clona este repo en `/opt/claude-vps` y ejecuta `claude-vps setup`. Te pregunta dos cosas: el nombre de usuario y su contraseña. La contraseña se usa para sudo y para entrar por RDP. Si la dejas vacía, se genera una y se muestra al final.

Para saltarte las preguntas, pasa las opciones después de `bash -s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

Todas las opciones están en la [referencia de la CLI](/es/reference/cli).

::: tip Pruébalo antes
`--dry-run` muestra cada comando sin ejecutarlo.
:::

## Al terminar

Verás un resumen como este:

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **Entra por SSH** con el usuario nuevo. Las claves SSH de root se copiaron, así que la misma clave te sirve.
2. **Arranca Claude Code** dentro de tmux e inicia sesión. Mira [Usar Claude Code](/es/guide/claude-code).
3. **Abre el escritorio** con cualquier cliente RDP. Mira [Escritorio remoto](/es/guide/remote-desktop).

## Usar tu propia configuración

Por defecto, el servidor recibe mi configuración de KDE y Claude desde `dotfiles/home`. Para usar la tuya, haz un fork del repo, ejecuta `claude-vps capture` en tu ordenador, haz push y apunta el instalador a tu fork:

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

En [Sincronizar la configuración](/es/guide/sync) se explica el proceso completo.
