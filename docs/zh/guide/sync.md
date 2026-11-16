---
description: "用 claude-vps publish、sync 和 autosync，在自己的电脑和 VPS 之间同步 KDE Plasma 和 Claude Code 配置。"
---

# 配置同步

服务器的外观和行为全部由仓库里的配置决定。你在自己的电脑上修改，服务器随后跟着更新。

```text
 your machine                  GitHub                     server
 ───────────                   ──────                     ──────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (or autosync, every 30 min)
```

## 在你的电脑上

先克隆仓库，把 CLI 加到 PATH 里（只需做一次）：

```bash
git clone https://github.com/halitsever/claude-code-vps.git ~/claude-code-vps
ln -s ~/claude-code-vps/bin/claude-vps ~/.local/bin/claude-vps
```

改完面板、快捷键、Konsole 配置文件或者 `~/.claude/settings.json` 之后，运行：

```bash
claude-vps publish
```

它会执行 `capture`，commit `dotfiles/` 并 push。想先看看改了什么：

```bash
claude-vps capture
git -C ~/claude-code-vps diff
```

## 在服务器上

```bash
claude-vps sync
```

它会拉取最新内容并执行 `apply`。每个要被覆盖的文件都会先复制到 `~/.local/state/claude-vps/backup-<timestamp>/`，没有变化的文件不会动。

也可以让它自动执行：

```bash
claude-vps autosync on     # systemd 用户定时器，每 30 分钟一次
claude-vps autosync        # 查看下次运行时间
claude-vps autosync off
```

::: warning Plasma 与正在使用的会话
Plasma 会把一部分设置留在内存里，注销时才写回文件。如果你通过 RDP 连着的时候同步了新配置，需要注销再登录才能看到。在这之前，不要在服务器上改同一项设置。
:::

## 会导出哪些文件

列表在 [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/manifest.txt) 里。以斜杠结尾表示整个目录。

| 类别 | 文件 |
| --- | --- |
| Plasma | `kdeglobals`、`kwinrc`、`kglobalshortcutsrc`、`plasmarc`、`plasmashellrc`、`plasma-org.kde.plasma.desktop-appletsrc`、`kdedefaults/`，以及电源和通知设置 |
| 应用 | `dolphinrc`、`konsolerc`、`katerc`、`~/.local/share/konsole/`、GTK 主题设置、`mimeapps.list` |
| 外观 | `~/.local/share/color-schemes/`、`plasma/`、`aurorae/`、`wallpapers/`（存在时） |
| Claude | `~/.claude/settings.json`、`hooks/` |
| Shell | `.tmux.conf`、`.xsession` |

想同步其他文件，在 manifest 里加一行即可。你电脑上不存在的路径会被跳过。

## 不会导出的内容

你的主目录路径会被替换成 `@HOME@`，这样换任何用户名都能用。记录最近文件和历史的部分会被删掉。凭据根本不在列表里：`~/.claude/.credentials.json`、`~/.claude/ntfy-topic`、SSH 密钥、`kwalletrc`、浏览器配置。请保持这样，因为仓库是公开的。
