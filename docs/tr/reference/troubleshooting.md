---
description: "Claude Code VPS'inde sık görülen sorunların çözümü: RDP'de siyah ekran, xrdp renk profili sorusu, SSH'a girememek, claude bulunamadı ve sync hataları."
---

# Sorun giderme

İlk olarak şunu çalıştır:

```bash
claude-vps doctor
```

## RDP siyah ekran gösterip bağlantıyı kesiyor

Genelde ya `~/.xsession` dosyası yoktur ya da o kullanıcı için Plasma zaten çalışıyordur.

```bash
cat ~/.xsession                      # son satır şu olmalı: exec startplasma-x11
loginctl list-sessions               # kullanıcının eski bir oturumu var mı? varsa kapat:
loginctl terminate-user $USER
```

Loglar `~/.xsession-errors` ve `/var/log/xrdp-sesman.log` dosyalarında.

## "Authentication is required to create a color managed device"

Bu soruyu `rdp` adımındaki polkit kuralı engeller. Kullanıcının `users` grubunda olduğunu kontrol et (`id`), sonra yeniden bağlan.

## RDP'ye hiç bağlanamıyorum

```bash
sudo ss -tlnp | grep xrdp      # 53389 portunu dinliyor mu?
sudo ufw status                # porta izin verilmiş mi?
```

Bulut sağlayıcının sunucunun önünde ayrı bir güvenlik duvarı da olabilir. Onun ayarlarına da bak.

## SSH'a giremiyorum

`ssh` adımı parolayla girişi sadece kullanıcının bir anahtarı varsa kapatır. Yine de dışarıda kaldıysan sağlayıcının web konsolundan gir ve şunu çalıştır:

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

Resmi kurulum Claude'u `~/.local/bin` içine koyar. Ubuntu bu klasörü, klasör varsa girişte `PATH`'e ekler. Çıkıp tekrar gir ya da `source ~/.profile` çalıştır.

## `claude-vps sync` "Not possible to fast-forward" diyor

Sunucudaki repoda yerel değişiklikler var. Sunucu sadece çekmeli, kendisi değişiklik yapmamalı:

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## Eski bir dosyayı geri almak

Her `apply` üzerine yazdığı dosyaları yedekler:

```bash
ls ~/.local/state/claude-vps/
```
