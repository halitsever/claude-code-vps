---
title: "インストールされるもの"
description: "claude-vps が Ubuntu サーバーで実行する全手順：パッケージ、swap、SSH の強化、ufw、KDE Plasma、xrdp、Docker、Chrome、Claude Code、dotfiles。"
---

# claude-vps setup がインストールするもの

`claude-vps setup` は9つの手順を順番に実行します。どの手順も [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh) にある普通の bash 関数なので、サーバーで何が実行されるかをそのまま読めます。`--skip` で手順を飛ばしたり、`--only` で一部だけを実行したりできます。

## 1. base

- `apt upgrade` ですべてのパッケージを更新
- `git curl jq ripgrep fd-find tmux htop build-essential python3` などの基本ツール
- Node.js 20 以上。Ubuntu 24.04 の apt には 18 しかないため、NodeSource のリポジトリから入れます
- `unattended-upgrades` を有効化。セキュリティパッチが自動で入ります
- swap がなく、メモリが 8 GB 未満なら 4 GB の swap ファイルを作成。Plasma と複数の agent を動かしても OOM killer に止められにくくなります
- `--timezone` を指定した場合はタイムゾーンを設定

## 2. user

作業用ユーザーを作成し、`sudo` グループに追加します。そのユーザーに SSH 鍵がなければ `/root/.ssh/authorized_keys` をコピーします。ここで決めたパスワードは、RDP のログイン画面で入力するものです。

## 3. ssh

`/etc/ssh/sshd_config.d/10-claude-vps.conf` を書き込みます。

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd は同じ項目について最初に読んだ値を使います。ファイル名を `10-` で始めているのはそのためで、多くのクラウドイメージに入っている `50-cloud-init.conf` より優先されます。ユーザーにまだ SSH 鍵がない場合、この手順は警告を出してスキップされます。自分を締め出してしまうことはありません。

## 4. firewall

`ufw` で OpenSSH と RDP のポートだけを許可し、ほかはすべて閉じます。`--rdp-private` を付けると RDP のポートも閉じたままにし、SSH トンネル経由で接続します。

## 5. desktop

`kde-plasma-desktop` と X11 セッション（Ubuntu 25.10 以降では `plasma-session-x11` と `kwin-x11`）、Konsole、Dolphin、Kate、Spectacle、Noto と JetBrains Mono のフォントを入れます。SDDM は無効にし、デフォルトのターゲットを `multi-user` にします。サーバーの前に人が座ることはないので、起動するとコンソールのままで、Plasma は接続したときにだけ起動します。

::: info なぜ X11 なのか
xrdp が扱うのは Xorg のセッションです。Ubuntu 24.04 から 26.04 では、Plasma 6 にまだ X11 セッションがあります。私が普段 RDP で使っているのもこれです。
:::

## 6. rdp

- `xrdp` と `xorgxrdp` を入れ、ポート **53389** で待ち受け（`--rdp-port` で変更可能）
- `~/.xsession` を作成し、適切な `XDG_*` 変数で `startplasma-x11` を起動
- polkit のルールを追加。これがないと、ログインのたびに「カラーマネージドデバイスの作成には認証が必要です」という確認が出ます

## 7. apps

- Docker（`docker.io`、compose v2、buildx）。ユーザーを `docker` グループに追加
- GitHub CLI（`gh`）
- Google の apt リポジトリから Google Chrome（amd64 と arm64）。Claude が本物のブラウザを必要とするときに便利です

## 8. claude

- 公式のネイティブインストーラーで Claude Code を `~/.local/bin/claude` に入れます。自動でアップデートされます
- [claudegrid](https://github.com/halitsever/claudegrid) を最新の `.deb` リリースからインストールします。1 つのコマンドで Konsole や tmux に Claude Code エージェントのグリッドを開けます。Konsole のプロファイルとアプリメニューの項目も追加されます
- ntfy.sh の topic を指定した場合は `~/.claude/ntfy-topic` に保存します。通知用の hook はここから読み込みます

## 9. dotfiles

`/opt/claude-vps` の所有者を作業用ユーザーに変え、`claude-vps` を `/usr/local/bin` にリンクし、そのユーザーとして `claude-vps apply` を実行します。これで `dotfiles/home` 以下のファイルがすべてホームディレクトリに書き込まれます。KDE の設定、Konsole のプロファイル、`~/.claude/settings.json`、`CLAUDE.md`、hook、`.tmux.conf` です。

## 手順をもう一度実行する

どの手順もまず現在の状態を確認するので、再実行しても問題ありません。

```bash
sudo claude-vps setup --only desktop,rdp     # 例：OS のバージョンアップ後
sudo claude-vps setup --skip apps            # Docker と Chrome 以外をすべて実行
sudo claude-vps setup --no-desktop           # ターミナルだけのサーバー
```
