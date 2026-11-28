---
title: "Быстрый старт"
description: "Установка claude-vps на чистый VPS с Ubuntu 24.04 или 26.04 одной командой: Claude Code, KDE Plasma по RDP и защищённый SSH примерно за десять минут."
---

# Начало работы с claude-vps

claude-vps превращает чистый сервер на Ubuntu в машину, на которой я работаю с Claude Code. Вы получаете пользователя с sudo, SSH только по ключу, файрвол, рабочий стол KDE Plasma с доступом по RDP, Docker и Chrome. И сам Claude Code, уже с моими настройками, хуками и раскладкой KDE.

## Что понадобится

| | |
| --- | --- |
| **ОС** | Ubuntu 24.04 LTS или новее (сам я использую 26.04) |
| **CPU / RAM** | Минимум для Plasma: 2 vCPU и 4 ГБ. С 4 vCPU / 8 ГБ работать так же удобно, как за обычным компьютером |
| **Диск** | От 25 ГБ |
| **Доступ** | root по SSH, лучше если ваш SSH-ключ уже добавлен на сервер |
| **Архитектура** | И на amd64, и на arm64 ставится всё |

Чтобы потом войти в Claude Code, нужен тариф Claude Pro или Max либо ключ Anthropic API.

## Установка

Подключитесь по SSH под root (или пользователем с sudo) и выполните:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

Скрипт клонирует репозиторий в `/opt/claude-vps` и запускает `claude-vps setup`. Он задаст два вопроса: имя пользователя для рабочей машины и пароль для него. Пароль нужен для sudo и для входа по RDP. Если оставить его пустым, скрипт сгенерирует пароль и покажет его в конце.

Чтобы обойтись без вопросов, передайте параметры после `bash -s --`:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

Все параметры описаны в [справочнике по CLI](/ru/reference/cli).

::: tip Сначала попробуйте
`--dry-run` выводит все команды, но не выполняет их.
:::

## После установки

В конце вы увидите примерно такую сводку:

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. **Войдите по SSH** под новым пользователем. Ключи root скопированы ему, так что подойдёт тот же ключ.
2. **Запустите Claude Code** внутри tmux и войдите в аккаунт. См. [Работа с Claude Code](/ru/guide/claude-code).
3. **Откройте рабочий стол** любым RDP-клиентом. См. [Удалённый рабочий стол](/ru/guide/remote-desktop).

## Свои настройки

По умолчанию сервер получает мои настройки KDE и Claude из `dotfiles/home`. Чтобы использовать свои, сделайте форк репозитория, запустите `claude-vps capture` на своём компьютере, сделайте push и укажите установщику адрес форка:

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

Весь процесс описан в разделе [Синхронизация настроек](/ru/guide/sync).
