---
description: "claude-vps の全コマンドとオプションのリファレンス。setup、sync、autosync、doctor、capture、publish、apply と install.sh の環境変数。"
---

# CLI

```text
claude-vps <command> [options]
```

| コマンド | 実行場所 | 内容 |
| --- | --- | --- |
| `setup` | サーバー（root） | インストール手順を実行 |
| `update` | サーバー（root） | 最新版を取得し、初回インストール時のオプションで setup をやり直す |
| `sync` | サーバー | `git pull` のあと `apply` |
| `autosync on\|off` | サーバー | systemd のユーザータイマーで30分ごとに `sync` を実行 |
| `doctor` | サーバー | Claude、tmux、Docker、xrdp、Plasma、ufw、ntfy、autosync を確認 |
| `capture` | 手元の PC | `dotfiles/manifest.txt` にあるファイルを `dotfiles/home` にコピー |
| `publish` | 手元の PC | `capture` してから commit と push |
| `release X.Y.Z` | 手元の PC | `VERSION` を書き換え、`vX.Y.Z` タグを付けて push。GitHub が `CHANGELOG.md` をもとにリリースを公開 |
| `apply` | どこでも | `dotfiles/home` を `$HOME` に書き込み。上書きするものは先にバックアップ |
| `version` | どこでも | バージョンを表示 |

## setup

```bash
sudo claude-vps setup [options]
```

| オプション | デフォルト | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER`。なければ質問 | 作業用ユーザー。存在しなければ作成 |
| `--rdp-port PORT` | `53389` | xrdp のポート |
| `--rdp-private` | オフ | ufw で RDP のポートを開けない |
| `--ntfy-topic NAME` | 質問 | 通知に使う ntfy.sh の topic |
| `--timezone TZ` | 変更しない | 例：`Europe/Istanbul` |
| `--no-desktop` | オフ | `--skip desktop,rdp` と同じ |
| `--skip a,b` | | スキップする手順 |
| `--only a,b` | | 指定した手順だけを実行 |
| `-y, --yes` | オフ | 質問しない。ユーザー名は `dev`、パスワードは自動生成 |
| `-n, --dry-run` | オフ | コマンドを実行せずに表示する |

手順の順番：`base user ssh firewall desktop rdp apps claude dotfiles`

## アップデート

新しいバージョンが出たら、各サーバーで次を実行します。

```bash
sudo claude-vps update
```

新しいコードを取得し、変更内容を表示してから、setup の全手順をもう一度実行します。完了済みの手順はスキップされます。xrdp と SSH は設定が変わったときだけ再起動するので、開いている RDP セッションは切れません。初回インストールで選んだオプション（ユーザー、RDP ポート、スキップした手順）は `/etc/claude-vps.conf` に保存され、そのまま使われます。

新しいバージョンが届いたときは `claude-vps sync` でも知らせてくれます。

## バージョンのリリース

手元の PC で `CHANGELOG.md` に `## X.Y.Z` のセクションを追加して commit し、次を実行します。

```bash
claude-vps release X.Y.Z
```

リリース用の workflow がタグと `VERSION` の一致を確認し、GitHub リリースを公開します。リリースノートには changelog のそのセクションが使われます。

## 設定元のマシン

`claude-vps capture` を実行したマシンは設定元としてマークされます（`~/.config/claude-vps/source`）。このマシンでは `apply` と `sync` がファイルを書き換えません。リポジトリ側のコピーが、いま使っている設定より古い場合があるためです。それでも上書きするときは `claude-vps apply --force` を使います。

## install.sh

ブートストラップ用のスクリプトは、3つの環境変数を読み込みます。

| 変数 | デフォルト |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

`bash -s --` のあとに書いた引数は、すべて `setup` に渡されます。
