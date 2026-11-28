---
title: "Ayarları senkron tutmak"
description: "KDE Plasma ve Claude Code ayarlarını claude-vps publish, sync ve autosync ile kendi bilgisayarın ve VPS sunucun arasında senkron tut."
---

# Ayarları bilgisayarınla sunucu arasında senkron tutmak

Sunucunun bütün ayarları repoda durur. Değişikliği kendi bilgisayarında yaparsın, sunucu repodan çekip aynısını uygular.

```text
 senin bilgisayarın            GitHub                     sunucu
 ──────────────────            ──────                     ──────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (ya da 30 dakikada bir autosync)
```

## Kendi bilgisayarında

Repoyu bir kere klonla ve CLI'ı `PATH`'e ekle:

```bash
git clone https://github.com/halitsever/claude-code-vps.git ~/claude-code-vps
ln -s ~/claude-code-vps/bin/claude-vps ~/.local/bin/claude-vps
```

Bir paneli, kısayolu, Konsole profilini ya da `~/.claude/settings.json` dosyasını değiştirdikten sonra şunu çalıştır:

```bash
claude-vps publish
```

Bu komut `capture` çalıştırır, `dotfiles/` klasörünü commit'ler ve push'lar. Önce farkları görmek istersen:

```bash
claude-vps capture
git -C ~/claude-code-vps diff
```

## Sunucuda

```bash
claude-vps sync
```

Bu komut değişiklikleri çeker ve `apply` çalıştırır. Üzerine yazacağı her dosyayı önce `~/.local/state/claude-vps/backup-<timestamp>/` klasörüne yedekler. Değişmeyen dosyalara dokunmaz.

İstersen bunu otomatik de yapabilir:

```bash
claude-vps autosync on     # systemd kullanıcı zamanlayıcısı, 30 dakikada bir
claude-vps autosync        # bir sonraki çalışma zamanını gösterir
claude-vps autosync off
```

::: warning Plasma açıkken senkronizasyon
Plasma bazı ayarları bellekte tutar ve oturumu kapattığında diske yazar. RDP ile bağlıyken bir senkronizasyon gelirse değişikliği görmek için oturumu kapatıp tekrar aç. Bu arada aynı ayarı sunucuda değiştirme, yoksa biri diğerinin üzerine yazar.
:::

## Hangi dosyalar alınır

Liste [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/manifest.txt) dosyasında. Sonu `/` ile biten satırlar klasörün tamamını alır.

| Alan | Dosyalar |
| --- | --- |
| Plasma | `kdeglobals`, `kwinrc`, `kglobalshortcutsrc`, `plasmarc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kdedefaults/`, güç ve bildirim ayarları |
| Uygulamalar | `dolphinrc`, `konsolerc`, `katerc`, `~/.local/share/konsole/`, GTK tema ayarları, `mimeapps.list` |
| Görünüm | Varsa `~/.local/share/color-schemes/`, `plasma/`, `aurorae/`, `wallpapers/` |
| Claude | `~/.claude/settings.json`, `hooks/` |
| Shell | `.tmux.conf`, `.xsession` |

Başka bir dosyayı da takip etmek istersen manifest'e bir satır ekle. Senin bilgisayarında olmayan yollar atlanır.

## Hangi dosyalar asla alınmaz

Ev klasörünün yolu `@HOME@` ile değiştirilir, böylece dosyalar her kullanıcı adıyla çalışır. Son açılan dosyaları ve geçmişi tutan bölümler silinir. Gizli bilgiler listede hiç yok: `~/.claude/.credentials.json`, `~/.claude/ntfy-topic`, SSH anahtarları, `kwalletrc` ve tarayıcı profilleri. Repo herkese açık olduğu için bu liste böyle kalmalı.
