---
title: "Claude Code の使い方"
description: "画面のないサーバーで Claude Code にログインし、tmux で SSH が切れても agent を動かし続け、ntfy.sh でスマホに通知を送る方法。"
---

# サーバー上で Claude Code を使う

## 初回ログイン

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Claude Code がログイン用のリンクを表示します。手元のブラウザで開いて承認し、表示されたコードを貼り付けます。認証情報はサーバーの `~/.claude` に保存されます。

API キーを使いたい場合は、起動前に環境変数を設定しておきます。

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

API キーでも Claude Code は使えますが、Claude アプリや claude.ai からセッションを操作する [Remote Control](https://code.claude.com/docs/ja/remote-control) には claude.ai でのログインが必要です。

## tmux で動かし続ける

1時間かかる作業が、ノート PC のスリープで止まってしまっては困ります。tmux の中で動かし、デタッチしておきましょう。

| | |
| --- | --- |
| デタッチ | `Ctrl-b` を押してから `d` |
| 再接続 | `tmux attach -t claude` |
| 新しいウィンドウ | `Ctrl-b` を押してから `c` |
| セッション一覧 | `tmux ls` |

同梱の `.tmux.conf` では、マウス操作、5万行のスクロールバック、256色が有効になっています。

デスクトップで Konsole を開いて `tmux attach -t claude` を実行することもできます。同じセッションを大きな画面で見られます。

## スマホへの通知

`~/.claude/settings.json` には `Notification` hook として `~/.claude/hooks/notify.sh` が登録されています。Claude が入力を待つたびに、これが [ntfy.sh](https://ntfy.sh) に通知を送ります。

1. スマホに ntfy アプリを入れ、他人に推測されない topic を購読します。例：`claude-7f3k9q2m`
2. サーバーにも同じ topic を設定します。

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   セットアップ時に `--ntfy-topic` で渡すこともできます。

topic は秘密にしてください。知っている人なら誰でも通知を読めてしまいます。そのため topic は専用のファイルに置かれ、リポジトリに取り込まれることはありません。

## 最初から入っている設定

`dotfiles/home/.claude` から入るもの：

- **`settings.json`**：ダークテーマ、全画面の TUI、モデル・フォルダ・git ブランチ・コンテキスト使用量を表示するステータスライン、私が使っているプラグイン、通知用の hook
- **`CLAUDE.md`**：自分用のグローバルな指示を書くための空ファイル。ファイルがないときだけ作られるので、書いた内容が上書きされることはありません
- **`hooks/notify.sh`**：上で説明した ntfy 用の hook

どれも手元の PC で変更してから `claude-vps publish` を実行すれば反映できます。[設定の同期](/ja/guide/sync)を参照してください。

## Claude Code のアップデート

ネイティブ版はバックグラウンドで自動的にアップデートされます。すぐに更新したい場合は次を実行します。

```bash
claude update
```
