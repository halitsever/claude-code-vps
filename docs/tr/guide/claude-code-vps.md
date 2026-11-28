---
title: "Claude Code VPS'te nasıl çalıştırılır"
description: "Claude Code'u Ubuntu VPS'te adım adım çalıştırma rehberi: güvenli SSH, kapanmayan tmux oturumları, telefon bildirimleri ve RDP ile KDE Plasma masaüstü."
---

# Claude Code VPS'te nasıl çalıştırılır

Bu sayfa kendi kurulumumun elle yapılan hali. Ucuz bir Ubuntu sunucusunda Claude Code gece gündüz çalışıyor. Her yerden SSH ile bağlanıyorum. Ekran gerektiğinde de RDP ile KDE Plasma masaüstüne giriyorum.

Aşağıdaki komutların hepsini [`claude-vps setup`](/tr/guide/getting-started) senin için çalıştırır. Bu sayfayı, kurulumun ne yaptığını anlamak ya da her şeyi elle yapmak için okuyabilirsin.

## Claude Code'u neden VPS'te çalıştırmalı

- **Laptop uyku moduna geçse de iş devam eder.** Uzun refactor'lar, testler ve migration'lar sen başında değilken biter.
- **Kendi bilgisayarın temiz kalır.** Claude paket kurar, Docker çalıştırır, geliştirme sunucuları açar. Bunların hepsi on dakikada silip yeniden kurabileceğin bir sunucuda olur.
- **Her cihazdan aynı ortam.** Laptop, masaüstü, tablet ya da telefon fark etmez. Hepsinden aynı tmux oturumuna ve aynı masaüstüne bağlanırsın.
- **İnternet hızlıdır.** Sunucu, GitHub'a ve paket depolarına senin evinden daha yakındır.

## Sunucu seçimi

| Kullanım | vCPU | RAM | Disk |
| --- | --- | --- | --- |
| Sadece terminal | 2 | 4 GB | 40 GB |
| KDE masaüstüyle | 4 | 8 GB | 80 GB |
| Birden fazla Claude ve Docker | 8 | 16 GB | 160 GB |

Ubuntu 24.04 LTS veya daha yenisini sunan her sağlayıcı olur: Hetzner, DigitalOcean, OVH, Vultr, Linode, AWS Lightsail ya da evde boşta duran bir bilgisayar. RDP'nin akıcı olması için sana yakın bir bölge seç. Sunucuyu oluştururken SSH public key'ini ekle, böylece root parolasına hiç ihtiyacın olmaz.

## 1. İlk giriş ve güncellemeler

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades` güvenlik yamalarını kendisi kurar. Sürekli internete açık bir sunucuda bu önemli.

Küçük sunuculara swap ekle. Böylece Claude yoğun çalışırken bellek dolup OOM killer süreçleri öldürmez:

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. Kullanıcı oluştur

Claude Code'u root olarak çalıştırma. Ona sudo yetkili normal bir kullanıcı aç:

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

Devam etmeden önce ikinci bir terminal aç ve `ssh dev@<server-ip>` ile girebildiğini kontrol et.

## 3. SSH'ı güvenli hale getir

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd bir ayar için okuduğu ilk değeri kullanır ve dosyaları isim sırasına göre yükler. Dosya adının `10-` ile başlaması bu yüzden. Birçok bulut imajında `PasswordAuthentication yes` içeren bir `50-cloud-init.conf` gelir, bizim dosyamızın ondan önce okunması gerekir.

## 4. Güvenlik duvarı

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # RDP'ye internetten bağlanacaksan gerekli, aşağıya bak
ufw --force enable
```

## 5. Claude Code'u kur

Kendi kullanıcınla giriş yap ve resmi kurulum script'ini kullan. Node.js gerektirmez ve kendini otomatik günceller:

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

Claude `~/.local/bin/claude` konumuna kurulur. Bu klasörün `PATH`'e eklenmesi için bir kere çıkıp tekrar gir, sonra kontrol et:

```bash
claude --version
```

## 6. Ekransız sunucuda giriş yapmak

Sunucuda tarayıcı yok, zaten gerek de yok:

```bash
claude
```

Claude Code bir link verir. Bu linki kendi bilgisayarında ya da telefonunda aç, onay ver ve çıkan kodu terminale yapıştır. Oturum bilgisi sunucuda `~/.claude` içinde saklanır.

Pro veya Max planı yerine Anthropic API anahtarı kullanıyorsan anahtarı shell profiline ekle:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

Claude Code API anahtarıyla da çalışır, ama oturumu Claude uygulamasından veya claude.ai'den yönetmeni sağlayan [Remote Control](https://code.claude.com/docs/en/remote-control) için claude.ai ile giriş yapman gerekir.

