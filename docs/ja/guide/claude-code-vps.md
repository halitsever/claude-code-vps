---
title: "VPS で Claude Code を動かす方法"
description: "Ubuntu VPS で Claude Code を動かす手順を順に解説。安全な SSH、切れない tmux セッション、スマホ通知、RDP で使える KDE Plasma デスクトップまで。"
---

# VPS で Claude Code を動かす方法

このページでは、私が使っている環境を手作業で組む手順をすべて紹介します。安い Ubuntu サーバーで Claude Code を24時間動かし、ふだんはどこからでも SSH でつなぎます。画面が欲しいときは RDP で KDE Plasma デスクトップを開きます。

ここに出てくるコマンドは、どれも [`claude-vps setup`](/ja/guide/getting-started) が自動で実行するものです。中身を理解したいとき、または自分で手を動かして構築したいときに読んでください。

## VPS で Claude Code を動かす理由

- **ノート PC がスリープしても作業が止まりません。** 大きなリファクタリングやテスト、マイグレーションも、席を外している間に終わります。
- **手元の PC が汚れません。** agent がパッケージを入れたり、Docker や開発サーバーを動かしたりするのはサーバーの中だけです。環境が散らかっても、10分あれば作り直せます。
- **どの端末からでも同じ環境です。** ノート PC、デスクトップ、タブレット、スマホのどれからでも、同じ tmux セッションと同じデスクトップにつながります。
- **回線が速く**、Git のホスティングやパッケージレジストリにも近い場所に置けます。

## サーバーを選ぶ

| 用途 | vCPU | メモリ | ディスク |
| --- | --- | --- | --- |
| ターミナルのみ | 2 | 4 GB | 40 GB |
| KDE デスクトップあり | 4 | 8 GB | 80 GB |
| 複数の agent と Docker | 8 | 16 GB | 160 GB |

Ubuntu 24.04 LTS 以降が使えれば、どのサービスでもかまいません。Hetzner、DigitalOcean、OVH、Vultr、Linode、AWS Lightsail、自宅の空いているマシンでも動きます。リージョンは近い場所を選ぶと RDP の反応がよくなります。サーバー作成時に SSH 公開鍵を登録しておけば、root のパスワードは一切不要です。

## 1. 初回ログインと更新

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades` はセキュリティパッチを自動で入れてくれます。常時オンラインのサーバーでは大事な設定です。

メモリの少ないサーバーには swap を追加しておきます。agent が重い処理をしたときに OOM killer に止められないようにするためです。

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. ユーザーを作る

Claude Code を root で動かすのはやめましょう。sudo 権限を持つ一般ユーザーを作ります。

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

次に進む前に、別のターミナルで `ssh dev@<server-ip>` でログインできることを確認してください。

## 3. SSH を固める

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd は同じ項目について最初に読んだ値を使い、設定ファイルはファイル名の順に読み込まれます。ファイル名を `10-` で始めているのはそのためです。多くのクラウドイメージには `PasswordAuthentication yes` と書かれた `50-cloud-init.conf` が入っているので、それより先に読ませる必要があります。

## 4. ファイアウォール

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # インターネットから RDP でつなぐ場合のみ。詳しくは後述
ufw --force enable
```

## 5. Claude Code を入れる

作成したユーザーでログインし、公式のネイティブインストーラーを使います。Node.js は不要で、自動でアップデートされます。

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

インストール先は `~/.local/bin/claude` です。一度ログアウトしてログインし直すと、このフォルダが `PATH` に入ります。そのあと確認します。

```bash
claude --version
```

## 6. 画面のないサーバーでログインする

サーバーにブラウザはありませんが、なくても問題ありません。

```bash
claude
```

Claude Code が URL を表示します。それを手元の PC やスマホで開いて承認し、表示されたコードをターミナルに貼り付けます。ログイン情報はサーバーの `~/.claude` に保存されます。

Pro や Max のプランではなく Anthropic の API キーを使う場合は、シェルの設定ファイルに書いておきます。

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

