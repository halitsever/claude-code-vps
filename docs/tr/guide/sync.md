---
description: "KDE Plasma ve Claude Code ayarlarını claude-vps publish, sync ve autosync ile kendi makinen ve VPS'in arasında senkron tut."
---

# Config senkronizasyonu

Sunucunun nasıl göründüğünün ve nasıl davrandığının tek doğru kaynağı repo. Sen kendi makinende değişiklik yaparsın, sunucu arkandan gelir.

```text
 senin makinen                 GitHub                     sunucu
 ─────────────                 ──────                     ──────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (ya da autosync, 30 dk'da bir)
```

## Kendi makinende

Repoyu bir kere klonla ve CLI'ı PATH'e ekle:

```bash
git clone https://github.com/halitsever/claude-code-vps.git ~/claude-code-vps
ln -s ~/claude-code-vps/bin/claude-vps ~/.local/bin/claude-vps
```

Bir paneli, kısayolu, Konsole profilini ya da `~/.claude/settings.json` dosyasını değiştirdikten sonra:

```bash
claude-vps publish
```

Bu komut `capture` çalıştırır, `dotfiles/` klasörünü commit'ler ve push'lar. Önce diff'e bakmak istersen:

```bash
claude-vps capture
git -C ~/claude-code-vps diff
```

## Sunucuda

```bash
claude-vps sync
```

Pull yapar ve `apply` çalıştırır. Üzerine yazacağı her dosya önce `~/.local/state/claude-vps/backup-<timestamp>/` altına kopyalanır, değişmeyen dosyalara dokunulmaz.

Ya da kendiliğinden olsun:

```bash
claude-vps autosync on     # systemd user timer, 30 dakikada bir
claude-vps autosync        # bir sonraki çalışmayı göster
claude-vps autosync off
```

::: warning Plasma ve açık oturumlar
Plasma bazı ayarları bellekte tutar ve çıkış yaparken geri yazar. RDP ile bağlıyken bir sync gelirse, görmek için çıkış yapıp tekrar gir ve bu arada aynı ayarı sunucuda değiştirmekten kaçın.
:::

## Neler alınıyor

Liste [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/manifest.txt) içinde. Sonda eğik çizgi varsa klasörün tamamı alınır.

| Alan | Dosyalar |
| --- | --- |
| Plasma | `kdeglobals`, `kwinrc`, `kglobalshortcutsrc`, `plasmarc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kdedefaults/`, güç ve bildirim ayarları |
| Uygulamalar | `dolphinrc`, `konsolerc`, `katerc`, `~/.local/share/konsole/`, GTK tema ayarları, `mimeapps.list` |
| Görünüm | varsa `~/.local/share/color-schemes/`, `plasma/`, `aurorae/`, `wallpapers/` |
| Claude | `~/.claude/CLAUDE.md`, `settings.json`, `hooks/` |
| Shell | `.tmux.conf`, `.xsession` |

Başka bir şeyi takip etmek için manifest'e bir satır ekle. Makinende olmayan yollar atlanır.

## Neler asla alınmıyor

Ev dizini yolun `@HOME@` ile değiştirilir, böylece dosyalar her kullanıcı adıyla çalışır; son açılan dosyaları ve geçmişi tutan bölümler atılır. Kimlik bilgileri zaten listede yok: `~/.claude/.credentials.json`, `~/.claude/ntfy-topic`, SSH anahtarları, `kwalletrc`, tarayıcı profilleri. Böyle kalsın, repo herkese açık.
