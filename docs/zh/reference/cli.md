---
description: "claude-vps 所有命令和参数的参考：setup、sync、autosync、doctor、capture、publish、apply，以及 install.sh 的环境变量。"
---

# CLI

```text
claude-vps <command> [options]
```

| 命令 | 在哪里运行 | 作用 |
| --- | --- | --- |
| `setup` | 服务器，root 身份 | 执行安装步骤 |
| `sync` | 服务器 | 先 `git pull`，再 `apply` |
| `autosync on\|off` | 服务器 | 用 systemd 用户定时器每 30 分钟运行一次 `sync` |
| `doctor` | 服务器 | 检查 Claude、tmux、Docker、xrdp、Plasma、ufw、ntfy 和 autosync |
| `capture` | 你的电脑 | 把 `dotfiles/manifest.txt` 里列出的文件复制到 `dotfiles/home` |
| `publish` | 你的电脑 | 执行 `capture`，然后 commit 并 push |
| `apply` | 任意位置 | 把 `dotfiles/home` 写入 `$HOME`，覆盖前先备份 |
| `version` | 任意位置 | 显示版本号 |

## setup

```bash
sudo claude-vps setup [options]
```

| 参数 | 默认值 | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER`，否则询问 | 工作用户，不存在时会创建 |
| `--rdp-port PORT` | `53389` | xrdp 端口 |
| `--rdp-private` | 关 | 不在 ufw 中开放 RDP 端口 |
| `--ntfy-topic NAME` | 询问 | 用于通知的 ntfy.sh topic |
| `--timezone TZ` | 不修改 | 例如 `Europe/Istanbul` |
| `--no-desktop` | 关 | 等同于 `--skip desktop,rdp` |
| `--skip a,b` | | 要跳过的步骤 |
| `--only a,b` | | 只运行这些步骤 |
| `-y, --yes` | 关 | 不提问。用户名默认为 `dev`，密码自动生成 |
| `-n, --dry-run` | 关 | 只打印命令，不执行 |

步骤顺序：`base user ssh firewall desktop rdp apps claude dotfiles`。

## install.sh

引导脚本会读取三个环境变量：

| 变量 | 默认值 |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

`bash -s --` 后面的所有参数都会传给 `setup`。
