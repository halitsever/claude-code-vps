---
description: "Claude Code VPS'indeki KDE Plasma masaüstüne Windows, macOS, Linux, iOS veya Android'den RDP ile doğrudan ya da SSH tüneliyle bağlan."
---

# Uzak masaüstü

Sunucu RDP üzerinden tam bir KDE Plasma oturumu çalıştırır. Bağlandığında başlar, bağlantıyı kestiğinde çalışmaya devam eder; bir sonraki sefere pencereler bıraktığın yerde durur.

## İstemciler

| Platform | İstemci |
| --- | --- |
| Windows | Remote Desktop Connection (`mstsc`), sistemle gelir |
| macOS, iOS, iPadOS | Windows App (eski adıyla Microsoft Remote Desktop) |
| Android | Windows App veya aRDP |
| Linux | Remmina, KDE'de KRDC |

`<server-ip>:53389` adresine bağlan, xrdp oturum türü sorarsa **Xorg** seç ve iş istasyonu kullanıcınla parolanla giriş yap.

## SSH tüneliyle

RDP şifreli, ama internete açık bir port yine de taranır. `--rdp-private` ile kurduysan ya da sadece böyle tercih ediyorsan tünelle:

```bash
ssh -N -L 3389:localhost:53389 dev@<server-ip>
```

Sonra RDP istemcini `localhost:3389` adresine bağla. Dışarıya SSH dışında hiçbir şey açık kalmaz.

Daha önce açtığın RDP portunu kapatmak için:

```bash
sudo ufw delete allow 53389/tcp
```

## Ekran ipuçları

- **Çözünürlük** istemci penceresini takip eder. Boyutlandır, yeniden bağlan, tamam.
- **HiDPI**: ölçeği Sistem Ayarları, Ekran bölümünden ayarla. Kullanıcı bazında kalıcıdır.
- **Yavaş bağlantı**: istemcide renk derinliğini 16 bit'e düşür ve Sistem Ayarları, Çalışma Alanı Davranışı'ndan animasyonları kapat.
- **Pano**, metin için iki yönde de hazır çalışır.

## Kullanıcı başına tek oturum

xrdp seni çalışan oturumuna geri bağlar. Aynı kullanıcıyla hem yerelde hem RDP üzerinden aynı anda giriş yapmak Plasma'da çalışmaz. Yerel ekranı olmayan bir sunucuda bu zaten hiç olmaz.
