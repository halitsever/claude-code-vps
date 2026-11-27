---
description: "Connect to a KDE Plasma desktop on your Claude Code VPS over RDP from Windows, macOS, Linux, iOS or Android, directly or through an SSH tunnel."
---

# Remote desktop

The server runs a full KDE Plasma session over RDP. It starts when you connect and keeps running when you disconnect, so windows are still where you left them next time.

## Clients

| Platform | Client |
| --- | --- |
| Windows | Remote Desktop Connection (`mstsc`), built in |
| macOS, iOS, iPadOS | Windows App (formerly Microsoft Remote Desktop) |
| Android | Windows App or aRDP |
| Linux | Remmina, or KRDC on KDE |

Connect to `<server-ip>:53389`, pick **Xorg** if xrdp asks for a session type, and log in with your workstation user and password.

## Over Tailscale

With [Tailscale](https://tailscale.com) on the server and on your computer, connect to `<tailscale-ip>:53389` instead. `sudo claude-vps tailscale` sets it up and can then close SSH and RDP to the internet, which stops the scanning altogether. See the [tailscale step](/guide/what-it-installs#_10-tailscale).

## Through an SSH tunnel

RDP is encrypted, but a port open to the internet still gets scanned. If you installed with `--rdp-private`, or you just prefer it, tunnel it:

```bash
ssh -N -L 3389:localhost:53389 dev@<server-ip>
```

Then connect your RDP client to `localhost:3389`. Nothing but SSH is exposed.

To close an RDP port you already opened:

```bash
sudo ufw delete allow 53389/tcp
```

## Display tips

- **Resolution** follows the client window. Resize, reconnect, done.
- **HiDPI**: set the scale in System Settings, Display. It sticks per user.
- **Slow link**: drop the color depth to 16 bit in your client, and turn off animations in System Settings, Workspace Behavior.
- **Clipboard** works both ways for text out of the box.

## One session per user

xrdp reconnects you to your running session. Logging in locally and over RDP at the same time as the same user does not work with Plasma. On a server that never happens, since there is no local display.

## Theme the desktop

The desktop is stock KDE Plasma. For a monochrome, terminal-style look across Plasma, Kvantum, Konsole, the login screen and the boot splash, install [HaltOS](https://projects.halit.org/haltos/) on top. It needs Plasma 6, so Ubuntu 25.04 or newer.
