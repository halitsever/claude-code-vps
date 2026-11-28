---
title: "Sincronizando as configurações"
description: "Mantenha as configurações do KDE Plasma e do Claude Code iguais no seu computador e na sua VPS com claude-vps publish, sync e autosync."
---

# Sincronizando as configurações entre sua máquina e o servidor

Todas as configurações do servidor ficam no repositório. Você muda as coisas no seu computador e o servidor recebe depois.

```text
 seu computador                GitHub                     servidor
 ──────────────                ──────                     ────────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (ou autosync, a cada 30 min)
```

## No seu computador

Clone o repositório uma vez e coloque a CLI no seu PATH:

```bash
git clone https://github.com/halitsever/claude-code-vps.git ~/claude-code-vps
ln -s ~/claude-code-vps/bin/claude-vps ~/.local/bin/claude-vps
```

Depois de mudar um painel, um atalho, o seu perfil do Konsole ou o `~/.claude/settings.json`:

```bash
claude-vps publish
```

Isso roda o `capture`, faz commit de `dotfiles/` e faz push. Se preferir ver as mudanças antes:

```bash
claude-vps capture
git -C ~/claude-code-vps diff
```

## No servidor

```bash
claude-vps sync
```

Ele faz pull e roda o `apply`. Antes de sobrescrever um arquivo, faz uma cópia em `~/.local/state/claude-vps/backup-<timestamp>/`. Arquivos que não mudaram ficam como estão.

Ou deixe isso acontecer sozinho:

```bash
claude-vps autosync on     # timer do systemd do usuário, a cada 30 minutos
claude-vps autosync        # mostra quando roda da próxima vez
claude-vps autosync off
```

::: warning Plasma e sessões abertas
O Plasma guarda algumas configurações na memória e só grava quando você sai da sessão. Se uma sincronização chegar enquanto você está conectado por RDP, saia e entre de novo para ver a mudança. Enquanto isso, não mude a mesma configuração no servidor.
:::

## O que é copiado

A lista fica em [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/manifest.txt). Uma barra no final significa a pasta inteira.

| Área | Arquivos |
| --- | --- |
| Plasma | `kdeglobals`, `kwinrc`, `kglobalshortcutsrc`, `plasmarc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kdedefaults/`, configurações de energia e notificações |
| Apps | `dolphinrc`, `konsolerc`, `katerc`, `~/.local/share/konsole/`, configurações do tema GTK, `mimeapps.list` |
| Visual | `~/.local/share/color-schemes/`, `plasma/`, `aurorae/`, `wallpapers/` quando existem |
| Claude | `~/.claude/settings.json`, `hooks/` |
| Shell | `.tmux.conf`, `.xsession` |

Para acompanhar outro arquivo, adicione uma linha no manifest. Caminhos que não existem no seu computador são pulados.

## O que nunca é copiado

O caminho da sua pasta pessoal vira `@HOME@`, para os arquivos funcionarem com qualquer nome de usuário, e as seções com arquivos recentes ou histórico são removidas. As credenciais simplesmente não estão na lista: `~/.claude/.credentials.json`, `~/.claude/ntfy-topic`, chaves SSH, `kwalletrc` e perfis do navegador. Mantenha assim, o repositório é público.
