---
description: "claude-vps 在你的 Ubuntu 服务器上执行的每一步：软件包、swap、SSH 加固、ufw、KDE Plasma、xrdp、Docker、Chrome、Claude Code 和 dotfiles。"
---

# 安装了哪些东西

`claude-vps setup` 按顺序执行九个步骤。每一步都是 [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh) 里的一个普通 bash 函数，服务器上到底执行了什么，你都能直接看到。用 `--skip` 可以跳过某些步骤，用 `--only` 可以只运行其中几步。

## 1. base

- 用 `apt upgrade` 升级所有软件包
- 安装 `git curl jq ripgrep fd-find tmux htop build-essential nodejs npm python3` 等常用工具
- 开启 `unattended-upgrades`，安全补丁会自动安装
- 如果服务器没有 swap 且内存小于 8 GB，就创建一个 4 GB 的 swap 文件。这样同时跑 Plasma 和几个 agent 时不容易被 OOM killer 杀掉
- 如果传了 `--timezone`，设置时区

## 2. user

创建工作用户并加入 `sudo` 组。如果这个用户还没有 SSH 密钥，就把 `/root/.ssh/authorized_keys` 复制过去。这里设置的密码就是 RDP 登录界面要输入的密码。

## 3. ssh

写入 `/etc/ssh/sshd_config.d/10-claude-vps.conf`：

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd 对同一个选项只认第一次读到的值，所以文件名以 `10-` 开头，这样它就排在大多数云镜像自带的 `50-cloud-init.conf` 前面。如果你的用户还没有 SSH 密钥，这一步会跳过并给出警告，免得把自己锁在外面。

## 4. firewall

开启 `ufw`，只放行 OpenSSH 和 RDP 端口，其他全部关闭。如果传了 `--rdp-private`，RDP 端口也不开放，改为通过 SSH 隧道连接。

## 5. desktop

安装 `kde-plasma-desktop` 和 X11 会话（Ubuntu 25.10 及以上还会装 `plasma-session-x11` 和 `kwin-x11`），以及 Konsole、Dolphin、Kate、Spectacle、Noto 字体和 JetBrains Mono 字体。SDDM 会被禁用，默认启动目标设为 `multi-user`。服务器前面不会有人坐着，所以开机直接进控制台，只有在你连接时才启动 Plasma。

::: info 为什么用 X11
xrdp 驱动的是 Xorg 会话。在 Ubuntu 24.04 到 26.04 上，Plasma 6 仍然提供 X11 会话，我日常通过 RDP 用的也是它。
:::

## 6. rdp

- 安装 `xrdp` 和 `xorgxrdp`，监听 **53389** 端口（可以用 `--rdp-port` 修改）
- 写入 `~/.xsession`，用正确的 `XDG_*` 变量启动 `startplasma-x11`
- 添加一条 polkit 规则。不加的话，每次登录都会弹出“创建颜色管理设备需要认证”的提示

## 7. apps

- Docker（`docker.io`、compose v2、buildx），并把你的用户加入 `docker` 组
- GitHub CLI（`gh`）
- 从 Google 的 apt 源安装 Google Chrome（仅 amd64）。Claude 需要真正的浏览器时很有用

## 8. claude

- 用官方原生安装脚本把 Claude Code 装到 `~/.local/bin/claude`，之后会自动更新
- 如果提供了 ntfy.sh topic，就写入 `~/.claude/ntfy-topic`，通知 hook 会从这里读取

## 9. dotfiles

把 `/opt/claude-vps` 的所有权交给你的用户，把 `claude-vps` 链接到 `/usr/local/bin`，然后以你的身份运行 `claude-vps apply`。这会把 `dotfiles/home` 下的所有文件写入你的主目录：KDE 配置、Konsole 配置文件、`~/.claude/settings.json`、`CLAUDE.md`、hook 和 `.tmux.conf`。

## 重新运行某些步骤

每一步都会先检查当前状态，所以重复运行是安全的：

```bash
sudo claude-vps setup --only desktop,rdp     # 比如升级系统版本之后
sudo claude-vps setup --skip apps            # 除了 Docker 和 Chrome 都装
sudo claude-vps setup --no-desktop           # 只用终端的服务器
```
