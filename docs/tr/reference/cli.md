---
description: "Claude Code VPS kurulumu için claude-vps komutları ve seçenekleri: setup, sync, autosync, doctor, capture, publish, apply ve install.sh değişkenleri."
---

# CLI

```text
claude-vps <command> [options]
```

| Komut | Nerede | Ne yapar |
| --- | --- | --- |
| `setup` | sunucuda, root olarak | Kurulum adımlarını çalıştırır |
| `update` | sunucuda, root olarak | Son sürümü çeker, kurulumu ilk seferdeki seçeneklerle yeniden çalıştırır |
| `sync` | sunucuda | `git pull`, ardından `apply` |
| `autosync on\|off` | sunucuda | `sync` komutunu 30 dakikada bir çalıştıran systemd kullanıcı zamanlayıcısı |
| `doctor` | sunucuda | Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy ve autosync durumunu kontrol eder |
| `capture` | senin bilgisayarında | `dotfiles/manifest.txt` içindeki dosyaları `dotfiles/home` klasörüne kopyalar |
| `publish` | senin bilgisayarında | `capture`, commit ve push |
| `release X.Y.Z` | senin bilgisayarında | `VERSION` dosyasını yazar, `vX.Y.Z` etiketini atar ve push eder. GitHub sürümü `CHANGELOG.md` içeriğiyle yayınlar |
| `apply` | her yerde | `dotfiles/home` içeriğini `$HOME` klasörüne yazar, üzerine yazdığı dosyaları yedekler |
| `version` | her yerde | Sürümü gösterir |

## setup

```bash
sudo claude-vps setup [options]
```

| Seçenek | Varsayılan | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER`, yoksa sorar | Kullanıcı adı. Kullanıcı yoksa oluşturulur |
| `--rdp-port PORT` | `53389` | xrdp portu |
| `--rdp-private` | kapalı | RDP portunu ufw'de açmaz |
| `--ntfy-topic NAME` | sorar | Bildirimler için ntfy.sh topic'i |
| `--timezone TZ` | değişmez | örneğin `Europe/Istanbul` |
| `--no-desktop` | kapalı | `--skip desktop,rdp` ile aynı |
| `--skip a,b` | | Atlanacak adımlar |
| `--only a,b` | | Sadece bu adımları çalıştırır |
| `-y, --yes` | kapalı | Hiçbir şey sormaz. Kullanıcı adı `dev` olur, parola otomatik üretilir |
| `-n, --dry-run` | kapalı | Komutları çalıştırmaz, sadece ekrana yazar |

Adımlar sırasıyla: `base user ssh firewall desktop rdp apps claude dotfiles`.

## Güncelleme

Yeni sürüm çıktığında her sunucuda şunu çalıştır:

```bash
sudo claude-vps update
```

Komut yeni kodu çeker, nelerin değiştiğini gösterir ve kurulum adımlarının hepsini yeniden çalıştırır. Zaten yapılmış adımlar atlanır. xrdp ve SSH sadece ayarları değiştiyse yeniden başlatılır, bu yüzden açık RDP oturumun kopmaz. İlk kurulumda seçtiğin ayarlar (kullanıcı, RDP portu, atlanan adımlar) `/etc/claude-vps.conf` dosyasında saklanır ve tekrar kullanılır.

`claude-vps sync` de yeni bir sürüm geldiğinde haber verir.

## Sürüm yayınlama

Kendi bilgisayarında `CHANGELOG.md` dosyasına `## X.Y.Z` başlıklı bir bölüm ekle, commit et, sonra şunu çalıştır:

```bash
claude-vps release X.Y.Z
```

Release workflow'u etiketin `VERSION` ile aynı olduğunu kontrol eder ve GitHub'da yeni sürümü yayınlar. Sürüm notları changelog'daki o bölümden alınır.

## Ayarların kaynağı olan makineler

`claude-vps capture` çalıştığı makineyi ayar kaynağı olarak işaretler (`~/.config/claude-vps/source`). Böyle bir makinede `apply` ve `sync` dosyalarına dokunmaz, çünkü repodaki kopya şu an kullandığından eski olabilir. Yine de üzerine yazmak istersen `claude-vps apply --force` kullan.

## install.sh

Kurulum script'i üç ortam değişkenine bakar:

| Değişken | Varsayılan |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

`bash -s --` sonrasına yazdığın her şey `setup` komutuna aktarılır.
