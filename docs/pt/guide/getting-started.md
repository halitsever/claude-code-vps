---
description: "Instale o claude-vps em uma VPS com Ubuntu 24.04 ou 26.04 com um comando. Em uns dez minutos você tem Claude Code, KDE Plasma via RDP e SSH seguro."
---

# Primeiros passos

O claude-vps transforma um servidor Ubuntu recém-criado na máquina onde eu uso o Claude Code. Ele cria um usuário com sudo, deixa o SSH só com chave, liga um firewall e instala um desktop KDE Plasma que você acessa por RDP, Docker, Chrome e o próprio Claude Code com as minhas configurações, hooks e layout do KDE já aplicados.

## O que você precisa

| | |
| --- | --- |
| **Sistema** | Ubuntu 24.04 LTS ou mais recente (eu uso o 26.04) |
| **CPU / RAM** | 2 vCPU e 4 GB é o mínimo para o Plasma. Com 4 vCPU / 8 GB parece um desktop de verdade |
| **Disco** | 25 GB ou mais |
| **Acesso** | root por SSH, de preferência com a sua chave SSH já no servidor |
| **Arquitetura** | Em amd64 tudo é instalado. arm64 funciona, mas sem o Chrome |

Para fazer login no Claude Code depois, você precisa de um plano Claude Pro ou Max, ou de uma chave de API da Anthropic.

## Instalação

Entre por SSH como root (ou com um usuário com sudo) e rode:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

O script clona este repositório em `/opt/claude-vps` e roda `claude-vps setup`. Ele pergunta duas coisas: o nome do usuário e a senha dele. A senha é usada para o sudo e para entrar por RDP. Se você deixar em branco, uma senha é gerada e mostrada no final.

Para pular as perguntas, passe as opções depois de `bash -s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

Todas as opções estão na [referência da CLI](/pt/reference/cli).

::: tip Teste antes
`--dry-run` mostra cada comando sem rodar nada.
:::

## Quando terminar

Você vê um resumo como este:

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **Entre por SSH** com o novo usuário. As chaves SSH do root foram copiadas, então a mesma chave funciona.
2. **Inicie o Claude Code** dentro do tmux e faça login. Veja [Usando o Claude Code](/pt/guide/claude-code).
3. **Abra o desktop** com qualquer cliente RDP. Veja [Área de trabalho remota](/pt/guide/remote-desktop).

## Usando as suas próprias configurações

Por padrão, o servidor recebe as minhas configurações do KDE e do Claude a partir de `dotfiles/home`. Para usar as suas, faça um fork do repositório, rode `claude-vps capture` no seu computador, faça push e aponte o instalador para o seu fork:

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

O processo completo está em [Sincronizando as configurações](/pt/guide/sync).
