---
description: "화면 없는 서버에서 Claude Code에 로그인하고, SSH가 끊겨도 tmux로 에이전트를 계속 실행하며, ntfy.sh로 휴대폰 알림을 받는 방법입니다."
---

# Claude Code 사용하기

## 첫 로그인

```bash
ssh dev@<server-ip>
tmux new -s claude
claude
```

Claude Code가 로그인 링크를 보여 줍니다. 내 브라우저에서 링크를 열고 승인한 뒤, 받은 코드를 터미널에 붙여 넣으세요. 로그인 정보는 서버의 `~/.claude`에 저장됩니다.

API 키를 쓰고 싶다면 실행하기 전에 환경 변수로 지정합니다.

```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.bashrc
```

## tmux로 계속 실행하기

한 시간씩 일하는 에이전트가 노트북이 잠들었다고 멈추면 안 됩니다. tmux 안에서 실행하고 세션에서 빠져나오세요.

| | |
| --- | --- |
| 빠져나오기 | `Ctrl-b` 다음 `d` |
| 다시 접속 | `tmux attach -t claude` |
| 새 창 | `Ctrl-b` 다음 `c` |
| 세션 목록 | `tmux ls` |

기본으로 들어 있는 `.tmux.conf`는 마우스 사용, 5만 줄 스크롤 기록, 256색을 켭니다.

데스크톱에서 Konsole을 열고 `tmux attach -t claude`를 실행해도 됩니다. 같은 세션을 더 큰 화면으로 볼 수 있습니다.

## 휴대폰 알림

`~/.claude/settings.json`에는 `Notification` 훅인 `~/.claude/hooks/notify.sh`가 등록되어 있습니다. Claude가 입력을 기다릴 때마다 이 훅이 [ntfy.sh](https://ntfy.sh)로 알림을 보냅니다.

1. 휴대폰에 ntfy 앱을 설치하고, 남이 추측하기 어려운 토픽을 구독합니다. 예: `claude-7f3k9q2m`
2. 서버에도 같은 토픽을 저장합니다.

   ```bash
   echo claude-7f3k9q2m > ~/.claude/ntfy-topic && chmod 600 ~/.claude/ntfy-topic
   ```

   설치할 때 `--ntfy-topic` 옵션으로 지정해도 됩니다.

토픽 이름을 아는 사람은 누구나 알림을 볼 수 있으니 비밀로 관리해야 합니다. 그래서 토픽은 별도 파일에 저장하고 저장소에는 절대 들어가지 않습니다.

## 미리 설정되어 있는 것

`dotfiles/home/.claude`에서 가져옵니다.

- **`settings.json`**: 다크 테마, 전체 화면 TUI, 모델과 폴더와 git 브랜치와 컨텍스트 사용량을 보여 주는 상태 표시줄, 제가 쓰는 플러그인, 알림 훅
- **`CLAUDE.md`**: 나만의 전역 지침을 적는 빈 파일입니다. 파일이 없을 때만 만들어지므로 직접 적은 내용은 덮어쓰지 않습니다
- **`hooks/notify.sh`**: 위에서 설명한 ntfy 훅

내 컴퓨터에서 이 파일들을 수정하고 `claude-vps publish`를 실행하면 됩니다. [설정 동기화](/ko/guide/sync)를 참고하세요.

## Claude Code 업데이트

공식 설치 스크립트로 설치한 Claude Code는 백그라운드에서 스스로 업데이트합니다. 바로 업데이트하려면 다음을 실행합니다.

```bash
claude update
```
