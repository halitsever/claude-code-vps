---
title: "O que é instalado"
description: "Cada etapa que o claude-vps roda no seu servidor Ubuntu: pacotes, swap, SSH, ufw, KDE Plasma, xrdp, Docker, Chrome, Claude Code e seus dotfiles."
---

# O que o claude-vps setup instala

O `claude-vps setup` roda nove etapas em ordem. Cada uma é uma função bash comum em [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh), então você pode ler exatamente o que roda no seu servidor. Pule qualquer etapa com `--skip`, ou rode só algumas com `--only`.

## 1. base

- `apt upgrade` em tudo
- `git curl jq ripgrep fd-find tmux htop build-essential python3` e outras ferramentas do tipo
- Node.js 20 ou mais recente. No Ubuntu 24.04 o apt só tem a 18, então ele vem do repositório da NodeSource
- `unattended-upgrades` ligado, para as correções de segurança chegarem sem você fazer nada
- um arquivo de swap de 4 GB quando o servidor não tem swap e tem menos de 8 GB de RAM. Assim o Plasma e alguns agentes não acionam o OOM killer
- o fuso horário, se você passar `--timezone`

## 2. user

Cria o seu usuário, coloca ele no grupo `sudo` e copia `/root/.ssh/authorized_keys` para ele se ainda não tiver chaves. A senha que você escolher é a que vai digitar na tela de login do RDP.

## 3. ssh

Escreve `/etc/ssh/sshd_config.d/10-claude-vps.conf`:

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

O sshd fica com o primeiro valor que lê. Por isso o nome do arquivo começa com `10-`: assim ele vale antes do `50-cloud-init.conf` que a maioria das imagens de provedores traz. Se o seu usuário ainda não tem chave SSH, a etapa é pulada com um aviso, para você nunca ficar trancado do lado de fora.

## 4. firewall

O `ufw` libera o OpenSSH e a porta do RDP, e fecha todo o resto. Com `--rdp-private`, a porta do RDP fica fechada e você entra por um túnel SSH.

## 5. desktop

`kde-plasma-desktop` mais a sessão X11 (`plasma-session-x11`, `kwin-x11` no Ubuntu 25.10 ou mais recente), Konsole, Dolphin, Kate, Spectacle e as fontes Noto e JetBrains Mono. O SDDM é desligado e o boot fica em `multi-user`. Ninguém senta na frente de um servidor, então ele inicia direto no console e o Plasma só abre quando você conecta.

::: info Por que X11
O xrdp trabalha com uma sessão Xorg. O Plasma 6 ainda traz uma sessão X11 do Ubuntu 24.04 ao 26.04, e é a que eu uso todo dia via RDP.
:::

## 6. rdp

- `xrdp` e `xorgxrdp`, escutando na porta **53389** (mude com `--rdp-port`)
- um `~/.xsession` que inicia o `startplasma-x11` com as variáveis `XDG_*` certas
- uma regra do polkit que desliga o aviso "authentication is required to create a color managed device", que senão aparece a cada login

## 7. apps

- Docker (`docker.io`, compose v2, buildx), com o seu usuário no grupo `docker`
- GitHub CLI (`gh`)
- Google Chrome pelo repositório apt do Google (amd64 e arm64). Útil quando o Claude precisa de um navegador de verdade

## 8. claude

- Claude Code pelo instalador nativo oficial, em `~/.local/bin/claude`. Ele se atualiza sozinho
- [claudegrid](https://github.com/halitsever/claudegrid) pelo último release `.deb`, para abrir uma grade de agentes do Claude Code no Konsole ou no tmux com um comando. Ele também adiciona um perfil do Konsole e um item no menu de aplicativos
- o seu tópico do ntfy.sh em `~/.claude/ntfy-topic`, se você informar um. O hook de notificação lê de lá

## 9. dotfiles

Passa `/opt/claude-vps` para o seu usuário, cria um link de `claude-vps` em `/usr/local/bin` e roda `claude-vps apply` como você. Isso copia tudo o que está em `dotfiles/home` para a sua pasta pessoal: configurações do KDE, perfis do Konsole, `~/.claude/settings.json`, `CLAUDE.md`, hooks e `.tmux.conf`.

## Rodando etapas de novo

Cada etapa confere o que já está instalado, então rodar de novo é seguro:

```bash
sudo claude-vps setup --only desktop,rdp     # por exemplo, depois de atualizar a versão do Ubuntu
sudo claude-vps setup --skip apps            # tudo menos Docker e Chrome
sudo claude-vps setup --no-desktop           # servidor só com terminal
```
