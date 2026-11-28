---
title: "문제 해결"
description: "Claude Code VPS에서 자주 생기는 문제 해결법입니다. RDP 검은 화면, xrdp 색상 프로필 창, SSH 접속 불가, claude 명령어 없음, 동기화 오류."
---

# 자주 발생하는 문제 해결하기

먼저 다음 명령어를 실행해 보세요.

```bash
claude-vps doctor
```

## RDP 화면이 검게 나오다가 연결이 끊깁니다

대개 `~/.xsession`이 없거나, 그 사용자로 Plasma가 이미 실행 중인 경우입니다.

```bash
cat ~/.xsession                      # 마지막 줄이 exec startplasma-x11이어야 합니다
loginctl list-sessions               # 내 사용자의 오래된 세션이 있다면 종료합니다
loginctl terminate-user $USER
```

로그는 `~/.xsession-errors`와 `/var/log/xrdp-sesman.log`에 있습니다.

## "Authentication is required to create a color managed device" 창이 뜹니다

`rdp` 단계에서 추가한 polkit 규칙이 이 창을 막습니다. `id`로 사용자가 `users` 그룹에 들어 있는지 확인한 뒤 다시 접속하세요.

## RDP에 아예 접속되지 않습니다

```bash
sudo ss -tlnp | grep xrdp      # 53389 포트에서 대기 중인가요?
sudo ufw status                # 포트가 허용되어 있나요?
```

클라우드 업체가 서버 앞에 별도 방화벽을 두고 있을 수도 있습니다. 업체의 방화벽 설정도 확인하세요.

## SSH로 접속할 수 없게 되었습니다

`ssh` 단계는 사용자에게 키가 있을 때만 비밀번호 로그인을 끕니다. 그래도 접속이 막혔다면 클라우드 업체의 웹 콘솔로 들어가서 다음을 실행하세요.

```bash
sudo rm /etc/ssh/sshd_config.d/10-claude-vps.conf && sudo systemctl reload ssh
```

## `claude: command not found`

공식 설치 스크립트는 Claude Code를 `~/.local/bin`에 설치합니다. Ubuntu는 이 폴더가 있으면 로그인할 때 `PATH`에 추가합니다. 로그아웃했다가 다시 로그인하거나 `source ~/.profile`을 실행하세요.

## `claude-vps sync`에서 "Not possible to fast-forward" 오류가 납니다

서버의 저장소에 로컬 변경 사항이 있다는 뜻입니다. 서버는 pull만 하도록 되어 있으므로 로컬 변경을 버립니다.

```bash
git -C /opt/claude-vps status
git -C /opt/claude-vps reset --hard origin/main
```

## 예전 파일 되살리기

`apply`는 덮어쓰는 파일을 매번 백업합니다.

```bash
ls ~/.local/state/claude-vps/
```
