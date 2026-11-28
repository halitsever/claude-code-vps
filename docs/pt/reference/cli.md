---
title: "CLI do claude-vps: comandos e opções"
description: "Referência de todos os comandos e opções do claude-vps para o seu servidor com Claude Code: setup, sync, autosync, doctor, capture, publish e apply."
---

# CLI

```text
claude-vps <command> [options]
```

| Comando | Onde | O que faz |
| --- | --- | --- |
| `setup` | servidor, como root | Roda as etapas de instalação |
| `update` | servidor, como root | Baixa a versão mais recente e roda o setup de novo com as opções da primeira instalação |
| `sync` | servidor | `git pull` e depois `apply` |
| `autosync on\|off` | servidor | Timer do systemd do usuário que roda o `sync` a cada 30 minutos |
| `doctor` | servidor | Confere Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy e autosync |
| `capture` | seu computador | Copia os arquivos de `dotfiles/manifest.txt` para `dotfiles/home` |
| `publish` | seu computador | `capture`, commit e push |
| `release X.Y.Z` | seu computador | Grava o `VERSION`, cria a tag `vX.Y.Z` e faz push. O GitHub publica a release a partir do `CHANGELOG.md` |
| `apply` | qualquer lugar | Copia `dotfiles/home` para `$HOME` e guarda cópia do que substitui |
| `version` | qualquer lugar | Mostra a versão |

## setup

```bash
sudo claude-vps setup [options]
```

| Opção | Padrão | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER`, ou pergunta | O seu usuário. É criado se não existir |
| `--rdp-port PORT` | `53389` | Porta do xrdp |
| `--rdp-private` | desligado | Não abre a porta do RDP no ufw |
| `--ntfy-topic NAME` | pergunta | Tópico do ntfy.sh para as notificações |
| `--timezone TZ` | sem mudança | Por exemplo `Europe/Istanbul` |
| `--no-desktop` | desligado | O mesmo que `--skip desktop,rdp` |
| `--skip a,b` | | Etapas a pular |
| `--only a,b` | | Roda só estas etapas |
| `-y, --yes` | desligado | Sem perguntas. O usuário vira `dev` e a senha é gerada |
| `-n, --dry-run` | desligado | Mostra os comandos sem rodar |

Etapas, em ordem: `base user ssh firewall desktop rdp apps claude dotfiles`.

## Atualizar

Quando sair uma versão nova, rode isto em cada servidor:

```bash
sudo claude-vps update
```

O comando baixa o código novo, mostra o que mudou e roda de novo todas as etapas do setup. Etapas que já foram feitas são puladas. O xrdp e o SSH só reiniciam se a configuração deles mudou, então uma sessão RDP aberta continua conectada. As opções que você escolheu na primeira instalação (usuário, porta RDP, etapas puladas) ficam em `/etc/claude-vps.conf` e são usadas de novo.

O `claude-vps sync` também avisa quando chega uma versão nova.

## Publicar uma versão

No seu computador, adicione uma seção `## X.Y.Z` ao `CHANGELOG.md`, faça o commit e depois rode:

```bash
claude-vps release X.Y.Z
```

O workflow de release confere se a tag bate com o `VERSION` e publica uma release no GitHub. As notas da release são essa seção do changelog.

## Máquinas de origem da configuração

O `claude-vps capture` marca a máquina onde roda como origem da configuração (`~/.config/claude-vps/source`). Nessa máquina, `apply` e `sync` não mexem nos seus arquivos, porque a cópia do repo pode ser mais antiga do que a que você está usando. Para sobrescrever mesmo assim, use `claude-vps apply --force`.

## install.sh

O script de instalação lê três variáveis de ambiente:

| Variável | Padrão |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Tudo o que vier depois de `bash -s --` é passado para o `setup`.
