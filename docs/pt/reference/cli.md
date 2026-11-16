---
description: "Referência de todos os comandos e opções do claude-vps para o seu servidor com Claude Code: setup, sync, autosync, doctor, capture, publish e apply."
---

# CLI

```text
claude-vps <command> [options]
```

| Comando | Onde | O que faz |
| --- | --- | --- |
| `setup` | servidor, como root | Roda as etapas de instalação |
| `sync` | servidor | `git pull` e depois `apply` |
| `autosync on\|off` | servidor | Timer do systemd do usuário que roda o `sync` a cada 30 minutos |
| `doctor` | servidor | Confere Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy e autosync |
| `capture` | seu computador | Copia os arquivos de `dotfiles/manifest.txt` para `dotfiles/home` |
| `publish` | seu computador | `capture`, commit e push |
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

## install.sh

O script de instalação lê três variáveis de ambiente:

| Variável | Padrão |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Tudo o que vier depois de `bash -s --` é passado para o `setup`.
