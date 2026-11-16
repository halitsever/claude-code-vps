---
description: "Частые проблемы Claude Code на VPS: чёрный экран RDP, запросы цветовых профилей, потерянный доступ по SSH, claude не найден и ошибки синхронизации."
---

# Решение проблем

Начните с этого:

```bash
claude-vps doctor
```

## RDP показывает чёрный экран и отключается

Обычно нет файла `~/.xsession` или Plasma у этого пользователя уже запущена.

```bash
cat ~/.xsession                      # последняя строка должна быть: exec startplasma-x11
loginctl list-sessions               # есть старая сессия вашего пользователя? Завершите её:
loginctl terminate-user $USER
```

Логи лежат в `~/.xsession-errors` и `/var/log/xrdp-sesman.log`.

## "Authentication is required to create a color managed device"

Это решает правило polkit из шага `rdp`. Проверьте командой `id`, что ваш пользователь в группе `users`, и переподключитесь.

## К RDP вообще не подключиться

```bash
sudo ss -tlnp | grep xrdp      # слушает ли xrdp порт 53389?
sudo ufw status                # открыт ли порт?
```

У облачного провайдера может быть и свой файрвол перед сервером.

## Нет доступа по SSH

Шаг `ssh` отключает вход по паролю, только если у пользователя есть ключ. Если доступ всё же пропал, зайдите через веб-консоль провайдера и выполните:

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

Нативный установщик кладёт программу в `~/.local/bin`. Ubuntu добавляет эту папку в `PATH` при входе, если она существует. Выйдите и зайдите снова или выполните `source ~/.profile`.

## `claude-vps sync` пишет "Not possible to fast-forward"

В клоне на сервере есть локальные изменения. А сервер должен только получать изменения:

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## Как вернуть старый файл

Каждый `apply` сохраняет копии файлов, которые перезаписывает:

```bash
ls ~/.local/state/claude-vps/
```
