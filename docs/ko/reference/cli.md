---
description: "claude-vps의 모든 명령어와 옵션 레퍼런스입니다. setup, sync, autosync, doctor, capture, publish, apply와 install.sh 환경 변수를 다룹니다."
---

# CLI

```text
claude-vps <command> [options]
```

| 명령어 | 실행 위치 | 하는 일 |
| --- | --- | --- |
| `setup` | 서버, root로 | 설치 단계를 실행합니다 |
| `sync` | 서버 | `git pull` 후 `apply`를 실행합니다 |
| `autosync on\|off` | 서버 | 30분마다 `sync`를 실행하는 systemd 사용자 타이머 |
| `doctor` | 서버 | Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy, autosync 상태를 점검합니다 |
| `capture` | 내 컴퓨터 | `dotfiles/manifest.txt`에 적힌 파일을 `dotfiles/home`으로 복사합니다 |
| `publish` | 내 컴퓨터 | `capture` 후 커밋하고 푸시합니다 |
| `apply` | 어디서나 | `dotfiles/home`을 `$HOME`에 씁니다. 덮어쓰는 파일은 백업합니다 |
| `version` | 어디서나 | 버전을 출력합니다 |

## setup

```bash
sudo claude-vps setup [options]
```

| 옵션 | 기본값 | |
| --- | --- | --- |
| `-u, --user NAME` | `$SUDO_USER`, 없으면 물어봄 | 작업용 사용자. 없으면 새로 만듭니다 |
| `--rdp-port PORT` | `53389` | xrdp 포트 |
| `--rdp-private` | 꺼짐 | ufw에서 RDP 포트를 열지 않습니다 |
| `--ntfy-topic NAME` | 물어봄 | 알림을 받을 ntfy.sh 토픽 |
| `--timezone TZ` | 변경 안 함 | 예: `Europe/Istanbul` |
| `--no-desktop` | 꺼짐 | `--skip desktop,rdp`와 같습니다 |
| `--skip a,b` | | 건너뛸 단계 |
| `--only a,b` | | 이 단계만 실행 |
| `-y, --yes` | 꺼짐 | 아무것도 묻지 않습니다. 사용자는 `dev`, 비밀번호는 자동 생성됩니다 |
| `-n, --dry-run` | 꺼짐 | 명령어를 실행하지 않고 출력만 합니다 |

단계 순서: `base user ssh firewall desktop rdp apps claude dotfiles`.

## install.sh

설치 스크립트는 환경 변수 세 개를 읽습니다.

| 변수 | 기본값 |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

`bash -s --` 뒤에 적은 내용은 모두 `setup`에 그대로 전달됩니다.
