---
title: "Neler kuruluyor"
description: "claude-vps'in Ubuntu sunucunda çalıştırdığı her adım: paketler, swap, SSH ayarları, ufw, KDE Plasma, xrdp, Docker, Chrome, Claude Code ve dotfiles."
---

# claude-vps setup neleri kuruyor

`claude-vps setup` dokuz adımı sırayla çalıştırır. Her adım [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh) içinde düz bir bash fonksiyonu. Sunucunda tam olarak neyin çalıştığını oradan okuyabilirsin. İstediğin adımı `--skip` ile atlayabilir, `--only` ile sadece bazılarını çalıştırabilirsin.

## 1. base

- Bütün paketlere `apt upgrade`
- `git curl jq ripgrep fd-find tmux htop build-essential python3` ve benzeri araçlar
- Node.js 20 veya üstü. Ubuntu 24.04'te apt sadece 18 sürümünü verdiği için orada NodeSource deposundan kurulur
- `unattended-upgrades` açılır, güvenlik yamaları sen uğraşmadan kurulur
- Sunucuda swap yoksa ve RAM 8 GB'tan azsa 4 GB'lık bir swap dosyası. Böylece Plasma ve birkaç Claude birlikte çalışırken bellek dolup OOM killer devreye girmez
- `--timezone` verdiysen saat dilimi

## 2. user

Kullanıcını oluşturur ve `sudo` grubuna ekler. Kullanıcının SSH anahtarı yoksa `/root/.ssh/authorized_keys` dosyasını ona kopyalar. Burada seçtiğin parolayı RDP giriş ekranında kullanırsın.

## 3. ssh

`/etc/ssh/sshd_config.d/10-claude-vps.conf` dosyasını yazar:

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd bir ayar için okuduğu ilk değeri kullanır. Dosya adının `10-` ile başlaması bu yüzden: çoğu bulut imajıyla gelen `50-cloud-init.conf` dosyasından önce okunur. Kullanıcının henüz SSH anahtarı yoksa bu adım bir uyarıyla atlanır, böylece sunucuya erişimini kaybetmezsin.

## 4. firewall

`ufw` açılır. Sadece OpenSSH ve RDP portuna izin verilir, geri kalan her şey kapalıdır. RDP portunu kapalı tutup SSH tüneliyle bağlanmak istersen `--rdp-private` kullan.

## 5. desktop

`kde-plasma-desktop` ve X11 oturumu (Ubuntu 25.10 ve üstünde `plasma-session-x11` ile `kwin-x11`), Konsole, Dolphin, Kate, Spectacle, Noto ve JetBrains Mono fontları kurulur. SDDM kapatılır ve varsayılan hedef `multi-user` yapılır. Sunucunun başında kimse oturmadığı için giriş ekranına gerek yok. Sunucu doğrudan konsola açılır, Plasma sadece sen bağlandığında başlar.

::: info Neden X11
xrdp bir Xorg oturumu çalıştırır. Plasma 6, Ubuntu 24.04 ile 26.04 arasında hâlâ X11 oturumuyla geliyor. Ben de RDP üzerinden her gün bunu kullanıyorum.
:::

## 6. rdp

- `xrdp` ve `xorgxrdp`, **53389** portunda dinler (`--rdp-port` ile değiştirilebilir)
- Doğru `XDG_*` değişkenleriyle `startplasma-x11` başlatan bir `~/.xsession`
- Bir polkit kuralı. Bu kural olmadan her girişte "authentication is required to create a color managed device" diye parola soran bir pencere çıkar

## 7. apps

- Docker (`docker.io`, compose v2, buildx). Kullanıcın `docker` grubuna eklenir
- GitHub CLI (`gh`)
- Google'ın apt deposundan Google Chrome (amd64 ve arm64). Claude'un gerçek bir tarayıcıya ihtiyacı olduğunda işe yarar

## 8. claude

- Claude Code, resmi kurulum script'iyle `~/.local/bin/claude` konumuna kurulur. Kendini otomatik günceller
- [claudegrid](https://github.com/halitsever/claudegrid), son `.deb` sürümünden kurulur. Tek komutla Konsole ya da tmux içinde bir Claude Code ajanı ızgarası açar. Bir Konsole profili ve uygulama menüsü kaydı da ekler
- ntfy.sh topic'i verdiysen `~/.claude/ntfy-topic` dosyasına yazılır. Bildirim hook'u topic'i buradan okur

## 9. dotfiles

`/opt/claude-vps` klasörünün sahipliğini senin kullanıcına verir, `claude-vps` komutunu `/usr/local/bin` altına linkler ve `claude-vps apply` komutunu senin kullanıcınla çalıştırır. Bu komut `dotfiles/home` altındaki her şeyi ev klasörüne yazar: KDE ayarları, Konsole profilleri, `~/.claude/settings.json`, `CLAUDE.md`, hook'lar ve `.tmux.conf`.

## Adımları tekrar çalıştırmak

Her adım önce neyin zaten kurulu olduğuna bakar. Bu yüzden tekrar çalıştırmak güvenli:

```bash
sudo claude-vps setup --only desktop,rdp     # örneğin Ubuntu sürüm yükseltmesinden sonra
sudo claude-vps setup --skip apps            # Docker ve Chrome hariç her şey
sudo claude-vps setup --no-desktop           # sadece terminal kullanılacak sunucu
```
