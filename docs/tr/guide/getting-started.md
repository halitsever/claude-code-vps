---
description: "claude-vps'i boş bir Ubuntu 24.04 veya 26.04 VPS'e tek komutla kur. Claude Code, RDP ile KDE Plasma ve güvenli SSH yaklaşık on dakikada hazır."
---

# Başlarken

claude-vps boş bir Ubuntu sunucusunu benim Claude Code için kullandığım makineye çevirir. Kurulum sonunda şunlar hazır olur: sudo yetkili bir kullanıcı, sadece anahtarla girilen SSH, güvenlik duvarı, RDP ile bağlandığın bir KDE Plasma masaüstü, Docker, Chrome ve Claude Code. Claude Code benim ayarlarım, hook'larım ve KDE düzenimle birlikte gelir.

## Gerekenler

| | |
| --- | --- |
| **İşletim sistemi** | Ubuntu 24.04 LTS veya daha yenisi (ben 26.04 kullanıyorum) |
| **CPU / RAM** | Plasma için en az 2 vCPU ve 4 GB. 4 vCPU / 8 GB ile gerçek bir masaüstü gibi hissettirir |
| **Disk** | 25 GB veya daha fazla |
| **Erişim** | SSH ile root erişimi. SSH anahtarının sunucuda önceden ekli olması en iyisi |
| **Mimari** | amd64'te de arm64'te de her şey kurulur |

Kurulumdan sonra Claude Code'a giriş yapmak için bir Claude Pro ya da Max planı veya bir Anthropic API anahtarı gerekir.

## Kurulum

Sunucuya root olarak (ya da sudo yetkili bir kullanıcıyla) SSH ile bağlan ve şunu çalıştır:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Script bu repoyu `/opt/claude-vps` klasörüne klonlar ve `claude-vps setup` komutunu çalıştırır. Sana iki şey sorulur: kullanıcı adı ve bu kullanıcının parolası. Parola hem sudo hem de RDP girişi için kullanılır. Parolayı boş bırakırsan bir tane üretilir ve kurulumun sonunda gösterilir.

Soruları atlamak için seçenekleri `bash -s --` sonrasına yaz:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

Bütün seçenekler [CLI referansında](/tr/reference/cli) var.

::: tip Önce dene
`--dry-run` hiçbir şey çalıştırmadan çalışacak komutları ekrana yazar.
:::

## Kurulum bitince

Şuna benzer bir özet görürsün:

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **Yeni kullanıcıyla SSH'a gir.** Root'un SSH anahtarları bu kullanıcıya kopyalandı, aynı anahtar çalışır.
2. **tmux içinde Claude Code'u başlat** ve giriş yap. Detaylar [Claude Code'u çalıştırmak](/tr/guide/claude-code) sayfasında.
3. **Masaüstünü aç.** Herhangi bir RDP istemcisi olur. Detaylar [Uzak masaüstü](/tr/guide/remote-desktop) sayfasında.

## Kendi ayarlarını kullanmak

Varsayılan kurulumda sunucuya `dotfiles/home` içindeki benim KDE ve Claude ayarlarım gelir. Kendi ayarlarını kullanmak için repoyu fork'la, kendi bilgisayarında `claude-vps capture` çalıştır, push'la ve kurulumu fork'una yönlendir:

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

Bütün süreç [Ayarları senkron tutmak](/tr/guide/sync) sayfasında anlatılıyor.
