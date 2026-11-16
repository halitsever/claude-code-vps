---
description: "从 Windows、macOS、Linux、iOS 或 Android 通过 RDP 连接 Claude Code VPS 上的 KDE Plasma 桌面，可以直连，也可以走 SSH 隧道。"
---

# 远程桌面

服务器通过 RDP 提供完整的 KDE Plasma 会话。连接时启动，断开后继续运行，下次连上时窗口还在原来的位置。

## 客户端

| 平台 | 客户端 |
| --- | --- |
| Windows | 系统自带的远程桌面连接（`mstsc`） |
| macOS、iOS、iPadOS | Windows App（原 Microsoft Remote Desktop） |
| Android | Windows App 或 aRDP |
| Linux | Remmina，KDE 上也可以用 KRDC |

连接 `<server-ip>:53389`。如果 xrdp 让你选会话类型，选 **Xorg**，然后用工作用户的用户名和密码登录。

## 通过 SSH 隧道连接

RDP 本身是加密的，但对公网开放的端口还是会被扫描。如果安装时用了 `--rdp-private`，或者你就是想更稳妥一些，可以走 SSH 隧道：

```bash
ssh -N -L 3389:localhost:53389 dev@<server-ip>
```

然后让 RDP 客户端连接 `localhost:3389`。这样对外只开放了 SSH。

如果之前已经开放了 RDP 端口，可以这样关掉：

```bash
sudo ufw delete allow 53389/tcp
```

## 显示设置

- **分辨率**跟随客户端窗口大小。调整窗口后重新连接即可。
- **高分屏**：在“系统设置”的“显示”里设置缩放比例。每个用户单独保存。
- **网络慢**：在客户端里把颜色深度降到 16 位，并在“系统设置”的“工作区行为”里关闭动画。
- **剪贴板**：文本默认可以双向复制粘贴。

## 每个用户只有一个会话

xrdp 会把你重新连到正在运行的会话上。同一个用户同时在本地和通过 RDP 登录，Plasma 是不支持的。不过服务器没有本地显示器，所以不会遇到这种情况。
