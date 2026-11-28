---
title: "常见问题排查"
description: "解决 Claude Code VPS 的常见问题：RDP 黑屏、xrdp 颜色配置文件弹窗、SSH 登不上、找不到 claude 命令以及同步出错。"
---

# 常见问题及解决方法

先运行：

```bash
claude-vps doctor
```

## RDP 黑屏后断开

通常是因为 `~/.xsession` 不存在，或者这个用户已经有一个正在运行的 Plasma。

```bash
cat ~/.xsession                      # 最后一行应该是 exec startplasma-x11
loginctl list-sessions               # 有你用户的旧会话？结束它：
loginctl terminate-user $USER
```

日志在 `~/.xsession-errors` 和 `/var/log/xrdp-sesman.log`。

## 弹出“Authentication is required to create a color managed device”

`rdp` 步骤添加的 polkit 规则就是用来处理这个的。用 `id` 确认你的用户在 `users` 组里，然后重新连接。

## 完全连不上 RDP

```bash
sudo ss -tlnp | grep xrdp      # 是否在监听 53389？
sudo ufw status                # 端口是否已放行？
```

另外，云服务商可能在服务器前面还有一层自己的防火墙。

## SSH 登不上了

`ssh` 步骤只会在你的用户有密钥时才关闭密码登录。如果还是被锁在外面，用服务商的网页控制台登录，然后运行：

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

原生安装脚本会把它装到 `~/.local/bin`。这个目录存在后，Ubuntu 会在登录时把它加进 `PATH`。所以退出再重新登录，或者运行 `source ~/.profile`。

## `claude-vps sync` 提示 "Not possible to fast-forward"

服务器上的克隆有本地改动。服务器上的仓库应该只拉取，不做修改：

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## 恢复旧文件

每次 `apply` 都会备份被覆盖的文件：

```bash
ls ~/.local/state/claude-vps/
```
