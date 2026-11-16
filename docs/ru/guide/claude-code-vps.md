---
title: "Как запустить Claude Code на VPS"
description: "Пошаговое руководство по Claude Code на VPS с Ubuntu: защищённый SSH, сессии tmux, уведомления на телефон и рабочий стол KDE Plasma по RDP."
---

# Как запустить Claude Code на VPS

Здесь описана моя настройка целиком, чтобы её можно было повторить вручную. Недорогой сервер на Ubuntu круглосуточно держит Claude Code. Я подключаюсь к нему по SSH откуда угодно, а когда нужен полноценный экран, захожу на рабочий стол KDE Plasma по RDP.

Все команды ниже за вас выполняет [`claude-vps setup`](/ru/guide/getting-started). Читайте эту страницу, чтобы понять, что происходит, или чтобы сделать всё руками.

## Зачем запускать Claude Code на VPS

- **Работа идёт, пока ноутбук спит.** Длинные рефакторинги, прогоны тестов и миграции завершаются без вас.
- **Ваш компьютер остаётся чистым.** Агенты ставят пакеты, запускают Docker и dev-серверы. Всё это происходит на машине, которую можно пересобрать за десять минут.
- **Одно окружение на всех устройствах.** С ноутбука, ПК, планшета или телефона вы попадаете в ту же сессию tmux и на тот же рабочий стол.
- **Быстрая сеть** рядом с вашим git-хостингом и репозиториями пакетов.

## Выбор сервера

| Задача | vCPU | RAM | Диск |
| --- | --- | --- | --- |
| Только терминал | 2 | 4 ГБ | 40 ГБ |
| С рабочим столом KDE | 4 | 8 ГБ | 80 ГБ |
| Несколько агентов и Docker | 8 | 16 ГБ | 160 ГБ |

Подойдёт любой провайдер с Ubuntu 24.04 LTS или новее: Hetzner, DigitalOcean, OVH, Vultr, Linode, AWS Lightsail или свободный компьютер дома. Выбирайте ближайший к вам регион, так RDP будет отзывчивее. При создании сервера сразу добавьте свой публичный SSH-ключ, тогда пароль root вообще не понадобится.

## 1. Первый вход и обновления

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades` сам ставит обновления безопасности. Для сервера, который всё время в сети, это важно.

На маленьких серверах нужен swap. Иначе, когда агенту не хватит памяти, OOM killer начнёт убивать процессы:

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. Создание пользователя

Не запускайте Claude Code от root. Создайте обычного пользователя с правами sudo:

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

Прежде чем продолжать, откройте второй терминал и проверьте, что `ssh dev@<server-ip>` работает.

## 3. Защита SSH

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd берёт первое прочитанное значение, а файлы читает по алфавиту. Поэтому имя начинается с `10-`. Файл должен идти раньше `50-cloud-init.conf`, где многие облачные образы прописывают `PasswordAuthentication yes`.

## 4. Файрвол

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # только если нужен RDP из интернета, см. ниже
ufw --force enable
```

## 5. Установка Claude Code

Войдите под своим пользователем и запустите нативный установщик. Node.js ему не нужен, обновляется он сам:

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

Claude Code устанавливается в `~/.local/bin/claude`. Выйдите и зайдите снова, чтобы эта папка попала в `PATH`, затем проверьте:

```bash
claude --version
```

## 6. Вход на сервере без браузера

На сервере нет браузера, и он не нужен:

```bash
claude
```

Claude Code покажет ссылку. Откройте её на своём компьютере или телефоне, подтвердите вход и вставьте код обратно в терминал. Данные входа сохраняются на сервере в `~/.claude`.

Если у вас ключ Anthropic API, а не тариф Pro или Max, добавьте его в профиль оболочки:

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## 7. Сессии, которые не обрываются: tmux

Если Claude запущен прямо в SSH-сессии, он остановится, как только вы закроете ноутбук. Поэтому запускайте его в tmux:

```bash
tmux new -s claude
claude
# Ctrl-b, затем d, чтобы отключиться. Агент продолжит работу
tmux attach -t claude   # потом, с любого устройства
```

Небольшой `~/.tmux.conf` сделает работу удобнее:

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Уведомление, когда Claude ждёт вас

Когда Claude Code ждёт ввода, он вызывает хук `Notification`. Его можно отправить на телефон через [ntfy.sh](https://ntfy.sh):

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude ждёт вашего ответа"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
EOF
chmod +x ~/.claude/hooks/notify.sh
echo my-hard-to-guess-topic > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
```

Подключите хук в `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

Подпишитесь на тот же топик в приложении ntfy. Храните топик в секрете, как пароль.

## 9. По желанию: рабочий стол KDE Plasma по RDP

Большую часть работы можно делать в терминале. Рабочий стол пригодится, если нужен Chrome рядом с агентом, файловый менеджер или несколько окон Konsole на большом экране.

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

В Ubuntu 24.04 пакетов `plasma-session-x11` и `kwin-x11` отдельно нет. Просто уберите их из команды.

Укажите xrdp, что для вашего пользователя нужно запускать Plasma:

```bash
cat > ~/.xsession <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
sudo systemctl restart xrdp
```

Без следующего шага при каждом входе будет появляться запрос пароля для цветовых профилей. Отключите его:

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

Подключитесь любым RDP-клиентом к `<server-ip>:53389`. Подробнее в разделе [Удалённый рабочий стол](/ru/guide/remote-desktop), там же описано, как держать порт закрытым и ходить через SSH-туннель.

## 10. Инструменты разработчика

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## Чек-лист безопасности

- SSH только по ключу, вход root по паролю отключён
- Файрвол включён, открыты только нужные порты
- Claude Code работает под обычным пользователем, не под root
- `--dangerously-skip-permissions` только в одноразовых контейнерах и никогда на машине с вашими токенами и SSH-ключами
- Секреты (`~/.claude/.credentials.json`, ключи API, топик ntfy) никогда не попадают в публичный репозиторий
- Автоматические обновления включены

## Всё одной командой

Всё, что описано выше, плюс ваши собственные настройки KDE и Claude, claude-vps делает автоматически:

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

См. [Быстрый старт](/ru/guide/getting-started).

## Вопросы и ответы

### Работает ли Claude Code на сервере без графического интерфейса?

Да. Это терминальное приложение. Вход выполняется по ссылке, которую вы открываете на любом другом устройстве.

### Какой тариф Claude нужен?

Любой тариф с Claude Code (Pro или Max) или ключ Anthropic API с оплатой по факту использования.

### Сколько стоит VPS для Claude Code?

У недорогих провайдеров сервер с 4 до 8 ГБ RAM обычно стоит от 5 до 20 USD в месяц. За Claude вы платите отдельно, по своему тарифу или ключу API.

### Продолжит ли Claude работать, если закрыть SSH?

Только внутри tmux (или screen). Запустите его через `tmux new -s claude` и отключитесь сочетанием `Ctrl-b d`.

### Это безопасно?

Настолько же, насколько безопасен любой сервер, который вы обслуживаете сами. Следуйте чек-листу выше и не давайте агенту доступ к учётным данным, которые ему не нужны.
