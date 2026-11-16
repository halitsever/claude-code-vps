# CLI

```text
claude-vps <command> [options]
```

| Komut | Nerede | Ne yapar |
| --- | --- | --- |
| `setup` | sunucu, root olarak | Kurulum adımlarını çalıştırır |
| `sync` | sunucu | `git pull`, ardından `apply` |
| `autosync on\|off` | sunucu | `sync` komutunu 30 dakikada bir çalıştıran systemd user timer |
| `doctor` | sunucu | Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy ve autosync durumunu kontrol eder |
| `capture` | kendi makinen | `dotfiles/manifest.txt` içindeki dosyaları `dotfiles/home` altına kopyalar |
| `publish` | kendi makinen | `capture`, commit ve push |
| `apply` | her yerde | `dotfiles/home` içeriğini `$HOME` altına yazar, üzerine yazdıklarını yedekler |
| `version` | her yerde | Sürümü yazar |

## setup

```bash
sudo claude-vps setup [options]
```

| Seçenek | Varsayılan | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER` ya da sorar | İş istasyonu kullanıcısı, yoksa oluşturulur |
| `--rdp-port PORT` | `53389` | xrdp portu |
| `--rdp-private` | kapalı | RDP portunu ufw'de açma |
| `--ntfy-topic NAME` | sorar | Bildirimler için ntfy.sh topic'i |
| `--timezone TZ` | değişmez | örn. `Europe/Istanbul` |
| `--no-desktop` | kapalı | `--skip desktop,rdp` ile aynı |
| `--skip a,b` | | Atlanacak adımlar |
| `--only a,b` | | Sadece bu adımları çalıştır |
| `-y, --yes` | kapalı | Soru sorma. Kullanıcı varsayılan olarak `dev`, parola üretilir |
| `-n, --dry-run` | kapalı | Komutları çalıştırmak yerine yazdır |

Adımlar, sırasıyla: `base user ssh firewall desktop rdp apps claude dotfiles`.

## install.sh

Bootstrap script'i üç ortam değişkeni okur:

| Değişken | Varsayılan |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

`bash -s --` sonrasındaki her şey `setup` komutuna geçirilir.
