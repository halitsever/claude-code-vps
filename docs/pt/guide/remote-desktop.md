---
title: "Área de trabalho remota"
description: "Conecte por RDP ao desktop KDE Plasma da sua VPS com Claude Code a partir do Windows, macOS, Linux, iOS ou Android, direto ou por um túnel SSH."
---

# Área de trabalho remota via RDP

O servidor tem uma sessão completa do KDE Plasma que você acessa por RDP. Ela abre quando você conecta e continua rodando quando você desconecta, então na próxima vez as janelas estão onde você deixou.

## Clientes

| Plataforma | Cliente |
| --- | --- |
| Windows | Conexão de Área de Trabalho Remota (`mstsc`), já vem no sistema |
| macOS, iOS, iPadOS | Windows App (antigo Microsoft Remote Desktop) |
| Android | Windows App ou aRDP |
| Linux | Remmina, ou KRDC no KDE |

Conecte em `<server-ip>:53389`. Se o xrdp pedir um tipo de sessão, escolha **Xorg**, e entre com o seu usuário e senha.

## Por um túnel SSH

O RDP é criptografado, mas uma porta aberta na internet recebe varreduras do mesmo jeito. Se você instalou com `--rdp-private`, ou só prefere assim, use um túnel:

```bash
ssh -N -L 3389:localhost:53389 dev@<server-ip>
```

Depois conecte o cliente RDP em `localhost:3389`. Só o SSH fica exposto.

Para fechar uma porta RDP que você já abriu:

```bash
sudo ufw delete allow 53389/tcp
```

## Dicas de tela

- **Resolução**: segue o tamanho da janela do cliente. Redimensione e conecte de novo.
- **HiDPI**: ajuste a escala em Configurações do sistema, Tela. Fica salvo para cada usuário.
- **Conexão lenta**: baixe a profundidade de cor para 16 bits no cliente e desligue as animações em Configurações do sistema, Comportamento do espaço de trabalho.
- **Área de transferência**: texto copia nos dois sentidos sem configurar nada.

## Uma sessão por usuário

O xrdp reconecta você à sessão que já está aberta. Com o Plasma, não dá para entrar ao mesmo tempo localmente e por RDP com o mesmo usuário. Em um servidor isso não acontece, porque não existe tela local.
