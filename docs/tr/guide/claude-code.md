---
description: "Ekransız bir sunucuda Claude Code'a giriş yap, SSH bağlantısı kopsa da tmux içinde çalışmaya devam etsin ve ntfy.sh ile telefonuna bildirim gelsin."
---

# Claude Code'u çalıştırmak

## İlk giriş

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Claude Code bir giriş linki verir. Linki kendi tarayıcında aç, onay ver ve çıkan kodu terminale yapıştır. Giriş bilgileri sunucuda `~/.claude` içinde saklanır.

API anahtarı mı kullanmak istiyorsun? Claude'u başlatmadan önce anahtarı tanımla:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

Claude Code API anahtarıyla da çalışır, ama oturumu Claude uygulamasından veya claude.ai'den yönetmeni sağlayan [Remote Control](https://code.claude.com/docs/en/remote-control) için claude.ai ile giriş yapman gerekir.

## tmux ile çalışır halde tut

Bir saattir çalışan Claude, laptopun uyku moduna geçti diye kapanmamalı. Claude'u tmux içinde çalıştır ve oturumdan ayrıl:

| | |
| --- | --- |
| Oturumdan ayrıl | `Ctrl-b`, ardından `d` |
| Geri bağlan | `tmux attach -t claude` |
| Yeni pencere | `Ctrl-b`, ardından `c` |
| Oturumları listele | `tmux ls` |

Kurulumla gelen `.tmux.conf` fare desteğini, 50 bin satırlık geçmişi ve 256 rengi açar.

Masaüstünde Konsole açıp `tmux attach -t claude` da çalıştırabilirsin. Aynı oturumu bu kez büyük ekranda görürsün.

## Telefon bildirimleri

`~/.claude/settings.json` bir `Notification` hook'u tanımlar: `~/.claude/hooks/notify.sh`. Claude senden bir cevap beklediğinde bu hook [ntfy.sh](https://ntfy.sh) üzerinden bildirim gönderir.

1. Telefonuna ntfy uygulamasını kur ve kimsenin tahmin edemeyeceği bir topic'e abone ol, örneğin `claude-7f3k9q2m`.
2. Aynı topic'i sunucuya yaz:

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   Ya da kurulum sırasında `--ntfy-topic` ile ver.

Topic adı gizli kalmalı, çünkü onu bilen herkes bildirimlerini okuyabilir. Bu yüzden ayrı bir dosyada durur ve hiçbir zaman repoya alınmaz.

## Hazır gelen ayarlar

`dotfiles/home/.claude` içinden gelenler:

- **`settings.json`**: koyu tema, tam ekran arayüz, model, klasör, git branch'i ve context kullanımını gösteren bir durum çubuğu, benim kullandığım eklentiler ve bildirim hook'u
- **`CLAUDE.md`**: kendi genel talimatların için boş bir dosya. Sadece dosya yoksa oluşturulur, yani buraya yazdıkların hiçbir zaman silinmez
- **`hooks/notify.sh`**: yukarıdaki ntfy hook'u

Bunlardan birini kendi bilgisayarında değiştirip `claude-vps publish` çalıştırman yeterli. Detaylar [Ayarları senkron tutmak](/tr/guide/sync) sayfasında.

## Claude Code'u güncellemek

Resmi kurulum kendini arka planda günceller. Hemen güncellemek istersen:

```bash
claude update
```
