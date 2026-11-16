# Sorun giderme

İlk olarak:

```bash
claude-vps doctor
```

## RDP siyah ekran gösterip bağlantıyı kesiyor

Genelde `~/.xsession` eksiktir ya da o kullanıcı için Plasma zaten çalışıyordur.

```bash
cat ~/.xsession                      # şununla bitmeli: exec startplasma-x11
loginctl list-sessions               # kullanıcının eski bir oturumu mu var? sonlandır:
loginctl terminate-user $USER
```

Loglar `~/.xsession-errors` ve `/var/log/xrdp-sesman.log` içinde.

## "Authentication is required to create a color managed device"

Bunu `rdp` adımındaki polkit kuralı halleder. Kullanıcının `users` grubunda olduğundan emin ol (`id`), sonra tekrar bağlan.

## RDP'ye hiç bağlanamıyorum

```bash
sudo ss -tlnp | grep xrdp      # 53389'u dinliyor mu?
sudo ufw status                # port açık mı?
```

Cloud sağlayıcının da sunucunun önünde kendi firewall'u olabilir.

## SSH'tan dışarıda kaldım

`ssh` adımı parola ile girişi sadece kullanıcının anahtarı varsa kapatır, ama yine de olduysa sağlayıcının web konsolunu kullan, sonra:

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

Native installer onu `~/.local/bin` altına koyar. Ubuntu bu klasörü, klasör var olduğu sürece girişte `PATH`'e ekler; çıkış yapıp tekrar gir ya da `source ~/.profile` çalıştır.

## `claude-vps sync` "Not possible to fast-forward" diyor

Sunucudaki klonda yerel değişiklikler var. Sunucunun sadece pull yapması gerekiyor:

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## Eski bir dosyayı geri yüklemek

Her `apply` üzerine yazdığı dosyaların yedeğini alır:

```bash
ls ~/.local/state/claude-vps/
```
