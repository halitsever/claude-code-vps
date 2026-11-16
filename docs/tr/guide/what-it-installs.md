# Neler kuruluyor

`claude-vps setup` dokuz adımı sırayla çalıştırır. Her biri [`lib/setup.sh`](https://github.com/halitsever/claude-vps/blob/main/lib/setup.sh) içinde düz bir bash fonksiyonu, yani sunucunda tam olarak neyin çalıştığını okuyabilirsin. İstediğini `--skip` ile atla ya da birkaçını `--only` ile çalıştır.

## 1. base

- her şeye `apt upgrade`
- `git curl jq ripgrep fd-find tmux htop build-essential nodejs npm python3` ve benzerleri
- `unattended-upgrades` açık, güvenlik yamaları sen uğraşmadan gelir
- sunucuda swap yoksa ve RAM 8 GB'tan azsa 4 GB'lık bir swapfile; Plasma ve birkaç ajan aynı anda çalışırken OOM killer'a takılmamak için
- `--timezone` verdiysen saat dilimi

## 2. user

İş istasyonu kullanıcını oluşturur, `sudo` grubuna ekler ve hiç anahtarı yoksa `/root/.ssh/authorized_keys` dosyasını ona kopyalar. Seçtiğin parola, RDP giriş ekranında yazacağın paroladır.

## 3. ssh

`/etc/ssh/sshd_config.d/10-claude-vps.conf` dosyasını yazar:

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd okuduğu ilk değeri kullanır, dosya adının `10-` ile başlaması bu yüzden: çoğu cloud imajının getirdiği `50-cloud-init.conf` dosyasının önüne geçer. Kullanıcının henüz SSH anahtarı yoksa bu adım bir uyarıyla atlanır, böylece kendini dışarıda bırakmazsın.

## 4. firewall

OpenSSH ve RDP portuna izin veren, geri kalan her şeyi kapatan `ufw`. RDP'yi kapalı tutup SSH tüneliyle erişmek istersen `--rdp-private` ver.

## 5. desktop

`kde-plasma-desktop` ile birlikte X11 oturumu (Ubuntu 25.10+ için `plasma-session-x11`, `kwin-x11`), Konsole, Dolphin, Kate, Spectacle, Noto ve JetBrains Mono fontları. SDDM kapatılır ve varsayılan hedef `multi-user` yapılır: sunucunun başında kimse oturmuyor, bu yüzden doğrudan konsola açılır ve Plasma sadece sen bağlandığında başlar.

::: info Neden X11
xrdp bir Xorg oturumu yönetir. Plasma 6, Ubuntu 24.04 ile 26.04 arasında hâlâ X11 oturumuyla geliyor ve RDP üzerinden her gün kullandığım da bu.
:::

## 6. rdp

- **53389** portunu dinleyen `xrdp` ve `xorgxrdp` (`--rdp-port` ile değiştirilebilir)
- doğru `XDG_*` değişkenleriyle `startplasma-x11` başlatan bir `~/.xsession`
- her girişte çıkan "authentication is required to create a color managed device" penceresini engelleyen bir polkit kuralı

## 7. apps

- Docker (`docker.io`, compose v2, buildx), kullanıcın `docker` grubunda
- GitHub CLI (`gh`)
- Google'ın apt reposundan Google Chrome (sadece amd64), Claude'un gerçek bir tarayıcıya ihtiyaç duyduğu işler için

## 8. claude

- Resmi native installer ile `~/.local/bin/claude` altına Claude Code. Kendini kendisi günceller
- ntfy.sh topic'i verdiysen `~/.claude/ntfy-topic` içinde; notify hook'u buradan okur

## 9. dotfiles

`/opt/claude-vps` klasörünü kullanıcına devreder, `claude-vps` komutunu `/usr/local/bin` altına linkler ve senin kullanıcınla `claude-vps apply` çalıştırır. Bu da `dotfiles/home` altındaki her şeyi ev dizinine yazar: KDE ayarları, Konsole profilleri, `~/.claude/settings.json`, `CLAUDE.md`, hook'lar, `.tmux.conf`.

## Adımları tekrar çalıştırmak

Her adım önce neyin kurulu olduğuna bakar, tekrar çalıştırmak güvenli:

```bash
sudo claude-vps setup --only desktop,rdp     # örn. sürüm yükseltmesinden sonra
sudo claude-vps setup --skip apps            # Docker ve Chrome hariç her şey
sudo claude-vps setup --no-desktop           # sadece terminal kullanılan sunucu
```
