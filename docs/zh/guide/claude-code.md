---
title: "使用 Claude Code"
description: "在没有图形界面的服务器上登录 Claude Code，用 tmux 让 agent 在 SSH 断开后继续运行，并通过 ntfy.sh 接收手机通知。"
---

# 在远程服务器上使用 Claude Code

## 首次登录

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Claude Code 会输出一个登录链接。在你自己的浏览器里打开，点击授权，再把代码粘贴回来。登录凭据保存在服务器的 `~/.claude` 里。

想用 API 密钥？启动前先设置好环境变量：

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

用 API 密钥也能正常使用 Claude Code，但 [Remote Control](https://code.claude.com/docs/zh-CN/remote-control)（在 Claude 应用或 claude.ai 上操作会话）需要用 claude.ai 账号登录。

## 用 tmux 保持运行

一个要跑一小时的 agent，不应该因为笔记本休眠就停掉。在 tmux 里运行，然后断开：

| | |
| --- | --- |
| 断开 | 先按 `Ctrl-b` 再按 `d` |
| 重新连上 | `tmux attach -t claude` |
| 新建窗口 | 先按 `Ctrl-b` 再按 `c` |
| 列出会话 | `tmux ls` |

自带的 `.tmux.conf` 开启了鼠标支持、5 万行滚动历史和 256 色。

也可以在桌面上打开 Konsole，运行 `tmux attach -t claude`。还是同一个会话，只是屏幕更大。

## 手机通知

`~/.claude/settings.json` 注册了一个 `Notification` hook，也就是 `~/.claude/hooks/notify.sh`。每当 Claude 在等你回复，它就会向 [ntfy.sh](https://ntfy.sh) 发送通知。

1. 在手机上安装 ntfy 应用，订阅一个别人猜不到的 topic，比如 `claude-7f3k9q2m`。
2. 在服务器上写入同一个 topic：

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   也可以在安装时用 `--ntfy-topic` 传入。

topic 需要保密：知道它的人都能看到你的通知。所以它单独放在一个文件里，也永远不会被导出到仓库。

## 预先配置好的内容

来自 `dotfiles/home/.claude`：

- **`settings.json`**：深色主题、全屏 TUI，状态栏显示模型、当前目录、git 分支和上下文用量，还有我在用的插件和通知 hook
- **`CLAUDE.md`**：一个空文件，用来写你自己的全局指令。只有文件不存在时才会创建，所以你写的内容不会被覆盖
- **`hooks/notify.sh`**：就是上面的 ntfy hook

在自己电脑上改完其中任何一个，运行 `claude-vps publish` 即可。见[配置同步](/zh/guide/sync)。

## 更新 Claude Code

原生安装的版本会在后台自动更新。想立即更新：

```bash
claude update
```
