---
description: "新しい Ubuntu 24.04 / 26.04 の VPS にコマンド1つで claude-vps を入れ、約10分で Claude Code、RDP で使える KDE Plasma、安全な SSH を用意します。"
---

# はじめに

claude-vps は、新しい Ubuntu サーバーを、私が Claude Code を動かしている環境と同じ状態にします。sudo 権限のあるユーザーを作り、SSH を鍵認証のみにして、ファイアウォールを有効にします。RDP で接続できる KDE Plasma デスクトップ、Docker、Chrome も入ります。Claude Code 本体も、私の設定、hook、KDE のレイアウトを反映した状態で入ります。

## 必要なもの

| | |
| --- | --- |
| **OS** | Ubuntu 24.04 LTS 以降（私は 26.04 を使っています） |
| **CPU / メモリ** | Plasma を動かすには最低 2 vCPU、4 GB。4 vCPU / 8 GB あれば普通のデスクトップと同じ感覚で使えます |
| **ディスク** | 25 GB 以上 |
| **アクセス** | SSH で root としてログインできること。SSH 鍵を登録済みだと理想的です |
| **アーキテクチャ** | amd64 ではすべて入ります。arm64 でも動きますが、Chrome は入りません |

インストール後に Claude Code にログインするため、Claude の Pro または Max プランか、Anthropic の API キーも用意してください。

## インストール

root（または sudo できるユーザー）で SSH ログインし、次を実行します。

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

このリポジトリが `/opt/claude-vps` にクローンされ、`claude-vps setup` が実行されます。途中で2つのことを聞かれます。作業用ユーザーの名前と、そのパスワードです（sudo と RDP ログインに使います）。パスワードを空にすると自動で生成され、最後に表示されます。

質問を省きたいときは、`bash -s --` のあとにオプションを渡します。

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

すべてのオプションは [CLI リファレンス](/ja/reference/cli)にあります。

::: tip まず試したいとき
`--dry-run` を付けると、実行するコマンドを表示するだけで、実際には何も変更しません。
:::

## 完了したら

次のような概要が表示されます。

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **新しいユーザーで SSH ログインします。** root の SSH 鍵がコピーされているので、同じ鍵でログインできます。
2. **tmux の中で Claude Code を起動して**ログインします。[Claude Code の使い方](/ja/guide/claude-code)を参照してください。
3. **好きな RDP クライアントでデスクトップを開きます。** [リモートデスクトップ](/ja/guide/remote-desktop)を参照してください。

## 自分の設定を使う

初期状態では、サーバーには `dotfiles/home` にある私の KDE と Claude の設定が入ります。自分の設定を使いたい場合は、リポジトリを fork し、手元の PC で `claude-vps capture` を実行して push します。そのうえで、インストーラーの参照先を自分の fork にします。

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

全体の流れは[設定の同期](/ja/guide/sync)で説明しています。