API キーでも Claude Code は使えますが、Claude アプリや claude.ai からセッションを操作する [Remote Control](https://code.claude.com/docs/ja/remote-control) には claude.ai でのログインが必要です。

## 7. tmux でセッションを保つ

SSH のセッションで直接 Claude を動かすと、ノート PC を閉じた時点で止まってしまいます。tmux の中で動かしましょう。

```bash
tmux new -s claude
claude
# Ctrl-b を押してから d でデタッチ。agent はそのまま動き続ける
tmux attach -t claude   # あとで、どの端末からでも再接続
```

`~/.tmux.conf` を少し書いておくと使いやすくなります。

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Claude に呼ばれたら通知を受け取る

Claude Code は入力を待っているときに `Notification` hook を実行します。これを [ntfy.sh](https://ntfy.sh) でスマホに送ります。

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude が入力を待っています"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
EOF
chmod +x ~/.claude/hooks/notify.sh
echo my-hard-to-guess-topic > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
```

`~/.claude/settings.json` に登録します。

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

スマホの ntfy アプリで同じ topic を購読します。topic はパスワードと同じように扱ってください。

## 9. 任意：RDP で KDE Plasma デスクトップを使う

作業のほとんどはターミナルで足ります。agent の隣で Chrome を開きたいとき、ファイルマネージャーを使いたいとき、大きな画面で Konsole をいくつも並べたいときにはデスクトップが便利です。

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

Ubuntu 24.04 には `plasma-session-x11` と `kwin-x11` という独立したパッケージがないので、この2つは外してください。

xrdp が自分のユーザーで Plasma を起動するように設定します。

```bash
cat > ~/.xsession <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
sudo systemctl restart xrdp
```

最後に、ログインのたびに出てくるカラープロファイルのパスワード確認を止めます。

```bash
sudo tee /etc/polkit-1/rules.d/45-colord.rules >/dev/null <<'EOF'
polkit.addRule(function (action, subject) {
  if (action.id.indexOf("org.freedesktop.color-manager.") === 0 && subject.isInGroup("users")) {
    return polkit.Result.YES;
  }
});
EOF
sudo usermod -aG users dev
```

あとは好きな RDP クライアントで `<server-ip>:53389` に接続します。ポートを閉じたまま SSH トンネルでつなぐ方法などは[リモートデスクトップ](/ja/guide/remote-desktop)を参照してください。

## 10. 開発ツール

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## セキュリティチェックリスト

- SSH は鍵認証のみ。root のパスワードログインは無効
- ファイアウォールを有効にし、必要なポートだけを開ける
- Claude Code は root ではなく一般ユーザーで動かす
- `--dangerously-skip-permissions` は使い捨てのコンテナの中だけで使う。トークンや SSH 鍵があるマシンでは使わない
- 秘密情報（`~/.claude/.credentials.json`、API キー、ntfy の topic）は公開リポジトリに入れない
- セキュリティ更新の自動インストールを有効にする

## コマンド1つで全部やる

ここまでの作業に加えて、自分の KDE と Claude の設定の反映まで、claude-vps がすべて自動で行います。

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

詳しくは[はじめに](/ja/guide/getting-started)を参照してください。

## よくある質問

### GUI のないサーバーでも Claude Code は動きますか？

動きます。Claude Code はターミナルアプリです。ログインは、別の端末でリンクを開くだけで済みます。

### どの Claude プランが必要ですか？

Claude Code が使えるプラン（Pro または Max）か、従量課金の Anthropic API キーが必要です。

### Claude Code 用の VPS はいくらかかりますか？

格安のサービスなら、メモリ 4〜8 GB のサーバーで月額 5〜20 米ドルほどです。Claude の利用料は、プランや API キーに応じて別にかかります。

### SSH を閉じても Claude は動き続けますか？

tmux（または screen）の中で動かしている場合だけです。`tmux new -s claude` で起動し、`Ctrl-b d` でデタッチします。

### 安全ですか？

自分で管理するほかのサーバーと同じ程度に安全です。上のチェックリストを守り、agent には必要のない認証情報を触らせないようにしてください。
