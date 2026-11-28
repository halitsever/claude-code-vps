---
description: "새 Ubuntu 24.04 또는 26.04 VPS에 명령어 하나로 claude-vps를 설치하면 약 10분 만에 Claude Code, RDP용 KDE Plasma, 안전한 SSH가 준비됩니다."
---

# 시작하기

claude-vps는 새 Ubuntu 서버를 제가 Claude Code를 돌리는 환경과 똑같이 만들어 줍니다. sudo 사용자, 키로만 접속하는 SSH, 방화벽, RDP로 접속하는 KDE Plasma 데스크톱, Docker, Chrome을 설치합니다. Claude Code에는 제 설정, 훅, KDE 레이아웃이 적용된 상태로 들어갑니다.

## 준비물

| | |
| --- | --- |
| **OS** | Ubuntu 24.04 LTS 이상 (저는 26.04를 씁니다) |
| **CPU / RAM** | Plasma를 쓰려면 최소 2 vCPU, 4 GB입니다. 4 vCPU, 8 GB면 일반 데스크톱처럼 쓸 수 있습니다 |
| **디스크** | 25 GB 이상 |
| **접속** | SSH root 접속. 서버에 SSH 키가 미리 등록되어 있으면 좋습니다 |
| **아키텍처** | amd64와 arm64 모두 모든 항목이 설치됩니다 |

설치가 끝난 뒤 Claude Code에 로그인하려면 Claude Pro 또는 Max 요금제나 Anthropic API 키가 필요합니다.

## 설치

root(또는 sudo 권한이 있는 사용자)로 SSH 접속한 뒤 실행합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh | sudo bash
```

이 저장소를 `/opt/claude-vps`에 내려받고 `claude-vps setup`을 실행합니다. 질문은 두 가지입니다. 작업용 사용자 이름과 그 사용자의 비밀번호입니다. 비밀번호는 sudo와 RDP 로그인에 쓰입니다. 비워 두면 자동으로 만들어서 마지막에 보여 줍니다.

질문 없이 설치하려면 `bash -s --` 뒤에 옵션을 넣습니다.

```bash
curl -fsSL https://raw.githubusercontent.com/halitsever/claude-code-vps/main/install.sh \
  | sudo bash -s -- --user dev --timezone Europe/Istanbul --ntfy-topic my-secret-topic --yes
```

전체 옵션은 [CLI 레퍼런스](/ko/reference/cli)에 있습니다.

::: tip 먼저 확인해 보기
`--dry-run`을 붙이면 명령어를 실행하지 않고 출력만 합니다.
:::

## 설치가 끝나면

다음과 같은 요약이 나옵니다.

```text
  Done.

  SSH        ssh dev@203.0.113.7
  Desktop    RDP to 203.0.113.7:53389 as dev
  Claude     ssh in, run tmux, then claude and follow the login link
  Updates    claude-vps sync   (or: claude-vps autosync on)
```

1. 새 사용자로 **SSH 접속**합니다. root의 SSH 키가 복사되어 있으므로 같은 키로 들어갈 수 있습니다.
2. tmux 안에서 **Claude Code를 실행**하고 로그인합니다. [Claude Code 사용하기](/ko/guide/claude-code)를 참고하세요.
3. 아무 RDP 클라이언트로 **데스크톱에 접속**합니다. [원격 데스크톱](/ko/guide/remote-desktop)을 참고하세요.

## 내 설정 사용하기

기본으로는 `dotfiles/home`에 있는 제 KDE와 Claude 설정이 서버에 적용됩니다. 내 설정을 쓰려면 저장소를 포크하고, 내 컴퓨터에서 `claude-vps capture`를 실행해 푸시한 뒤, 설치 스크립트가 포크한 저장소를 쓰도록 지정합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/<you>/claude-code-vps/main/install.sh \
  | sudo CLAUDE_VPS_REPO=https://github.com/<you>/claude-code-vps.git bash
```

전체 흐름은 [설정 동기화](/ko/guide/sync)에서 설명합니다.
