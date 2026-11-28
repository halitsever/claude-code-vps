---
title: "VPS에서 Claude Code 실행하는 방법"
description: "Ubuntu VPS에서 Claude Code를 실행하는 단계별 가이드입니다. 안전한 SSH, 끊기지 않는 tmux 세션, 휴대폰 알림, RDP로 접속하는 KDE Plasma 데스크톱까지 다룹니다."
---

# VPS에서 Claude Code를 단계별로 실행하기

이 페이지는 제 작업 환경을 직접 구성하는 전체 과정입니다. 저렴한 Ubuntu 서버에서 Claude Code를 하루 종일 돌리고, 어디서든 SSH로 접속합니다. 화면이 필요할 때는 RDP로 KDE Plasma 데스크톱에 접속합니다.

아래 명령어는 모두 [`claude-vps setup`](/ko/guide/getting-started)이 대신 실행해 주는 것들입니다. 어떻게 동작하는지 알고 싶거나 직접 설치하고 싶을 때 읽어 보세요.

## 왜 VPS에서 Claude Code를 실행하나요

- **노트북이 잠자기 상태여도 작업이 계속됩니다.** 긴 리팩터링, 테스트, 마이그레이션이 자리를 비운 사이에 끝납니다.
- **내 컴퓨터를 깨끗하게 유지할 수 있습니다.** 에이전트가 패키지를 설치하고 Docker와 개발 서버를 띄우는 곳은 서버입니다. 서버는 10분이면 지우고 다시 만들 수 있습니다.
- **어디서나 같은 환경을 씁니다.** 노트북, 데스크톱, 태블릿, 휴대폰 어디서든 같은 tmux 세션과 같은 데스크톱에 접속합니다.
- **네트워크가 빠릅니다.** git 호스팅과 패키지 저장소에 가까워서 내려받기가 빠릅니다.

## 서버 고르기

| 용도 | vCPU | RAM | 디스크 |
| --- | --- | --- | --- |
| 터미널만 사용 | 2 | 4 GB | 40 GB |
| KDE 데스크톱 포함 | 4 | 8 GB | 80 GB |
| 에이전트 여러 개와 Docker | 8 | 16 GB | 160 GB |

Ubuntu 24.04 LTS 이상을 제공하는 곳이면 어디든 됩니다. Hetzner, DigitalOcean, OVH, Vultr, Linode, AWS Lightsail, 집에 남는 컴퓨터도 괜찮습니다. 가까운 리전을 고르면 RDP 반응이 더 빠릅니다. 서버를 만들 때 SSH 공개 키를 등록해 두면 root 비밀번호를 쓸 일이 없습니다.

## 1. 첫 로그인과 업데이트

```bash
ssh root@<server-ip>
apt update && apt upgrade -y
apt install -y git curl jq ripgrep fd-find tmux htop unzip build-essential nodejs npm unattended-upgrades
systemctl enable --now unattended-upgrades
```

`unattended-upgrades`는 보안 패치를 자동으로 설치합니다. 항상 인터넷에 연결된 서버라면 꼭 필요합니다.

메모리가 작은 서버에는 swap을 만들어 두세요. 에이전트가 메모리를 많이 써도 OOM killer가 프로세스를 죽이지 않습니다.

