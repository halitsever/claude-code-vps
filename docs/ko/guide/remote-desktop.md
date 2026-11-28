---
title: "원격 데스크톱"
description: "Windows, macOS, Linux, iOS, Android에서 RDP로 Claude Code VPS의 KDE Plasma 데스크톱에 접속하는 방법입니다. SSH 터널 접속도 다룹니다."
---

# RDP로 원격 데스크톱 접속하기

서버에서는 RDP로 접속하는 KDE Plasma 세션이 돌아갑니다. 접속하면 세션이 시작되고, 연결을 끊어도 계속 실행됩니다. 그래서 다음에 접속하면 창이 그대로 남아 있습니다.

## 클라이언트

| 플랫폼 | 클라이언트 |
| --- | --- |
| Windows | 기본 내장된 원격 데스크톱 연결(`mstsc`) |
| macOS, iOS, iPadOS | Windows App (이전 이름: Microsoft Remote Desktop) |
| Android | Windows App 또는 aRDP |
| Linux | Remmina, KDE에서는 KRDC |

`<server-ip>:53389`로 접속합니다. xrdp가 세션 종류를 물으면 **Xorg**를 고르고, 작업용 사용자 이름과 비밀번호로 로그인하세요.

## SSH 터널로 접속하기

RDP는 암호화되지만, 인터넷에 열린 포트는 계속 스캔을 당합니다. `--rdp-private`로 설치했거나 포트를 열어 두고 싶지 않다면 SSH 터널을 쓰세요.

```bash
ssh -N -L 3389:localhost:53389 dev@<server-ip>
```

그다음 RDP 클라이언트로 `localhost:3389`에 접속합니다. 외부에는 SSH 포트만 열려 있게 됩니다.

이미 열어 둔 RDP 포트를 닫으려면 다음을 실행합니다.

```bash
sudo ufw delete allow 53389/tcp
```

## 화면 설정 팁

- **해상도**는 클라이언트 창 크기를 따라갑니다. 창 크기를 바꾸고 다시 접속하면 됩니다.
- **HiDPI**: 시스템 설정의 디스플레이에서 배율을 조정합니다. 사용자별로 저장됩니다.
- **느린 회선**: 클라이언트에서 색 깊이를 16비트로 낮추고, 시스템 설정의 작업 공간 동작에서 애니메이션을 끄세요.
- **클립보드**는 텍스트라면 별도 설정 없이 양방향으로 동작합니다.

## 사용자당 세션 하나

xrdp는 이미 실행 중인 세션에 다시 연결해 줍니다. 같은 사용자로 로컬과 RDP에 동시에 로그인하면 Plasma가 제대로 동작하지 않습니다. 하지만 서버에는 로컬 화면이 없으므로 이런 일은 생기지 않습니다.
