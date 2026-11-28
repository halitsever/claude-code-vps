---
description: "Faça login no Claude Code em um servidor sem tela, mantenha os agentes no tmux mesmo se o SSH cair e receba avisos no celular com o ntfy.sh."
---

# Usando o Claude Code

## Primeiro login

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

O Claude Code mostra um link de login. Abra no seu navegador, autorize e cole o código de volta. As credenciais ficam em `~/.claude` no servidor.

Prefere usar uma chave de API? Exporte antes de iniciar:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

Com uma chave de API o Claude Code funciona, mas o [Remote Control](https://code.claude.com/docs/pt/remote-control), que permite controlar a sessão pelo app do Claude ou pelo claude.ai, precisa do login pelo claude.ai.

## Mantendo tudo rodando com tmux

Um agente que trabalha por uma hora não deveria parar porque o seu notebook entrou em suspensão. Rode dentro do tmux e saia da sessão sem fechar:

| | |
| --- | --- |
| Sair sem fechar | `Ctrl-b` e depois `d` |
| Voltar | `tmux attach -t claude` |
| Nova janela | `Ctrl-b` e depois `c` |
| Listar sessões | `tmux ls` |

O `.tmux.conf` incluído liga o mouse, um histórico de 50 mil linhas e 256 cores.

Você também pode abrir o Konsole no desktop e rodar `tmux attach -t claude` lá. É a mesma sessão, em uma tela maior.

## Avisos no celular

O `~/.claude/settings.json` registra um hook `Notification`, `~/.claude/hooks/notify.sh`, que manda uma mensagem para o [ntfy.sh](https://ntfy.sh) sempre que o Claude está esperando você.

1. Instale o app do ntfy no celular e assine um tópico que ninguém vai adivinhar, por exemplo `claude-7f3k9q2m`.
2. Coloque o mesmo tópico no servidor:

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   Ou passe `--ntfy-topic` durante a instalação.

O tópico é secreto: quem souber o nome pode ler as suas notificações. Por isso ele fica em um arquivo separado e nunca é copiado para o repositório.

## O que já vem configurado

A partir de `dotfiles/home/.claude`:

- **`settings.json`**: tema escuro, interface em tela cheia, uma barra de status com o modelo, a pasta, a branch do git e o uso de contexto, os plugins que eu uso e o hook de notificação
- **`CLAUDE.md`**: um arquivo vazio para as suas instruções globais. Ele só é criado se não existir, então o que você escrever ali nunca é sobrescrito
- **`hooks/notify.sh`**: o hook do ntfy descrito acima

Mude qualquer um deles no seu computador e rode `claude-vps publish`. Veja [Sincronizando as configurações](/pt/guide/sync).

## Atualizando o Claude Code

A instalação nativa se atualiza sozinha em segundo plano. Para forçar:

```bash
claude update
```
