---
description: "Collegati al desktop KDE Plasma del tuo VPS Claude Code via RDP da Windows, macOS, Linux, iOS o Android, direttamente o con un tunnel SSH."
---

# Desktop remoto

Il server esegue una sessione KDE Plasma completa via RDP. Parte quando ti colleghi e resta attiva quando ti scolleghi, così la volta dopo trovi le finestre dove le avevi lasciate.

## Client

| Piattaforma | Client |
| --- | --- |
| Windows | Connessione Desktop remoto (`mstsc`), già incluso |
| macOS, iOS, iPadOS | Windows App (prima Microsoft Remote Desktop) |
| Android | Windows App o aRDP |
| Linux | Remmina, o KRDC su KDE |

Collegati a `<server-ip>:53389`, scegli **Xorg** se xrdp ti chiede il tipo di sessione e fai il login con utente e password della workstation.

## Tramite un tunnel SSH

RDP è cifrato, ma una porta aperta su internet viene comunque scansionata. Se hai installato con `--rdp-private`, o semplicemente preferisci così, usa un tunnel:

```bash
ssh -N -L 3389:localhost:53389 dev@<server-ip>
```

Poi collega il client RDP a `localhost:3389`. All'esterno resta esposto solo SSH.

Per chiudere una porta RDP già aperta:

```bash
sudo ufw delete allow 53389/tcp
```

## Consigli per lo schermo

- **La risoluzione** segue la finestra del client. Ridimensiona, ricollegati, fatto.
- **HiDPI**: imposta la scala in Impostazioni di sistema, Schermo. Resta salvata per utente.
- **Connessione lenta**: abbassa la profondità colore a 16 bit nel client e disattiva le animazioni in Impostazioni di sistema, Comportamento dello spazio di lavoro.
- **Gli appunti** funzionano in entrambe le direzioni per il testo, senza configurare nulla.

## Una sessione per utente

xrdp ti ricollega alla sessione già in esecuzione. Con Plasma non puoi fare il login in locale e via RDP con lo stesso utente nello stesso momento. Su un server non succede mai, perché non c'è un display locale.
