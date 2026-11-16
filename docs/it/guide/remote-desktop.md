---
description: "Collegati in RDP al desktop KDE Plasma del tuo VPS con Claude Code da Windows, macOS, Linux, iOS o Android, direttamente o tramite un tunnel SSH."
---

# Desktop remoto

Il server fa girare una sessione KDE Plasma completa, a cui accedi in RDP. Parte quando ti colleghi e continua a girare quando ti scolleghi. Al prossimo accesso trovi le finestre dove le avevi lasciate.

## Client

| Piattaforma | Client |
| --- | --- |
| Windows | Connessione Desktop remoto (`mstsc`), già incluso |
| macOS, iOS, iPadOS | Windows App (il vecchio Microsoft Remote Desktop) |
| Android | Windows App o aRDP |
| Linux | Remmina, oppure KRDC su KDE |

Collegati a `<server-ip>:53389`. Se xrdp chiede il tipo di sessione, scegli **Xorg**. Poi inserisci nome utente e password del tuo utente.

## Tramite un tunnel SSH

RDP è cifrato, ma una porta aperta su internet viene comunque scansionata di continuo. Se hai installato con `--rdp-private`, o se semplicemente preferisci, usa un tunnel:

```bash
ssh -N -L 3389:localhost:53389 dev@<server-ip>
```

Poi collega il client RDP a `localhost:3389`. Su internet resta esposto solo SSH.

Per chiudere una porta RDP già aperta:

```bash
sudo ufw delete allow 53389/tcp
```

## Consigli sullo schermo

- **Risoluzione**: segue la dimensione della finestra del client. Ridimensiona, ricollegati e basta.
- **Schermi ad alta risoluzione**: imposta la scala in Impostazioni di sistema, Schermo. L'impostazione resta salvata per ogni utente.
- **Connessione lenta**: abbassa la profondità colore a 16 bit nel client e disattiva le animazioni in Impostazioni di sistema, Comportamento dello spazio di lavoro.
- **Appunti**: il copia e incolla del testo funziona in entrambe le direzioni, senza configurare niente.

## Una sessione per utente

xrdp ti ricollega alla sessione già aperta. Con Plasma lo stesso utente non può essere collegato in locale e in RDP nello stesso momento. Su un server non succede, perché non c'è uno schermo locale.
