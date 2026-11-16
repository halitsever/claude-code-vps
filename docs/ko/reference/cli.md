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
| `update` | 서버, root로 | 최신 릴리스를 받아 첫 설치 때의 옵션으로 setup을 다시 실행합니다 |
| `sync` | 서버 | `git pull` 후 `apply`를 실행합니다 |
| `autosync on\|off` | 서버 | 30분마다 `sync`를 실행하는 systemd 사용자 타이머 |
| `doctor` | 서버 | Claude, tmux, Docker, xrdp, Plasma, ufw, ntfy, autosync 상태를 점검합니다 |
| `capture` | 내 컴퓨터 | `dotfiles/manifest.txt`에 적힌 파일을 `dotfiles/home`으로 복사합니다 |
| `publish` | 내 컴퓨터 | `capture` 후 커밋하고 푸시합니다 |
| `release X.Y.Z` | 내 컴퓨터 | `VERSION`을 쓰고 `vX.Y.Z` 태그를 붙여 푸시합니다. GitHub가 `CHANGELOG.md`를 바탕으로 릴리스를 게시합니다 |
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

## 업데이트

새 버전이 나오면 각 서버에서 다음을 실행합니다.

```bash
sudo claude-vps update
```

새 코드를 받아 바뀐 내용을 보여 주고, setup 단계를 모두 다시 실행합니다. 이미 끝난 단계는 건너뜁니다. xrdp와 SSH는 설정이 바뀐 경우에만 재시작하므로 열려 있는 RDP 세션은 끊기지 않습니다. 첫 설치 때 고른 옵션(사용자, RDP 포트, 건너뛴 단계)은 `/etc/claude-vps.conf`에 저장되어 그대로 다시 쓰입니다.

새 버전이 도착하면 `claude-vps sync`도 알려 줍니다.

## 버전 릴리스

내 컴퓨터에서 `CHANGELOG.md`에 `## X.Y.Z` 섹션을 추가하고 커밋한 다음, 이렇게 실행합니다.

```bash
claude-vps release X.Y.Z
```

릴리스 워크플로가 태그와 `VERSION`이 같은지 확인하고 GitHub 릴리스를 게시합니다. 릴리스 노트는 changelog의 해당 섹션입니다.

## 설정 원본 머신

`claude-vps capture`를 실행한 머신은 설정 원본으로 표시됩니다(`~/.config/claude-vps/source`). 이 머신에서는 `apply`와 `sync`가 파일을 건드리지 않습니다. 저장소에 있는 사본이 지금 쓰는 설정보다 오래됐을 수 있기 때문입니다. 그래도 덮어쓰려면 `claude-vps apply --force`를 쓰세요.

## install.sh

설치 스크립트는 환경 변수 세 개를 읽습니다.

| 변수 | 기본값 |
| --- | --- |
| `CLAUDE_VPS_REPO` | `https://github.com/halitsever/claude-code-vps.git` |
| `CLAUDE_VPS_DIR` | `/opt/claude-vps` |
| `CLAUDE_VPS_BRANCH` | `main` |

`bash -s --` 뒤에 적은 내용은 모두 `setup`에 그대로 전달됩니다.
