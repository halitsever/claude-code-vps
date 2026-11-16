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
| `update` | 服务器，root 身份 | 拉取最新版本，并用首次安装时的参数重新运行 setup |
| `sync` | 服务器 | 先 `git pull`，再 `apply` |
| `autosync on\|off` | 服务器 | 用 systemd 用户定时器每 30 分钟运行一次 `sync` |
| `doctor` | 服务器 | 检查 Claude、tmux、Docker、xrdp、Plasma、ufw、ntfy 和 autosync |
| `capture` | 你的电脑 | 把 `dotfiles/manifest.txt` 里列出的文件复制到 `dotfiles/home` |
| `publish` | 你的电脑 | 执行 `capture`，然后 commit 并 push |
| `release X.Y.Z` | 你的电脑 | 写入 `VERSION`，打上 `vX.Y.Z` 标签并 push。GitHub 根据 `CHANGELOG.md` 发布版本 |
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

## 更新

有新版本时，在每台服务器上运行：

```bash
sudo claude-vps update
```

它会拉取新代码，显示改了什么，然后重新执行所有 setup 步骤。已经完成的步骤会跳过。只有配置变了才会重启 xrdp 和 SSH，所以已打开的 RDP 会话不会断开。首次安装时选的参数（用户、RDP 端口、跳过的步骤）保存在 `/etc/claude-vps.conf`，之后会继续使用。

有新版本到达时，`claude-vps sync` 也会提醒你。

## 发布新版本

在你的电脑上，往 `CHANGELOG.md` 里加一个 `## X.Y.Z` 小节并 commit，然后运行：

```bash
claude-vps release X.Y.Z
```

release workflow 会检查标签是否和 `VERSION` 一致，然后在 GitHub 上发布版本，发布说明就是 changelog 里的这一节。

## 作为配置来源的机器

`claude-vps capture` 会把运行它的机器标记为配置来源（`~/.config/claude-vps/source`）。在这样的机器上，`apply` 和 `sync` 不会改动你的文件，因为仓库里的副本可能比你正在用的旧。如果确实要覆盖，用 `claude-vps apply --force`。

## install.sh

引导脚本会读取三个环境变量：

| 变量 | 默认值 |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

`bash -s --` 后面的所有参数都会传给 `setup`。
