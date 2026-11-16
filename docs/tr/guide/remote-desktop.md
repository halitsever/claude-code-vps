---
description: "Claude Code VPS'indeki KDE Plasma masaüstüne Windows, macOS, Linux, iOS veya Android'den RDP ile doğrudan ya da SSH tüneliyle bağlan."
---

# Uzak masaüstü

Sunucuda RDP ile bağlanılan tam bir KDE Plasma oturumu çalışır. Oturum sen bağlandığında başlar, bağlantıyı kestiğinde kapanmaz. Bir sonraki bağlantında pencereler bıraktığın yerde durur.

## İstemciler

| Platform | İstemci |
| --- | --- |
| Windows | Uzak Masaüstü Bağlantısı (`mstsc`), sistemle gelir |
| macOS, iOS, iPadOS | Windows App (eski adıyla Microsoft Remote Desktop) |
| Android | Windows App ya da aRDP |
| Linux | Remmina, KDE kullanıyorsan KRDC |

`<server-ip>:53389` adresine bağlan. xrdp oturum türü sorarsa **Xorg** seç ve kurulumda oluşturduğun kullanıcı adı ve parolayla giriş yap.

## SSH tüneliyle bağlanmak

RDP bağlantısı şifrelidir. Ama internete açık bir port yine de sürekli taranır. `--rdp-private` ile kurduysan ya da portu açık bırakmak istemiyorsan SSH tüneli kullan:

```bash
ssh -N -L 3389:localhost:53389 dev@<server-ip>
```

Sonra RDP istemcini `localhost:3389` adresine bağla. Bu şekilde dışarıya sadece SSH açık kalır.

Daha önce açtığın RDP portunu kapatmak için:

```bash
sudo ufw delete allow 53389/tcp
```

## Görüntü ipuçları

- **Çözünürlük** istemci penceresine göre ayarlanır. Pencereyi büyüt ya da küçült, sonra yeniden bağlan.
- **Yüksek DPI ekranlar**: Sistem Ayarları, Ekran bölümünden ölçeği ayarla. Ayar kullanıcıya özel kaydedilir.
- **Yavaş bağlantı**: İstemcinde renk derinliğini 16 bit'e düşür. Sistem Ayarları, Çalışma Alanı Davranışı bölümünden animasyonları kapat.
- **Pano** metin için iki yönde de kurulumdan hemen sonra çalışır.

## Kullanıcı başına bir oturum

xrdp seni çalışan oturumuna geri bağlar. Plasma'da aynı kullanıcıyla hem fiziksel ekrandan hem RDP'den aynı anda giriş yapılamaz. Sunucuda fiziksel ekran olmadığı için bu durumla zaten karşılaşmazsın.
