---
title: "Claude Code'u VPS'te çalıştırma rehberi"
description: "Claude Code'u Ubuntu VPS'te adım adım kurma rehberi. Güvenli SSH, hiç kapanmayan tmux oturumları, telefon bildirimleri ve RDP ile KDE Plasma masaüstü."
---

# Claude Code'u VPS'te çalıştırma rehberi

Bu, kendi kurulumumun elle yapılan tam hali: Claude Code'u 7/24 çalıştıran ucuz bir Ubuntu sunucu. Her yerden SSH ile bağlanıyorum, gerçek bir ekran istediğimde de RDP üzerinden KDE Plasma masaüstüne giriyorum.

Aşağıdaki her komut, [`claude-vps setup`](/tr/guide/getting-started) komutunun senin yerine çalıştırdığı şeyler. Bu sayfayı ne olup bittiğini anlamak ya da her şeyi elle yapmak için oku.

## Claude Code'u neden VPS'te çalıştırmalı

- **Laptopun uyusa da çalışmaya devam eder.** Uzun refactor'lar, test koşuları ve migration'lar sen yokken biter.
- **Kendi makinen temiz kalır.** Ajanlar paket kurar, Docker çalıştırır, dev sunucuları ayağa kaldırır. Hepsi on dakikada silip yeniden kurabileceğin bir makinede olur.
- **Her yerde aynı ortam.** Laptop, masaüstü, tablet ya da telefon: hepsinden aynı tmux oturumuna ve aynı masaüstüne bağlanırsın.
- **Hızlı ağ**, git sunucuna ve paket depolarına yakın.

## Sunucu seç

| Kullanım | vCPU | RAM | Disk |
| --- | --- | --- | --- |
| Sadece terminal | 2 | 4 GB | 40 GB |
| KDE masaüstüyle | 4 | 8 GB | 80 GB |
| Birden fazla ajan artı Docker | 8 | 16 GB | 160 GB |

Ubuntu 24.04 LTS veya daha yenisini sunan her sağlayıcı olur: Hetzner, DigitalOcean, OVH, Vultr, Linode, AWS Lightsail ya da evdeki boş bir makine. RDP daha akıcı olsun diye sana yakın bir bölge seç. Sunucuyu oluştururken SSH public key'ini ekle, böylece hiç root parolasına ihtiyacın olmaz.

## 1. İlk giriş ve güncellemeler

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades` güvenlik yamalarını kendisi kurar. Sürekli internete açık bir makinede bu önemli.

Küçük sunuculara swap ekle ki yoğun çalışan bir ajan OOM killer'ı tetiklemesin:

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. Kullanıcını oluştur

Claude Code'u root olarak çalıştırma. Sudo yetkisi olan normal bir kullanıcı aç:

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

Devam etmeden önce ikinci bir terminal aç ve `ssh dev@<server-ip>` komutunun çalıştığından emin ol.

## 3. SSH'ı kilitle

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd okuduğu ilk değeri kullanır ve dosyalar isim sırasıyla yüklenir. Dosya adının `10-` ile başlamasının sebebi bu: birçok cloud imajının `PasswordAuthentication yes` ile gelen `50-cloud-init.conf` dosyasından önce okunması gerekiyor.

## 4. Firewall

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # sadece internetten RDP istiyorsan, aşağıya bak
ufw --force enable
```

## 5. Claude Code'u kur

Kendi kullanıcınla giriş yap ve native installer'ı kullan. Node.js gerektirmez ve kendini günceller:

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

`~/.local/bin/claude` konumuna kurulur. O klasörün `PATH`'e girmesi için bir kez çıkış yapıp tekrar gir, sonra kontrol et:

```bash
claude --version
```

## 6. Ekransız sunucuda giriş yapmak

Sunucuda tarayıcı yok, olmasına da gerek yok:

```bash
claude
```

Claude Code bir URL yazdırır. Onu kendi bilgisayarında ya da telefonunda aç, onayla ve kodu terminale geri yapıştır. Oturum sunucuda `~/.claude` altında saklanır.

