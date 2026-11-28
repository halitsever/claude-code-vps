---
description: "一条命令在全新的 Ubuntu 24.04 或 26.04 VPS 上安装 claude-vps，大约十分钟就能用上 Claude Code、通过 RDP 访问的 KDE Plasma 和加固过的 SSH。"
---

# 快速开始

claude-vps 会把一台全新的 Ubuntu 服务器配置成我平时运行 Claude Code 的那种环境。它会创建一个有 sudo 权限的用户，把 SSH 设成只能用密钥登录，打开防火墙，装好可以用 RDP 连接的 KDE Plasma 桌面、Docker 和 Chrome。Claude Code 本身也会装好，我的设置、hook 和 KDE 布局都已经应用。

## 准备工作

| | |
| --- | --- |
| **系统** | Ubuntu 24.04 LTS 或更新版本（我自己用的是 26.04） |
| **CPU / 内存** | 跑 Plasma 最少要 2 vCPU 和 4 GB。4 vCPU / 8 GB 用起来才像真正的桌面 |
| **磁盘** | 25 GB 或以上 |
| **访问方式** | 能用 SSH 以 root 登录，最好已经放好了你的 SSH 密钥 |
| **架构** | amd64 和 arm64 上所有组件都会安装 |

之后登录 Claude Code 还需要 Claude Pro 或 Max 套餐，或者一个 Anthropic API 密钥。

## 安装

以 root（或有 sudo 权限的用户）SSH 登录，然后运行：

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

脚本会把仓库克隆到 `/opt/claude-vps`，然后运行 `claude-vps setup`。过程中会问你两个问题：工作用户的用户名和密码（sudo 和 RDP 登录都用这个密码）。密码留空的话，脚本会自动生成一个，最后显示出来。

不想回答问题，可以在 `bash -s --` 后面直接传参数：

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

全部参数见 [CLI 参考](/zh/reference/cli)。

::: tip 先试运行
加上 `--dry-run` 只打印要执行的命令，不会真的执行。
:::

## 安装完成后

你会看到类似这样的总结：

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **用新用户通过 SSH 登录。** root 的 SSH 密钥已经复制过去，用同一把密钥就行。
2. **在 tmux 里启动 Claude Code** 并登录。见[使用 Claude Code](/zh/guide/claude-code)。
3. **用任意 RDP 客户端打开桌面。** 见[远程桌面](/zh/guide/remote-desktop)。

## 使用你自己的配置

默认情况下，服务器会从 `dotfiles/home` 拿到我的 KDE 和 Claude 配置。想用你自己的，先 fork 这个仓库，在自己电脑上运行 `claude-vps capture` 并 push，然后让安装脚本指向你的 fork：

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

完整流程见[配置同步](/zh/guide/sync)。
