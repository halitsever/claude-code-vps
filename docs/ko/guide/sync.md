---
title: "설정 동기화"
description: "claude-vps publish, sync, autosync로 내 컴퓨터와 VPS 사이에서 KDE Plasma와 Claude Code 설정을 똑같이 유지하는 방법입니다."
---

# 내 컴퓨터와 서버의 설정 동기화하기

서버의 모양과 동작을 정하는 설정은 모두 저장소에 있습니다. 내 컴퓨터에서 설정을 바꾸면 서버가 그 변경 사항을 가져옵니다.

```text
 내 컴퓨터                       GitHub                     서버
 ─────────                      ──────                     ────
 claude-vps publish  ──push──▶  dotfiles/home  ──pull──▶  claude-vps sync
 (capture + commit)                                        (또는 30분마다 autosync)
```

## 내 컴퓨터에서

저장소를 한 번 클론하고 CLI를 PATH에 추가합니다.

```bash
git clone https://github.com/halitsever/claude-code-vps.git ~/claude-code-vps
ln -s ~/claude-code-vps/bin/claude-vps ~/.local/bin/claude-vps
```

패널, 단축키, Konsole 프로필, `~/.claude/settings.json` 등을 바꾼 뒤에는 다음을 실행합니다.

```bash
claude-vps publish
```

이 명령은 `capture`를 실행하고 `dotfiles/`를 커밋한 뒤 푸시합니다. 변경 내용을 먼저 확인하고 싶다면 이렇게 하세요.

```bash
claude-vps capture
git -C ~/claude-code-vps diff
```

## 서버에서

```bash
claude-vps sync
```

변경 사항을 pull한 뒤 `apply`를 실행합니다. 덮어쓸 파일은 먼저 `~/.local/state/claude-vps/backup-<timestamp>/`에 복사해 둡니다. 바뀌지 않은 파일은 건드리지 않습니다.

자동으로 실행되게 할 수도 있습니다.

```bash
claude-vps autosync on     # systemd 사용자 타이머, 30분마다 실행
claude-vps autosync        # 다음 실행 시각 확인
claude-vps autosync off
```

::: warning Plasma 세션이 열려 있을 때
Plasma는 일부 설정을 메모리에 들고 있다가 로그아웃할 때 파일에 씁니다. RDP로 접속해 있는 동안 동기화가 되었다면, 로그아웃했다가 다시 로그인해야 변경 사항이 보입니다. 그 사이에 서버에서 같은 설정을 바꾸지 마세요.
:::

## 가져오는 항목

목록은 [`dotfiles/manifest.txt`](https://github.com/halitsever/claude-code-vps/blob/main/dotfiles/manifest.txt)에 있습니다. 경로가 슬래시로 끝나면 폴더 전체를 뜻합니다.

| 분류 | 파일 |
| --- | --- |
| Plasma | `kdeglobals`, `kwinrc`, `kglobalshortcutsrc`, `plasmarc`, `plasmashellrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `kdedefaults/`, 전원 및 알림 설정 |
| 앱 | `dolphinrc`, `konsolerc`, `katerc`, `~/.local/share/konsole/`, GTK 테마 설정, `mimeapps.list` |
| 테마 | `~/.local/share/color-schemes/`, `plasma/`, `aurorae/`, `wallpapers/` (있는 경우) |
| Claude | `~/.claude/settings.json`, `hooks/` |
| 셸 | `.tmux.conf`, `.xsession` |

다른 파일도 관리하고 싶다면 manifest에 한 줄 추가하면 됩니다. 내 컴퓨터에 없는 경로는 건너뜁니다.

## 절대 가져가지 않는 항목

홈 경로는 `@HOME@`으로 바뀌므로 사용자 이름이 달라도 파일이 그대로 동작합니다. 최근 파일 목록이나 기록이 담긴 부분은 제외합니다. 인증 정보는 처음부터 목록에 없습니다. `~/.claude/.credentials.json`, `~/.claude/ntfy-topic`, SSH 키, `kwalletrc`, 브라우저 프로필이 여기에 해당합니다. 저장소는 공개되어 있으니 계속 이렇게 유지하세요.
