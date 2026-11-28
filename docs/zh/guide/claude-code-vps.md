---
title: "如何在 VPS 上运行 Claude Code"
description: "在 Ubuntu VPS 上运行 Claude Code 的完整教程：安全的 SSH、断线不丢的 tmux 会话、手机通知，以及通过 RDP 访问的 KDE Plasma 桌面。"
---

# 如何在 VPS 上运行 Claude Code

这一页是我这套环境的完整手动搭建过程。我用一台便宜的 Ubuntu 服务器全天候运行 Claude Code，平时在任何地方用 SSH 连上去，需要图形界面时再用 RDP 打开 KDE Plasma 桌面。

下面的每条命令，[`claude-vps setup`](/zh/guide/getting-started) 都会自动帮你执行。读这一页可以了解它具体做了什么，也可以照着手动操作。

## 为什么要在 VPS 上运行 Claude Code

- **笔记本休眠了，它还在干活。** 大规模重构、跑测试、数据迁移，你不在的时候也能跑完。
- **本机保持干净。** Agent 装软件包、跑 Docker、起开发服务器，都发生在服务器上。服务器弄乱了，十分钟就能重装一台。
- **所有设备用同一个环境。** 笔记本、台式机、平板还是手机，连上的都是同一个 tmux 会话和同一个桌面。
- **网络快**，离 Git 托管平台和软件包仓库都更近。

## 选服务器

| 用途 | vCPU | 内存 | 磁盘 |
| --- | --- | --- | --- |
| 只用终端 | 2 | 4 GB | 40 GB |
| 加上 KDE 桌面 | 4 | 8 GB | 80 GB |
| 多个 agent 加 Docker | 8 | 16 GB | 160 GB |

只要能装 Ubuntu 24.04 LTS 或更新版本，哪家服务商都行：Hetzner、DigitalOcean、OVH、Vultr、Linode、AWS Lightsail，或者家里闲置的电脑。机房选离你近的，RDP 会更流畅。创建服务器时就把 SSH 公钥加进去，这样永远不需要 root 密码。

## 1. 首次登录并更新系统

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades` 会自动安装安全补丁。服务器一直在线，这一点很重要。

小内存的服务器要加 swap，否则 agent 一忙起来就可能被 OOM killer 杀掉：

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. 创建用户

不要用 root 运行 Claude Code。新建一个普通用户，给它 sudo 权限：

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

继续之前，另开一个终端，确认 `ssh dev@<server-ip>` 能登录。

## 3. 加固 SSH

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd 对同一个选项只认第一次读到的值，配置文件按文件名顺序加载。所以文件名以 `10-` 开头：它必须排在很多云镜像自带的 `50-cloud-init.conf` 前面，因为那个文件里写的是 `PasswordAuthentication yes`。

## 4. 防火墙

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # 只有想从公网连 RDP 时才需要，见下文
ufw --force enable
```

## 5. 安装 Claude Code

用新建的用户登录，然后用官方原生安装脚本。它不依赖 Node.js，而且会自动更新：

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

程序会装到 `~/.local/bin/claude`。退出再重新登录一次，让这个目录进入 `PATH`，然后检查：

```bash
claude --version
```

## 6. 在没有浏览器的服务器上登录

服务器上没有浏览器，也不需要：

```bash
claude
```

Claude Code 会输出一个链接。在自己的电脑或手机上打开它，点击授权，再把得到的代码粘贴回终端。登录信息保存在服务器的 `~/.claude` 里。

如果用的是 Anthropic API 密钥而不是 Pro 或 Max 套餐，把它写进 shell 配置：

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

用 API 密钥也能正常使用 Claude Code，但 [Remote Control](https://code.claude.com/docs/zh-CN/remote-control)（在 Claude 应用或 claude.ai 上操作会话）需要用 claude.ai 账号登录。

## 7. 用 tmux 保持会话

如果直接在 SSH 会话里运行 Claude，合上笔记本它就停了。放到 tmux 里运行：

```bash
tmux new -s claude
claude
# 先按 Ctrl-b 再按 d 断开，agent 会继续运行
tmux attach -t claude   # 之后从任意设备重新连上
```

再加一个简单的 `~/.tmux.conf`，用起来更顺手：

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Claude 需要你时推送通知

Claude Code 在等待输入时会触发 `Notification` hook。用 [ntfy.sh](https://ntfy.sh) 把它推送到手机：

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude 在等你回复"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
EOF
chmod +x ~/.claude/hooks/notify.sh
echo my-hard-to-guess-topic > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
```

在 `~/.claude/settings.json` 里注册这个 hook：

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

在手机的 ntfy 应用里订阅同一个 topic。topic 要像密码一样保管好。

## 9. 可选：通过 RDP 使用 KDE Plasma 桌面

大部分工作用终端就够了。想在 agent 旁边开个 Chrome、用文件管理器，或者在大屏幕上开好几个 Konsole 窗口时，桌面就很方便。

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

Ubuntu 24.04 上没有单独的 `plasma-session-x11` 和 `kwin-x11` 包，去掉这两个即可。

让 xrdp 为你的用户启动 Plasma：

```bash
cat > ~/.xsession <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
sudo systemctl restart xrdp
```

再把颜色配置文件的密码弹窗关掉，不然每次登录都会弹：

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

用任意 RDP 客户端连接 `<server-ip>:53389` 即可。更多内容见[远程桌面](/zh/guide/remote-desktop)，包括如何不开放端口、改走 SSH 隧道。

## 10. 开发工具

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## 安全检查清单

- SSH 只允许密钥登录，root 不能用密码登录
- 防火墙已开启，只开放需要的端口
- Claude Code 以普通用户运行，不用 root
- `--dangerously-skip-permissions` 只在用完即弃的容器里使用，绝不要在存着你的 token 和 SSH 密钥的机器上用
- 机密信息（`~/.claude/.credentials.json`、API 密钥、ntfy topic）不要放进公开仓库
- 自动安全更新已开启

## 一条命令搞定

上面所有步骤，再加上应用你自己的 KDE 和 Claude 配置，claude-vps 都能自动完成：

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

详见[快速开始](/zh/guide/getting-started)。

## 常见问题

### Claude Code 能在没有图形界面的服务器上运行吗？

可以。它是终端程序。登录时在任意其他设备上打开链接即可。

### 需要哪种 Claude 套餐？

任何包含 Claude Code 的套餐（Pro 或 Max），或者按用量计费的 Anthropic API 密钥。

### 一台运行 Claude Code 的 VPS 要多少钱？

在便宜的服务商那里，4 到 8 GB 内存的服务器一般每月 5 到 20 美元。Claude 的使用费用另外按你的套餐或 API 密钥计费。

### 关掉 SSH 后 Claude 还会继续运行吗？

只有在 tmux（或 screen）里才会。用 `tmux new -s claude` 启动，按 `Ctrl-b d` 断开。

### 安全吗？

和你自己维护的其他服务器一样安全。按上面的清单做，并且不要让 agent 接触它用不到的凭据。
