---
description: "claude-vps の publish、sync、autosync を使って、手元の PC と VPS の間で KDE Plasma と Claude Code の設定を同期する方法。"
---

# 設定の同期

サーバーの見た目や動作は、すべてリポジトリの内容で決まります。手元の PC で設定を変えると、サーバーもあとからそれに合わせて更新されます。

```text
 your machine                  GitHub                     server
 ───────────                   ──────                     ──────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (or autosync, every 30 min)
```

## 手元の PC で

最初に一度だけ、リポジトリをクローンして CLI を PATH に入れます。

```bash
git clone https://github.com/halitsever/claude-code-vps.git ~/claude-code-vps
ln -s ~/claude-code-vps/bin/claude-vps ~/.local/bin/claude-vps
```

パネル、ショートカット、Konsole のプロファイル、`~/.claude/settings.json` などを変更したら、次を実行します。

```bash
claude-vps publish
```

これで `capture` が実行され、`dotfiles/` が commit されて push されます。先に差分を確認したい場合は次のようにします。

```bash
claude-vps capture
git -C ~/claude-code-vps diff
```

## サーバーで

```bash
claude-vps sync
```

変更を pull してから `apply` を実行します。上書きされるファイルは、先に `~/.local/state/claude-vps/backup-<timestamp>/` にコピーされます。変更のないファイルには手を付けません。

自動で実行させることもできます。

```bash
claude-vps autosync on     # systemd のユーザータイマーで30分ごとに実行
claude-vps autosync        # 次の実行時刻を表示
claude-vps autosync off
```

::: warning Plasma のセッション中の注意
Plasma は一部の設定をメモリに持っていて、ログアウト時にファイルへ書き戻します。RDP で接続している間に同期が入った場合は、一度ログアウトしてログインし直すと反映されます。それまでは、サーバー側で同じ設定を変更しないでください。
:::

## 取り込まれるファイル

一覧は [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/manifest.txt) にあります。末尾にスラッシュがあるものはフォルダ全体が対象です。

| 分類 | ファイル |
| --- | --- |
| Plasma | `kdeglobals`、`kwinrc`、`kglobalshortcutsrc`、`plasmarc`、`plasmashellrc`、`plasma-org.kde.plasma.desktop-appletsrc`、`kdedefaults/`、電源と通知の設定 |
| アプリ | `dolphinrc`、`konsolerc`、`katerc`、`~/.local/share/konsole/`、GTK テーマの設定、`mimeapps.list` |
| 外観 | `~/.local/share/color-schemes/`、`plasma/`、`aurorae/`、`wallpapers/`（存在する場合） |
| Claude | `~/.claude/settings.json`、`hooks/` |
| シェル | `.tmux.conf`、`.xsession` |

ほかのファイルも同期したい場合は、manifest に1行追加します。手元の PC に存在しないパスはスキップされます。

## 取り込まれないもの

ホームディレクトリのパスは `@HOME@` に置き換えられるので、どのユーザー名でも使えます。最近使ったファイルや履歴を記録しているセクションは削除されます。認証情報はそもそも一覧に入っていません。`~/.claude/.credentials.json`、`~/.claude/ntfy-topic`、SSH 鍵、`kwalletrc`、ブラウザのプロファイルなどです。リポジトリは公開されているので、この状態を保ってください。
