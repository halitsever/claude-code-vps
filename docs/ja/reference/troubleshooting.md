---
title: "トラブルシューティング"
description: "Claude Code 用 VPS でよくある問題の対処法。RDP の黒い画面、xrdp のカラープロファイル確認、SSH の締め出し、claude が見つからない、同期エラー。"
---

# よくある問題と対処法

まずはこれを実行します。

```bash
claude-vps doctor
```

## RDP が黒い画面のまま切断される

たいていは `~/.xsession` がないか、そのユーザーの Plasma がすでに動いているのが原因です。

```bash
cat ~/.xsession                      # 最後の行が exec startplasma-x11 になっているか
loginctl list-sessions               # 自分のユーザーの古いセッションがあれば終了する
loginctl terminate-user $USER
```

ログは `~/.xsession-errors` と `/var/log/xrdp-sesman.log` にあります。

## 「Authentication is required to create a color managed device」と表示される

`rdp` の手順で入れた polkit のルールがこれを防ぎます。`id` で自分のユーザーが `users` グループに入っているか確認してから、再接続してください。

## RDP にまったく接続できない

```bash
sudo ss -tlnp | grep xrdp      # 53389 で待ち受けているか
sudo ufw status                # ポートが許可されているか
```

クラウド事業者が、サーバーの手前に独自のファイアウォールを置いている場合もあります。

## SSH でログインできなくなった

`ssh` の手順は、ユーザーに鍵があるときにしかパスワードログインを無効にしません。それでも締め出されてしまった場合は、事業者の Web コンソールからログインして次を実行します。

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

ネイティブインストーラーは `~/.local/bin` に入れます。Ubuntu はこのフォルダが存在すれば、ログイン時に `PATH` に追加します。一度ログアウトしてログインし直すか、`source ~/.profile` を実行してください。

## `claude-vps sync` で "Not possible to fast-forward" と出る

サーバー上のクローンにローカルの変更があります。サーバー側は pull するだけの想定です。

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## 古いファイルを元に戻す

`apply` は上書きするファイルを毎回バックアップしています。

```bash
ls ~/.local/state/claude-vps/
```
