---
description: "Per RDP von Windows, macOS, Linux, iOS oder Android auf den KDE-Plasma-Desktop deines Claude Code VPS zugreifen, direkt oder über einen SSH-Tunnel."
---

# Remote-Desktop

Auf dem Server läuft eine vollständige KDE-Plasma-Sitzung, die du per RDP erreichst. Sie startet, wenn du dich verbindest, und läuft weiter, wenn du dich trennst. Beim nächsten Mal sind alle Fenster noch da, wo du sie gelassen hast.

## Clients

| Plattform | Client |
| --- | --- |
| Windows | Remotedesktopverbindung (`mstsc`), schon eingebaut |
| macOS, iOS, iPadOS | Windows App (früher Microsoft Remote Desktop) |
| Android | Windows App oder aRDP |
| Linux | Remmina, unter KDE auch KRDC |

Verbinde dich mit `<server-ip>:53389`. Fragt xrdp nach dem Sitzungstyp, wähle **Xorg**. Melde dich mit deinem Benutzer und Passwort an.

## Über einen SSH-Tunnel

RDP ist verschlüsselt, aber ein offener Port wird trotzdem ständig gescannt. Hast du mit `--rdp-private` installiert, oder ist dir das einfach lieber, dann tunnel die Verbindung:

```bash
ssh -N -L 3389:localhost:53389 dev@<server-ip>
```

Verbinde deinen RDP-Client danach mit `localhost:3389`. Von außen ist nur SSH erreichbar.

So schließt du einen RDP-Port, den du schon geöffnet hast:

```bash
sudo ufw delete allow 53389/tcp
```

## Tipps zur Anzeige

- **Auflösung**: richtet sich nach dem Client-Fenster. Fenstergröße ändern, neu verbinden, fertig.
- **HiDPI**: Skalierung in den Systemeinstellungen unter Anzeige einstellen. Sie bleibt pro Benutzer gespeichert.
- **Langsame Verbindung**: im Client die Farbtiefe auf 16 Bit senken und in den Systemeinstellungen unter Arbeitsbereich die Animationen abschalten.
- **Zwischenablage**: Text lässt sich ohne weitere Einrichtung in beide Richtungen kopieren.

## Eine Sitzung pro Benutzer

xrdp verbindet dich wieder mit deiner laufenden Sitzung. Mit demselben Benutzer gleichzeitig lokal und per RDP angemeldet zu sein, klappt mit Plasma nicht. Auf einem Server passiert das nie, weil es keinen lokalen Bildschirm gibt.