## 7. tmux ile oturumu açık tut

Claude doğrudan SSH oturumunda çalışırsa laptopun kapağını kapattığında o da kapanır. Bu yüzden tmux içinde çalıştır:

```bash
tmux new -s claude
claude
# Ctrl-b, ardından d ile oturumdan ayrıl, Claude çalışmaya devam eder
tmux attach -t claude   # sonra istediğin cihazdan geri bağlan
```

Kısa bir `~/.tmux.conf` kullanımı rahatlatır:

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Claude seni beklediğinde bildirim al

Claude Code bir girdi beklediğinde `Notification` hook'unu tetikler. Bu bildirimi [ntfy.sh](https://ntfy.sh) ile telefonuna gönderebilirsin:

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude cevabını bekliyor"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
EOF
chmod +x ~/.claude/hooks/notify.sh
echo my-hard-to-guess-topic > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
```

Hook'u `~/.claude/settings.json` dosyasına ekle:

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

Telefondaki ntfy uygulamasında aynı topic'e abone ol. Topic adını parola gibi sakla, bilen herkes bildirimlerini okuyabilir.

## 9. İsteğe bağlı: RDP ile KDE Plasma masaüstü

İşin çoğu terminalde biter. Masaüstü ise Claude'un yanında Chrome açmak, dosya yöneticisi kullanmak ya da büyük ekranda birkaç Konsole penceresiyle çalışmak istediğinde işe yarar.

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

Ubuntu 24.04'te `plasma-session-x11` ve `kwin-x11` ayrı paket olarak yok. Bu sürümdeysen ikisini komuttan çıkar.

xrdp'ye senin kullanıcın için Plasma'yı başlatmasını söyle:

```bash
cat > ~/.xsession <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
sudo systemctl restart xrdp
```

Sonra renk profilleri için her girişte çıkan parola sorusunu kapat:

```bash
sudo tee /etc/polkit-1/rules.d/45-colord.rules >/dev/null <<'EOF'
polkit.addRule(function (action, subject) {
  if (action.id.indexOf("org.freedesktop.color-manager.") === 0 && subject.isInGroup("users")) {
    return polkit.Result.YES;
  }
});
EOF
sudo usermod -aG users dev
```

Herhangi bir RDP istemcisiyle `<server-ip>:53389` adresine bağlan. Portu kapalı tutup SSH tüneli üzerinden bağlanmak dahil, detaylar [Uzak masaüstü](/tr/guide/remote-desktop) sayfasında.

## 10. Geliştirme araçları

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## Güvenlik kontrol listesi

- SSH'a sadece anahtarla girilir, root'a parolayla giriş kapalı
- Güvenlik duvarı açık, sadece gereken portlara izin var
- Claude Code root değil, normal bir kullanıcıyla çalışıyor
- `--dangerously-skip-permissions` sadece silinip atılacak container'larda kullanılır. Token'larının ve SSH anahtarlarının durduğu bir makinede asla
- Gizli bilgiler (`~/.claude/.credentials.json`, API anahtarları, ntfy topic'i) hiçbir zaman açık bir repoya girmez
- Otomatik güvenlik güncellemeleri açık

## Hepsini tek komutla yap

Yukarıdaki her şeyi ve kendi KDE ve Claude ayarlarını uygulamayı claude-vps otomatik yapar:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Detaylar için [Başlarken](/tr/guide/getting-started) sayfasına bak.

## Sık sorulanlar

### Claude Code ekranı olmayan bir sunucuda çalışır mı?

Evet, çünkü Claude Code bir terminal uygulaması. Giriş için başka bir cihazda açtığın bir link yeterli.

### Hangi Claude planı gerekiyor?

Claude Code içeren bir plan (Pro ya da Max) veya kullandıkça ödediğin bir Anthropic API anahtarı.

### Claude Code için VPS'e ne kadar ödenir?

Uygun fiyatlı sağlayıcılarda 4 ile 8 GB RAM'li bir sunucu genelde ayda 5 ile 20 USD arası. Claude kullanımı planından ya da API anahtarından ayrıca ücretlendirilir.

### SSH bağlantısını kapatınca Claude çalışmaya devam eder mi?

Sadece tmux (ya da screen) içinde çalışıyorsa. `tmux new -s claude` ile başlat, `Ctrl-b d` ile oturumdan ayrıl.

### Güvenli mi?

Kendi yönettiğin her sunucu kadar güvenli. Yukarıdaki kontrol listesini uygula ve Claude'u ihtiyacı olmayan gizli bilgilerden uzak tut.
