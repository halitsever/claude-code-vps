---
description: "claude-vps'i tek komutla temiz bir Ubuntu 24.04 veya 26.04 VPS'e kur. Yaklaşık on dakikada Claude Code, RDP üzerinden KDE Plasma ve güvenli SSH hazır."
---

# Başlarken

claude-vps, temiz bir Ubuntu sunucuyu Claude Code'u çalıştırdığım makineye çevirir: sudo yetkili bir kullanıcı, sadece anahtarla SSH, firewall, RDP ile bağlandığın bir KDE Plasma masaüstü, Docker, Chrome ve ayarları, hook'ları ve KDE düzeniyle birlikte Claude Code'un kendisi.

## Gerekenler

| | |
| --- | --- |
| **İşletim sistemi** | Ubuntu 24.04 LTS veya üstü (ben 26.04 kullanıyorum) |
| **CPU / RAM** | Plasma için en az 2 vCPU ve 4 GB. 4 vCPU / 8 GB gerçek bir masaüstü gibi hissettirir |
| **Disk** | 25 GB veya fazlası |
| **Erişim** | SSH ile root erişimi, tercihen SSH anahtarın sunucuda hazır |
| **Mimari** | amd64'te her şey kurulur. arm64 çalışır ama Chrome atlanır |

Sonrasında Claude Code'a giriş yapmak için bir Claude Pro veya Max planı ya da Anthropic API anahtarı.

## Kurulum

Sunucuya root (veya sudo yetkili bir kullanıcı) olarak SSH ile bağlan ve şunu çalıştır:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Bu komut repoyu `/opt/claude-vps` altına klonlar ve `claude-vps setup` çalıştırır. Sana iki şey sorulur: iş istasyonu için kullanıcı adı ve bu kullanıcının parolası (sudo ve RDP girişi için). Parolayı boş bırakırsan bir tane üretilir ve sonda gösterilir.

Soruları atlamak için seçenekleri `bash -s --` sonrasına yaz:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

Bütün seçenekler [CLI referansında](/tr/reference/cli).

::: tip Önce dene
`--dry-run` her komutu çalıştırmadan ekrana yazar.
:::

## Bittiğinde

Şöyle bir özet görürsün:

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **Yeni kullanıcıyla SSH ile bağlan.** Root'un SSH anahtarları kopyalandı, aynı anahtar çalışır.
2. **Claude Code'u tmux içinde başlat** ve giriş yap. Bkz. [Claude Code'u çalıştırmak](/tr/guide/claude-code).
3. **Masaüstünü aç**, herhangi bir RDP istemcisiyle. Bkz. [Uzak masaüstü](/tr/guide/remote-desktop).

## Kendi ayarlarını kullanmak

Varsayılan olarak sunucu `dotfiles/home` altındaki benim KDE ve Claude ayarlarımı alır. Kendi ayarlarını kullanmak için repoyu fork'la, kendi makinende `claude-vps capture` çalıştır, push'la ve kurulumu fork'una yönlendir:

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

Döngünün tamamı [Config senkronizasyonu](/tr/guide/sync) sayfasında.
