---
title: "Что устанавливается"
description: "Все шаги claude-vps на сервере Ubuntu: пакеты, swap, защита SSH, ufw, KDE Plasma, xrdp, Docker, Chrome, Claude Code и ваши dotfiles."
---

# Что устанавливает claude-vps setup

`claude-vps setup` выполняет девять шагов по порядку. Каждый шаг это обычная bash-функция в [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh), так что вы можете прочитать, что именно запускается на сервере. Любой шаг можно пропустить через `--skip` или выполнить только нужные через `--only`.

## 1. base

- `apt upgrade` для всех пакетов
- `git curl jq ripgrep fd-find tmux htop build-essential python3` и ещё несколько пакетов
- Node.js 20 или новее. В apt на Ubuntu 24.04 есть только 18, поэтому там он ставится из репозитория NodeSource
- включается `unattended-upgrades`, чтобы обновления безопасности ставились без вашего участия
- swap-файл на 4 ГБ, если swap нет, а RAM меньше 8 ГБ. Так OOM killer не тронет Plasma и агентов
- часовой пояс, если указан `--timezone`

## 2. user

Создаёт пользователя для работы, добавляет его в группу `sudo` и копирует ему `/root/.ssh/authorized_keys`, если своих ключей у него ещё нет. Выбранный пароль вы будете вводить на экране входа RDP.

## 3. ssh

Создаёт `/etc/ssh/sshd_config.d/10-claude-vps.conf`:

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd берёт первое прочитанное значение, поэтому имя файла начинается с `10-`: он читается раньше `50-cloud-init.conf`, который есть в большинстве облачных образов. Если у вашего пользователя ещё нет SSH-ключа, шаг пропускается с предупреждением. Так вы не закроете себе доступ к серверу.

## 4. firewall

`ufw` пропускает OpenSSH и порт RDP, всё остальное закрыто. С `--rdp-private` порт RDP тоже остаётся закрытым, а подключаться нужно через SSH-туннель.

## 5. desktop

`kde-plasma-desktop` с сессией X11 (`plasma-session-x11`, `kwin-x11` в Ubuntu 25.10 и новее), а также Konsole, Dolphin, Kate, Spectacle и шрифты Noto и JetBrains Mono. SDDM отключается, а целью по умолчанию становится `multi-user`. За сервером никто не сидит, поэтому он загружается сразу в консоль, а Plasma стартует только при подключении.

::: info Почему X11
xrdp работает с сессией Xorg. В Ubuntu с 24.04 по 26.04 у Plasma 6 ещё есть сессия X11, и именно ей я пользуюсь каждый день через RDP.
:::

## 6. rdp

- `xrdp` и `xorgxrdp` на порту **53389** (меняется через `--rdp-port`)
- `~/.xsession`, который запускает `startplasma-x11` с нужными переменными `XDG_*`
- правило polkit, которое убирает запрос "authentication is required to create a color managed device". Без него он появляется при каждом входе

## 7. apps

- Docker (`docker.io`, compose v2, buildx), ваш пользователь добавляется в группу `docker`
- GitHub CLI (`gh`)
- Google Chrome из apt-репозитория Google (amd64 и arm64). Пригодится, когда Claude нужен настоящий браузер

## 8. claude

- Claude Code через официальный нативный установщик, в `~/.local/bin/claude`. Обновляется сам
- [claudegrid](https://github.com/halitsever/claudegrid) из последнего релиза `.deb`: одной командой открывает сетку агентов Claude Code в Konsole или tmux. Заодно добавляет профиль Konsole и пункт в меню приложений
- ваш топик ntfy.sh в `~/.claude/ntfy-topic`, если вы его указали. Оттуда его читает хук уведомлений

## 9. dotfiles

Передаёт `/opt/claude-vps` вашему пользователю, создаёт ссылку на `claude-vps` в `/usr/local/bin` и запускает `claude-vps apply` от вашего имени. Всё из `dotfiles/home` попадает в домашнюю папку: настройки KDE, профили Konsole, `~/.claude/settings.json`, `CLAUDE.md`, хуки и `.tmux.conf`.

## Повторный запуск

Каждый шаг сначала проверяет, что уже установлено, поэтому запускать его снова безопасно:

```bash
sudo claude-vps setup --only desktop,rdp     # например, после обновления релиза
sudo claude-vps setup --skip apps            # всё, кроме Docker и Chrome
sudo claude-vps setup --no-desktop           # сервер только с терминалом
```
