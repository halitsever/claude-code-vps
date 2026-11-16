---
description: "Ekransız bir sunucuda Claude Code'a giriş yap, SSH kopsa da ajanları tmux'ta çalışır tut ve ntfy.sh ile telefonuna bildirim al."
---

# Claude Code'u çalıştırmak

## İlk giriş

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Claude Code bir giriş linki yazar. Linki kendi tarayıcında aç, onayla ve kodu geri yapıştır. Kimlik bilgileri sunucuda `~/.claude` altında kalır.

API anahtarı mı tercih ediyorsun? Başlatmadan önce export et:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## tmux ile açık tut

Bir saat boyunca çalışan bir ajan, laptopun uykuya geçti diye ölmemeli. tmux içinde çalıştır ve detach et:

| | |
| --- | --- |
| Detach | `Ctrl-b` sonra `d` |
| Tekrar bağlan | `tmux attach -t claude` |
| Yeni pencere | `Ctrl-b` sonra `c` |
| Oturumları listele | `tmux ls` |

Gelen `.tmux.conf` mouse desteğini, 50 bin satırlık scrollback'i ve 256 rengi açar.

Masaüstünde Konsole'u açıp orada da `tmux attach -t claude` çalıştırabilirsin. Aynı oturum, daha büyük ekran.

## Telefon bildirimleri

`~/.claude/settings.json` bir `Notification` hook'u kaydeder: `~/.claude/hooks/notify.sh`. Claude seni beklediğinde [ntfy.sh](https://ntfy.sh)'e mesaj atar.

1. Telefonuna ntfy uygulamasını kur ve kimsenin tahmin edemeyeceği bir topic'e abone ol, örn. `claude-7f3k9q2m`.
2. Aynı topic'i sunucuya yaz:

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   Ya da kurulum sırasında `--ntfy-topic` ver.

Topic bir sır: bilen herkes bildirimlerini okuyabilir. Bu yüzden ayrı bir dosyada duruyor ve hiçbir zaman repoya alınmıyor.

## Hazır gelen ayarlar

`dotfiles/home/.claude` içinden:

- **`settings.json`**: koyu tema, tam ekran TUI, model, klasör, git branch ve context kullanımını gösteren bir status line, kullandığım plugin'ler ve notify hook'u
- **`CLAUDE.md`**: kendi global talimatların için boş bir dosya. Sadece yoksa oluşturulur, içine yazdıkların asla ezilmez
- **`hooks/notify.sh`**: yukarıdaki ntfy hook'u

Bunlardan herhangi birini kendi makinende değiştir ve `claude-vps publish` çalıştır. Bkz. [Config senkronizasyonu](/tr/guide/sync).

## Claude Code'u güncellemek

Native kurulum arka planda kendini günceller. Elle tetiklemek için:

```bash
claude update
```
