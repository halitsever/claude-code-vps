---
description: "claude-vps가 Ubuntu 서버에서 실행하는 모든 단계를 설명합니다. 패키지, swap, SSH 보안, ufw, KDE Plasma, xrdp, Docker, Chrome, Claude Code, dotfiles."
---

# 설치되는 항목

`claude-vps setup`은 9단계를 순서대로 실행합니다. 각 단계는 [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh)에 있는 평범한 bash 함수라서, 서버에서 무엇이 실행되는지 그대로 읽어 볼 수 있습니다. `--skip`으로 원하는 단계를 건너뛰거나 `--only`로 일부 단계만 실행할 수 있습니다.

## 1. base

- 모든 패키지에 `apt upgrade` 실행
- `git curl jq ripgrep fd-find tmux htop build-essential python3` 등 기본 도구 설치
- Node.js 20 이상. Ubuntu 24.04의 apt에는 18만 있어서 NodeSource 저장소에서 설치합니다
- `unattended-upgrades`를 켜서 보안 패치가 자동으로 설치되도록 함
- swap이 없고 RAM이 8 GB보다 작으면 4 GB swap 파일 생성. Plasma와 에이전트 여러 개가 함께 돌아도 OOM killer에 걸리지 않습니다
- `--timezone`을 지정하면 시간대 설정

## 2. user

작업용 사용자를 만들고 `sudo` 그룹에 추가합니다. 이 사용자에게 SSH 키가 없으면 `/root/.ssh/authorized_keys`를 복사합니다. 여기서 정한 비밀번호는 RDP 로그인 화면에서 입력합니다.

## 3. ssh

`/etc/ssh/sshd_config.d/10-claude-vps.conf` 파일을 만듭니다.

```ini
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin prohibit-password
```

sshd는 처음 읽은 값을 씁니다. 그래서 파일 이름을 `10-`으로 시작해, 대부분의 클라우드 이미지에 들어 있는 `50-cloud-init.conf`보다 먼저 읽히게 합니다. 사용자에게 아직 SSH 키가 없으면 경고만 하고 이 단계를 건너뜁니다. 서버에 접속하지 못하게 되는 일을 막기 위해서입니다.

## 4. firewall

`ufw`를 켜고 OpenSSH와 RDP 포트만 허용합니다. 나머지는 모두 닫습니다. `--rdp-private`를 주면 RDP 포트도 닫아 두고, SSH 터널로 접속하게 됩니다.

## 5. desktop

`kde-plasma-desktop`과 X11 세션(Ubuntu 25.10 이상에서는 `plasma-session-x11`, `kwin-x11`), Konsole, Dolphin, Kate, Spectacle, Noto 폰트와 JetBrains Mono 폰트를 설치합니다. 서버 앞에 앉아 있는 사람은 없으므로 SDDM은 끄고 기본 타깃을 `multi-user`로 바꿉니다. 부팅하면 바로 콘솔로 가고, Plasma는 접속할 때만 시작됩니다.

::: info 왜 X11인가요
xrdp는 Xorg 세션을 사용합니다. Ubuntu 24.04부터 26.04까지 Plasma 6에는 아직 X11 세션이 있고, 저도 매일 RDP로 이 세션을 씁니다.
:::

## 6. rdp

- `xrdp`와 `xorgxrdp`를 설치하고 **53389** 포트에서 접속을 받습니다(`--rdp-port`로 변경 가능)
- 알맞은 `XDG_*` 변수와 함께 `startplasma-x11`을 실행하는 `~/.xsession` 생성
- 로그인할 때마다 뜨는 "authentication is required to create a color managed device" 창을 없애는 polkit 규칙 추가

## 7. apps

- Docker(`docker.io`, compose v2, buildx). 사용자를 `docker` 그룹에 추가합니다
- GitHub CLI(`gh`)
- Google apt 저장소의 Google Chrome(amd64 전용). Claude가 실제 브라우저를 써야 할 때 유용합니다

## 8. claude

- 공식 설치 스크립트로 Claude Code를 `~/.local/bin/claude`에 설치합니다. 업데이트는 알아서 합니다
- [claudegrid](https://github.com/halitsever/claudegrid)를 최신 `.deb` 릴리스로 설치합니다. 명령 하나로 Konsole이나 tmux에 Claude Code 에이전트 그리드를 띄웁니다. Konsole 프로필과 앱 메뉴 항목도 함께 추가됩니다
- ntfy.sh 토픽을 지정했다면 `~/.claude/ntfy-topic`에 저장합니다. 알림 훅이 이 파일을 읽습니다

## 9. dotfiles

`/opt/claude-vps`의 소유자를 작업용 사용자로 바꾸고, `claude-vps`를 `/usr/local/bin`에 링크한 뒤, 그 사용자로 `claude-vps apply`를 실행합니다. 그러면 `dotfiles/home` 아래의 모든 파일이 홈 폴더에 들어갑니다. KDE 설정, Konsole 프로필, `~/.claude/settings.json`, `CLAUDE.md`, 훅, `.tmux.conf`가 여기에 포함됩니다.

## 단계 다시 실행하기

각 단계는 이미 설치된 것을 먼저 확인하므로 다시 실행해도 안전합니다.

```bash
sudo claude-vps setup --only desktop,rdp     # 예: 배포판 업그레이드 후
sudo claude-vps setup --skip apps            # Docker와 Chrome만 빼고 전부
sudo claude-vps setup --no-desktop           # 터미널만 쓰는 서버
```
