---
description: "Resolva problemas comuns do Claude Code em uma VPS: tela preta no RDP, aviso de perfil de cor, SSH bloqueado, claude não encontrado e erros de sync."
---

# Solução de problemas

Comece por aqui:

```bash
claude-vps doctor
```

## O RDP mostra uma tela preta e desconecta

Normalmente o `~/.xsession` está faltando ou o Plasma já está aberto para esse usuário.

```bash
cat ~/.xsession                      # deve terminar com: exec startplasma-x11
loginctl list-sessions               # tem uma sessão antiga do seu usuário? encerre:
loginctl terminate-user $USER
```

Os logs ficam em `~/.xsession-errors` e `/var/log/xrdp-sesman.log`.

## "Authentication is required to create a color managed device"

A regra do polkit da etapa `rdp` resolve isso. Confira se o seu usuário está no grupo `users` (`id`) e conecte de novo.

## Não consigo conectar no RDP

```bash
sudo ss -tlnp | grep xrdp      # está escutando na 53389?
sudo ufw status                # a porta está liberada?
```

O seu provedor também pode ter um firewall próprio na frente do servidor.

## Fiquei sem acesso ao SSH

A etapa `ssh` só desliga o login por senha quando o seu usuário tem uma chave. Se mesmo assim acontecer, use o console web do provedor e rode:

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

O instalador nativo coloca o comando em `~/.local/bin`. O Ubuntu adiciona essa pasta ao `PATH` no login, desde que ela exista. Saia e entre de novo, ou rode `source ~/.profile`.

## `claude-vps sync` diz "Not possible to fast-forward"

O clone no servidor tem mudanças locais. No servidor a ideia é só fazer pull:

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## Recuperando um arquivo antigo

Cada `apply` guarda uma cópia do que sobrescreve:

```bash
ls ~/.local/state/claude-vps/
```
