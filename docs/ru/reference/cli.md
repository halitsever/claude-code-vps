---
title: "CLI claude-vps: команды и параметры"
description: "Справочник по всем командам и параметрам claude-vps для VPS с Claude Code: setup, sync, autosync, doctor, capture, publish, apply и переменные install.sh."
---

# CLI

```text
claude-vps <command> [options]
```

| Команда | Где | Что делает |
| --- | --- | --- |
| `setup` | сервер, от root | Выполняет шаги установки |
| `update` | сервер, от root | Скачивает последнюю версию и заново запускает setup с параметрами первой установки |
| `sync` | сервер | `git pull`, затем `apply` |
| `autosync on\|off` | сервер | Пользовательский таймер systemd, запускает `sync` каждые 30 минут |
| `doctor` | сервер | Проверяет Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy и autosync |
| `capture` | ваш компьютер | Копирует файлы из `dotfiles/manifest.txt` в `dotfiles/home` |
| `publish` | ваш компьютер | `capture`, коммит и push |
| `release X.Y.Z` | ваш компьютер | Записывает `VERSION`, ставит тег `vX.Y.Z` и делает push. GitHub публикует релиз по `CHANGELOG.md` |
| `apply` | где угодно | Записывает `dotfiles/home` в `$HOME`, сохраняя копии заменённых файлов |
| `version` | где угодно | Показывает версию |

## setup

```bash
sudo claude-vps setup [options]
```

| Параметр | По умолчанию | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER` или вопрос | Пользователь рабочей машины, создаётся, если его нет |
| `--rdp-port PORT` | `53389` | Порт xrdp |
| `--rdp-private` | выкл. | Не открывать порт RDP в ufw |
| `--ntfy-topic NAME` | вопрос | Топик ntfy.sh для уведомлений |
| `--timezone TZ` | не меняется | например, `Europe/Istanbul` |
| `--no-desktop` | выкл. | То же, что `--skip desktop,rdp` |
| `--skip a,b` | | Какие шаги пропустить |
| `--only a,b` | | Выполнить только эти шаги |
| `-y, --yes` | выкл. | Без вопросов. Пользователь `dev`, пароль генерируется |
| `-n, --dry-run` | выкл. | Показать команды, не выполняя их |

Шаги по порядку: `base user ssh firewall desktop rdp apps claude dotfiles`.

## Обновление

Когда выходит новая версия, выполните на каждом сервере:

```bash
sudo claude-vps update
```

Команда скачивает новый код, показывает, что изменилось, и заново проходит все шаги setup. Уже выполненные шаги пропускаются. xrdp и SSH перезапускаются, только если изменились их настройки, поэтому открытая RDP-сессия не обрывается. Параметры первой установки (пользователь, порт RDP, пропущенные шаги) хранятся в `/etc/claude-vps.conf` и используются снова.

`claude-vps sync` тоже сообщает, когда вышла новая версия.

## Выпуск версии

На своём компьютере добавьте в `CHANGELOG.md` раздел `## X.Y.Z`, сделайте коммит и выполните:

```bash
claude-vps release X.Y.Z
```

Workflow релиза проверяет, что тег совпадает с `VERSION`, и публикует релиз на GitHub. В описание релиза попадает этот раздел changelog.

## Машины-источники настроек

`claude-vps capture` помечает машину, на которой запущен, как источник настроек (`~/.config/claude-vps/source`). На такой машине `apply` и `sync` не трогают ваши файлы: копия в репозитории может быть старее того, чем вы сейчас пользуетесь. Чтобы всё равно перезаписать файлы, выполните `claude-vps apply --force`.

## install.sh

Скрипт начальной установки читает три переменные окружения:

| Переменная | По умолчанию |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

Всё, что указано после `bash -s --`, передаётся в `setup`.