Pro veya Max planı yerine Anthropic API key'i kullanıyorsan shell profiline ekle:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## 7. Oturumları tmux ile canlı tut

Claude doğrudan SSH oturumunda çalışıyorsa laptopun kapağını kapatmak onu öldürür. tmux içinde çalıştır:

```bash
tmux new -s claude
claude
# Ctrl-b, sonra d ile ayrıl, ajan çalışmaya devam eder
tmux attach -t claude   # sonra, herhangi bir cihazdan
```

Küçük bir `~/.tmux.conf` işi kolaylaştırır:

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Claude seni beklediğinde haber al

Claude Code senden girdi beklerken bir `Notification` hook'u tetikler. Bunu [ntfy.sh](https://ntfy.sh) ile telefonuna yolla:

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude seni bekliyor"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
EOF
chmod +x ~/.claude/hooks/notify.sh
echo my-hard-to-guess-topic > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
```

`~/.claude/settings.json` içine kaydet:

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

ntfy uygulamasında aynı topic'e abone ol. Topic'e parola gibi davran.

## 9. İsteğe bağlı: RDP ile KDE Plasma masaüstü

İşin çoğunu terminal karşılar. Masaüstü, ajanın yanında Chrome açmak, bir dosya yöneticisi kullanmak ya da büyük ekranda birkaç Konsole penceresi görmek istediğinde işe yarar.

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

Ubuntu 24.04'te `plasma-session-x11` ve `kwin-x11` ayrı paket olarak yok. Onları çıkar.

xrdp'ye kullanıcın için Plasma'yı başlatmasını söyle:

```bash
cat > ~/.xsession <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
sudo systemctl restart xrdp
```

Sonra her girişte çıkan renk profili parola sorusunu kapat:

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

Herhangi bir RDP istemcisiyle `<server-ip>:53389` adresine bağlan. Portu kapalı tutup SSH tüneliyle bağlanmak dahil ayrıntılar [Uzak masaüstü](/tr/guide/remote-desktop) sayfasında.

## 10. Geliştirici araçları

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## Güvenlik kontrol listesi

- SSH sadece anahtarla, root'a parola ile giriş kapalı
- Firewall açık, sadece ihtiyacın olan portlar
- Claude Code root olarak değil, normal kullanıcıyla çalışıyor
- `--dangerously-skip-permissions` sadece atılabilir container'larda, token'larının ve SSH anahtarlarının olduğu bir makinede asla
- Secret'lar (`~/.claude/.credentials.json`, API key'ler, ntfy topic'i) asla public bir repoya girmiyor
- Unattended upgrades açık

## Hepsini tek komutla yap

Yukarıdaki her şeyi, artı kendi KDE ve Claude ayarlarını uygulamayı claude-vps otomatikleştiriyor:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

[Başlarken](/tr/guide/getting-started) sayfasına bak.

## SSS

### Claude Code arayüzü olmayan bir sunucuda çalışır mı?

Evet. Terminal uygulaması. Giriş, başka herhangi bir cihazda açtığın bir link üzerinden yapılıyor.

### Hangi Claude planı gerekiyor?

Claude Code içeren herhangi bir plan (Pro veya Max) ya da kullanım başına ücretlendirilen bir Anthropic API key'i.

### Claude Code VPS'i ne kadara mal olur?

Uygun fiyatlı sağlayıcılarda 4 ila 8 GB RAM'li bir sunucu genelde ayda 5 ila 20 USD. Claude kullanımı planına ya da API key'ine göre ayrıca ücretlendirilir.

### SSH'ı kapatınca Claude çalışmaya devam eder mi?

Sadece tmux (ya da screen) içindeyse. `tmux new -s claude` ile başlat, `Ctrl-b d` ile ayrıl.

### Güvenli mi?

Kendi yönettiğin herhangi bir sunucu kadar güvenli. Yukarıdaki kontrol listesini uygula ve ajanı ihtiyacı olmayan kimlik bilgilerinden uzak tut.
