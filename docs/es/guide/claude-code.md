---
description: "Inicia sesión en Claude Code en un servidor sin pantalla, mantén los agentes en tmux aunque se corte SSH y recibe avisos en el móvil con ntfy.sh."
---

# Usar Claude Code

## Primer inicio de sesión

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Claude Code muestra un enlace para iniciar sesión. Ábrelo en tu navegador, acepta y pega el código en la terminal. Las credenciales se guardan en `~/.claude` en el servidor.

¿Prefieres una clave de API? Expórtala antes de arrancar:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## Mantenerlo en marcha con tmux

Un agente que trabaja una hora no debería pararse porque tu portátil se ha suspendido. Ejecútalo dentro de tmux y sal de la sesión sin cerrarla:

| | |
| --- | --- |
| Salir sin cerrar | `Ctrl-b` y luego `d` |
| Volver a entrar | `tmux attach -t claude` |
| Ventana nueva | `Ctrl-b` y luego `c` |
| Ver sesiones | `tmux ls` |

El `.tmux.conf` incluido activa el ratón, un historial de 50 000 líneas y 256 colores.

También puedes abrir Konsole en el escritorio y ejecutar ahí `tmux attach -t claude`. Es la misma sesión, en una pantalla más grande.

## Avisos en el móvil

`~/.claude/settings.json` registra un hook `Notification`, `~/.claude/hooks/notify.sh`, que manda un mensaje a [ntfy.sh](https://ntfy.sh) cada vez que Claude espera tu respuesta.

1. Instala la app de ntfy en el móvil y suscríbete a un tema que nadie pueda adivinar, por ejemplo `claude-7f3k9q2m`.
2. Pon el mismo tema en el servidor:

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   O pásalo con `--ntfy-topic` durante la instalación.

El tema es secreto: cualquiera que lo conozca puede leer tus notificaciones. Por eso está en un archivo aparte y nunca se copia al repo.

## Qué viene configurado

Desde `dotfiles/home/.claude`:

- **`settings.json`**: tema oscuro, interfaz a pantalla completa, una barra de estado con el modelo, la carpeta, la rama de git y el uso de contexto, los plugins que uso y el hook de notificaciones
- **`CLAUDE.md`**: un archivo vacío para tus instrucciones globales. Solo se crea si no existe, así que lo que escribas ahí nunca se sobrescribe
- **`hooks/notify.sh`**: el hook de ntfy de arriba

Cambia cualquiera de ellos en tu ordenador y ejecuta `claude-vps publish`. Mira [Sincronizar la configuración](/es/guide/sync).

## Actualizar Claude Code

La instalación nativa se actualiza sola en segundo plano. Para forzarlo:

```bash
claude update
```