```bash
fallocate -l 4G /swapfile && chmod 600 /swapfile
mkswap /swapfile && swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## 2. 사용자 만들기

Claude Code를 root로 실행하지 마세요. sudo 권한이 있는 일반 사용자를 만듭니다.

```bash
adduser dev
usermod -aG sudo dev
mkdir -p /home/dev/.ssh
cp /root/.ssh/authorized_keys /home/dev/.ssh/
chown -R dev:dev /home/dev/.ssh && chmod 700 /home/dev/.ssh && chmod 600 /home/dev/.ssh/authorized_keys
```

다음으로 넘어가기 전에 새 터미널을 열고 `ssh dev@<server-ip>`로 접속되는지 확인하세요.

## 3. SSH 보안 설정

```bash
cat > /etc/ssh/sshd_config.d/10-hardening.conf <<'EOF'
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
EOF
sshd -t && systemctl reload ssh
```

sshd는 같은 설정이 여러 번 나오면 처음 읽은 값을 씁니다. 파일은 이름 순서대로 읽습니다. 그래서 파일 이름이 `10-`으로 시작합니다. 많은 클라우드 이미지에 들어 있는 `50-cloud-init.conf`에는 `PasswordAuthentication yes`가 있는데, 그보다 먼저 읽혀야 하기 때문입니다.

## 4. 방화벽

```bash
apt install -y ufw
ufw allow OpenSSH
ufw allow 53389/tcp   # 인터넷에서 RDP로 접속할 때만 필요합니다. 아래 참고
ufw --force enable
```

## 5. Claude Code 설치

만든 사용자로 로그인한 뒤 공식 설치 스크립트를 실행합니다. Node.js가 필요 없고 업데이트도 알아서 합니다.

```bash
ssh dev@<server-ip>
curl -fsSL https://claude.ai/install.sh | bash
```

`~/.local/bin/claude`에 설치됩니다. 이 폴더가 `PATH`에 들어가도록 한 번 로그아웃했다가 다시 로그인한 뒤 확인합니다.

```bash
claude --version
```

## 6. 화면 없는 서버에서 로그인하기

서버에는 브라우저가 없지만 필요하지도 않습니다.

```bash
claude
```

Claude Code가 URL을 보여 줍니다. 내 컴퓨터나 휴대폰에서 이 URL을 열고 승인한 뒤, 받은 코드를 터미널에 붙여 넣으면 됩니다. 로그인 정보는 서버의 `~/.claude`에 저장됩니다.

Pro나 Max 요금제 대신 Anthropic API 키를 쓴다면 셸 프로필에 넣어 두세요.

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

API 키로도 Claude Code는 동작하지만, Claude 앱이나 claude.ai에서 세션을 조작하는 [Remote Control](https://code.claude.com/docs/ko/remote-control)을 쓰려면 claude.ai로 로그인해야 합니다.

## 7. tmux로 세션 유지하기

SSH 세션에서 Claude를 바로 실행하면 노트북을 덮는 순간 같이 종료됩니다. tmux 안에서 실행하세요.

```bash
tmux new -s claude
claude
# Ctrl-b 다음 d로 빠져나옵니다. 에이전트는 계속 실행됩니다
tmux attach -t claude   # 나중에 어느 기기에서든 다시 접속
```

`~/.tmux.conf`를 조금만 설정해도 훨씬 편해집니다.

```bash
set -g mouse on
set -g history-limit 50000
set -g default-terminal "tmux-256color"
```

## 8. Claude가 입력을 기다릴 때 알림 받기

Claude Code는 입력을 기다릴 때 `Notification` 훅을 실행합니다. 이 훅으로 [ntfy.sh](https://ntfy.sh)를 통해 휴대폰에 알림을 보낼 수 있습니다.

```bash
mkdir -p ~/.claude/hooks
cat > ~/.claude/hooks/notify.sh <<'EOF'
#!/usr/bin/env bash
topic=$(cat ~/.claude/ntfy-topic 2>/dev/null) || exit 0
msg=$(jq -r '.message // "Claude가 기다리고 있습니다"')
curl -s -m 5 -H "Title: Claude Code" -d "$msg" "https://ntfy.sh/$topic" >/dev/null || true
EOF
chmod +x ~/.claude/hooks/notify.sh
echo my-hard-to-guess-topic > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
```

`~/.claude/settings.json`에 훅을 등록합니다.

```json
{
  "hooks": {
    "Notification": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh" }] }
    ]
  }
}
```

휴대폰의 ntfy 앱에서 같은 토픽을 구독하면 됩니다. 토픽 이름은 비밀번호처럼 관리하세요.

## 9. 선택 사항: RDP로 접속하는 KDE Plasma 데스크톱

대부분의 작업은 터미널로 충분합니다. 에이전트 옆에 Chrome을 띄우거나, 파일 관리자를 쓰거나, 큰 화면에 Konsole 창을 여러 개 띄우고 싶을 때 데스크톱이 유용합니다.

```bash
sudo apt install -y kde-plasma-desktop plasma-session-x11 kwin-x11 xrdp xorgxrdp
sudo systemctl disable --now sddm
sudo systemctl set-default multi-user.target
sudo adduser xrdp ssl-cert
sudo sed -i '0,/^port=/s/^port=.*/port=53389/' /etc/xrdp/xrdp.ini
```

Ubuntu 24.04에는 `plasma-session-x11`과 `kwin-x11`이 별도 패키지로 없습니다. 이 둘은 빼고 설치하세요.

xrdp가 이 사용자로 접속할 때 Plasma를 시작하도록 설정합니다.

```bash
cat > ~/.xsession <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
sudo systemctl restart xrdp
```

그대로 두면 로그인할 때마다 색상 프로필 관련 비밀번호 창이 뜹니다. 다음 설정으로 이 창을 없앱니다.

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

아무 RDP 클라이언트로 `<server-ip>:53389`에 접속하면 됩니다. 포트를 닫아 두고 SSH 터널로 접속하는 방법은 [원격 데스크톱](/ko/guide/remote-desktop)에 있습니다.

## 10. 개발 도구

```bash
sudo apt install -y docker.io docker-compose-v2 gh
sudo usermod -aG docker dev
gh auth login
```

## 보안 체크리스트

- SSH는 키로만 접속하고 root 비밀번호 로그인은 끕니다
- 방화벽을 켜고 필요한 포트만 엽니다
- Claude Code는 root가 아닌 일반 사용자로 실행합니다
- `--dangerously-skip-permissions`는 버려도 되는 컨테이너에서만 씁니다. 토큰과 SSH 키가 있는 서버에서는 절대 쓰지 않습니다
- 비밀 정보(`~/.claude/.credentials.json`, API 키, ntfy 토픽)는 공개 저장소에 올리지 않습니다
- 자동 업데이트를 켜 둡니다

## 명령어 하나로 모두 설치하기

위의 모든 과정에 내 KDE와 Claude 설정 적용까지 claude-vps가 자동으로 해 줍니다.

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

[시작하기](/ko/guide/getting-started)를 참고하세요.

## 자주 묻는 질문

### GUI가 없는 서버에서도 Claude Code가 동작하나요?

네. Claude Code는 터미널 앱입니다. 로그인은 다른 기기에서 링크를 열어서 하면 됩니다.

### 어떤 Claude 요금제가 필요한가요?

Claude Code가 포함된 요금제(Pro 또는 Max)나, 사용한 만큼 과금되는 Anthropic API 키가 있으면 됩니다.

### Claude Code용 VPS 비용은 얼마나 드나요?

저렴한 호스팅 업체에서 RAM 4~8 GB 서버는 보통 월 5~20 USD입니다. Claude 사용료는 요금제나 API 키에 따라 따로 청구됩니다.

### SSH 연결을 끊어도 Claude가 계속 실행되나요?

tmux(또는 screen) 안에서 실행했을 때만 그렇습니다. `tmux new -s claude`로 시작하고 `Ctrl-b d`로 빠져나오세요.

### 안전한가요?

직접 운영하는 다른 서버만큼 안전합니다. 위의 체크리스트를 지키고, 에이전트가 필요 없는 인증 정보에 접근하지 못하게 하세요.
