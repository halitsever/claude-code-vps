---
title: "Синхронизация настроек"
description: "Синхронизация настроек KDE Plasma и Claude Code между вашим компьютером и VPS с помощью claude-vps publish, sync и autosync."
---

# Синхронизация настроек между компьютером и сервером

Всё, что определяет вид и поведение сервера, хранится в репозитории. Вы меняете что-то на своём компьютере, а сервер подтягивает изменения.

```text
 ваш компьютер                 GitHub                     сервер
 ─────────────                 ──────                     ──────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (или autosync, каждые 30 мин)
```

## На вашем компьютере

Один раз клонируйте репозиторий и добавьте CLI в PATH:

```bash
git clone https://github.com/halitsever/claude-code-vps.git ~/claude-code-vps
ln -s ~/claude-code-vps/bin/claude-vps ~/.local/bin/claude-vps
```

Изменили панель, сочетание клавиш, профиль Konsole или `~/.claude/settings.json`? Выполните:

```bash
claude-vps publish
```

Команда запускает `capture`, делает коммит `dotfiles/` и push. Если хотите сначала посмотреть diff:

```bash
claude-vps capture
git -C ~/claude-code-vps diff
```

## На сервере

```bash
claude-vps sync
```

Команда делает pull и запускает `apply`. Каждый файл, который будет перезаписан, сначала копируется в `~/.local/state/claude-vps/backup-<timestamp>/`. Файлы без изменений не трогаются.

Или пусть это происходит само:

```bash
claude-vps autosync on     # пользовательский таймер systemd, каждые 30 минут
claude-vps autosync        # показать время следующего запуска
claude-vps autosync off
```

::: warning Plasma и открытые сессии
Часть настроек Plasma держит в памяти и записывает на диск при выходе. Если синхронизация пришла, пока вы подключены по RDP, выйдите и зайдите снова, чтобы увидеть изменения. Пока не перезашли, не меняйте ту же настройку на сервере.
:::

## Что сохраняется

Список лежит в [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/manifest.txt). Слэш в конце означает всю папку.

| Область | Файлы |
| --- | --- |
| Plasma | `kdeglobals`, `kwinrc`, `kglobalshortcutsrc`, `plasmarc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kdedefaults/`, настройки питания и уведомлений |
| Приложения | `dolphinrc`, `konsolerc`, `katerc`, `~/.local/share/konsole/`, настройки темы GTK, `mimeapps.list` |
| Оформление | `~/.local/share/color-schemes/`, `plasma/`, `aurorae/`, `wallpapers/`, если они есть |
| Claude | `~/.claude/settings.json`, `hooks/` |
| Оболочка | `.tmux.conf`, `.xsession` |

Чтобы сохранять что-то ещё, добавьте строку в манифест. Пути, которых нет на вашем компьютере, пропускаются.

## Что никогда не сохраняется

Путь к вашей домашней папке заменяется на `@HOME@`, чтобы файлы работали с любым именем пользователя. Разделы с недавними файлами и историей удаляются. Учётных данных в списке просто нет: `~/.claude/.credentials.json`, `~/.claude/ntfy-topic`, SSH-ключи, `kwalletrc`, профили браузера. Не добавляйте их туда, репозиторий публичный.
