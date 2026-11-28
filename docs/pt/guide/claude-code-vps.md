---
title: "Como rodar o Claude Code em uma VPS"
description: "Guia passo a passo para rodar o Claude Code em uma VPS Ubuntu: SSH seguro, sessões tmux que não caem, avisos no celular e desktop KDE Plasma via RDP."
---

# Claude Code em uma VPS, passo a passo

Esta é a minha instalação completa, feita à mão. Um servidor Ubuntu barato que deixa o Claude Code rodando o dia inteiro. Eu acesso por SSH de qualquer lugar e, quando quero uma tela de verdade, entro em um desktop KDE Plasma via RDP.

Cada comando desta página é o que o [`claude-vps setup`](/pt/guide/getting-started) roda por você. Leia para entender o que acontece, ou para fazer tudo manualmente.

## Por que rodar o Claude Code em uma VPS

- **Ele continua trabalhando quando o notebook entra em suspensão.** Refatorações longas, testes e migrações terminam enquanto você está fora.
- **Seu computador fica limpo.** Os agentes instalam pacotes, rodam Docker e sobem servidores de desenvolvimento em uma máquina que você apaga e monta de novo em dez minutos.
- **O mesmo ambiente em todo lugar.** Notebook, desktop, tablet ou celular: você entra na mesma sessão do tmux e no mesmo desktop.
- **Rede rápida**, perto do seu servidor git e dos repositórios de pacotes.

## Escolha um servidor

| Uso | vCPU | RAM | Disco |
| --- | --- | --- | --- |
| Só terminal | 2 | 4 GB | 40 GB |
| Com desktop KDE | 4 | 8 GB | 80 GB |
| Vários agentes e Docker | 8 | 16 GB | 160 GB |

Qualquer provedor com Ubuntu 24.04 LTS ou mais recente serve: Hetzner, DigitalOcean, OVH, Vultr, Linode, AWS Lightsail ou um computador sobrando em casa. Escolha uma região perto de você para o RDP ficar mais fluido. Adicione sua chave pública SSH ao criar o servidor, assim você nunca vai precisar da senha do root.

## 1. Primeiro acesso e atualizações

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

O `unattended-upgrades` instala as correções de segurança sozinho. Isso é importante em uma máquina que fica sempre online.

Em servidores pequenos, vale adicionar swap. Assim um agente pesado não aciona o OOM killer:

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. Crie seu usuário

Não rode o Claude Code como root. Crie um usuário comum com sudo:

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

Antes de continuar, abra outro terminal e confira se `ssh dev@<server-ip>` funciona.

## 3. Proteja o SSH

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

O sshd usa o primeiro valor que lê, e carrega os arquivos em ordem alfabética. Por isso o nome começa com `10-`: ele precisa vir antes do `50-cloud-init.conf`, que muitas imagens de provedores trazem com `PasswordAuthentication yes`.

## 4. Firewall

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # só se você quiser RDP pela internet, veja abaixo
ufw --force enable
```

## 5. Instale o Claude Code

Entre com o seu usuário e use o instalador nativo. Ele não precisa de Node.js e se atualiza sozinho:

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

Ele fica em `~/.local/bin/claude`. Saia e entre de novo uma vez para essa pasta entrar no seu `PATH`, depois confira:

```bash
claude --version
```

## 6. Faça login em um servidor sem tela

O servidor não tem navegador, e você não precisa de um:

```bash
claude
```

O Claude Code mostra uma URL. Abra no seu computador ou celular, autorize e cole o código de volta no terminal. A sessão fica salva em `~/.claude` no servidor.

Se você usa uma chave de API da Anthropic em vez de um plano Pro ou Max, coloque no perfil do seu shell:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

Com uma chave de API o Claude Code funciona, mas o [Remote Control](https://code.claude.com/docs/pt/remote-control), que permite controlar a sessão pelo app do Claude ou pelo claude.ai, precisa do login pelo claude.ai.

## 7. Mantenha as sessões vivas com tmux

Se o Claude roda direto na sua sessão SSH, fechar o notebook encerra tudo. Rode dentro do tmux:

```bash
tmux new -s claude
claude
# Ctrl-b e depois d para sair, o agente continua trabalhando
tmux attach -t claude   # mais tarde, de qualquer aparelho
```

Um `~/.tmux.conf` pequeno deixa tudo mais confortável:

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Receba um aviso quando o Claude precisar de você

O Claude Code dispara um hook `Notification` quando está esperando sua resposta. Mande isso para o celular com o [ntfy.sh](https://ntfy.sh):

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "O Claude está esperando você"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
EOF
chmod +x ~/.claude/hooks/notify.sh
echo my-hard-to-guess-topic > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
```

Registre o hook em `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

Assine o mesmo tópico no app do ntfy. Trate o nome do tópico como uma senha.

## 9. Opcional: desktop KDE Plasma via RDP

O terminal resolve quase tudo. O desktop ajuda quando você quer o Chrome ao lado do agente, um gerenciador de arquivos ou várias janelas do Konsole em uma tela grande.

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

No Ubuntu 24.04, os pacotes `plasma-session-x11` e `kwin-x11` não existem separados. Tire os dois do comando.

Diga ao xrdp para abrir o Plasma para o seu usuário:

```bash
cat > ~/.xsession <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
sudo systemctl restart xrdp
```

Depois desligue o pedido de senha sobre perfis de cor, que senão aparece a cada login:

```bash
sudo tee /etc/polkit-1/rules.d/45-colord.rules >/dev/null <<'EOF'
polkit.addRule(function (action, subject) {
  if (action.id.indexOf("org.freedesktop.color-manager.") === 0 && subject.isInGroup("users")) {
    return polkit.Result.YES;
  }
});
EOF
sudo usermod -aG users dev
```

Conecte qualquer cliente RDP em `<server-ip>:53389`. Veja mais em [Área de trabalho remota](/pt/guide/remote-desktop), inclusive como deixar a porta fechada e passar por um túnel SSH.

## 10. Ferramentas de desenvolvimento

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## Checklist de segurança

- SSH só com chave, sem login de root por senha
- Firewall ligado, só com as portas que você precisa
- Claude Code rodando com um usuário comum, não como root
- `--dangerously-skip-permissions` só em containers descartáveis, nunca em uma máquina com seus tokens e chaves SSH
- Segredos (`~/.claude/.credentials.json`, chaves de API, tópico do ntfy) nunca vão para um repositório público
- Atualizações automáticas ligadas

## Tudo com um comando

O claude-vps automatiza tudo isso e ainda aplica as suas configurações do KDE e do Claude:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Veja [Primeiros passos](/pt/guide/getting-started).

## Perguntas frequentes

### O Claude Code roda em um servidor sem interface gráfica?

Sim. Ele é um app de terminal. O login é feito por um link que você abre em outro aparelho.

### Qual plano do Claude eu preciso?

Qualquer plano que inclua o Claude Code (Pro ou Max), ou uma chave de API da Anthropic cobrada por uso.

### Quanto custa uma VPS para o Claude Code?

Em provedores baratos, um servidor com 4 a 8 GB de RAM costuma custar entre 5 e 20 USD por mês. O uso do Claude é cobrado à parte, pelo seu plano ou pela chave de API.

### O Claude continua rodando depois que eu fecho o SSH?

Só se estiver dentro do tmux (ou do screen). Inicie com `tmux new -s claude` e saia com `Ctrl-b d`.

### É seguro?

Tão seguro quanto qualquer servidor que você mesmo administra. Siga o checklist acima e não dê ao agente credenciais de que ele não precisa.
