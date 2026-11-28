---
title: "ntfy vs Gotify: Which Push Server for Your Scripts?"
titleTemplate: false
description: "ntfy vs Gotify compared from each project's docs: hosting, phone apps, tokens, priorities and Docker setup, plus where Apprise fits in."
date: 2026-11-28
faq:
  - q: "Is ntfy or Gotify better?"
    a: "They solve the same problem differently. ntfy works without an account on the public ntfy.sh server and has Android and iOS apps. Gotify is self-hosted only, uses per-application tokens, and its official phone app is for Android."
  - q: "Does Gotify have an iOS app?"
    a: "The Gotify project lists a server with a web UI, an Android app and a CLI. It does not list an iOS app."
  - q: "What is the difference between Apprise and ntfy?"
    a: "Apprise is a Python library and CLI that sends one notification to many services through URLs such as ntfy:// and gotify://. ntfy is a push service with its own server and apps. Apprise can send to ntfy."
  - q: "Can ntfy be self-hosted like Gotify?"
    a: "Yes. ntfy is a single Go binary with a Docker image, binwiederhier/ntfy. Self-hosted ntfy supports users and access tokens for private topics."
---

# ntfy vs Gotify: which push server for your scripts?

<p class="post-meta">Halit Sever · 28 November 2026</p>

ntfy and Gotify both send push notifications to your phone from a script. Both are open source, written in Go, and run in Docker. The differences are in how you host them, how you authenticate, and which phones they support. This comparison uses each project's own docs and repository, checked on 28 November 2026, and explains why claude-code-vps went with ntfy.

## At a glance

| | ntfy | Gotify |
| --- | --- | --- |
| License | Apache 2.0 and GPLv2 (dual) | MIT |
| Hosted option | Yes, ntfy.sh, free tier plus paid tiers | None from the project, you run the server |
| Account needed to send | No on ntfy.sh, the topic is the secret | Yes, an application token |
| Phone apps | Android (Google Play, F-Droid) and iOS | Android (Google Play, F-Droid, APK) |
| Web UI | Yes | Yes, built into the server |
| Receive API | HTTP streaming, WebSocket and others | WebSocket |
| Priorities | 1 to 5 | 0 to 10 |
| Docker image | `binwiederhier/ntfy` | `gotify/server` |

## Sending a message

ntfy needs nothing but the topic:

```bash
curl -H "Title: Backup" -d "Backup finished" https://ntfy.sh/my-secret-topic
```

Gotify needs an application token, which you create in the web UI or through the API. Since Gotify 3, the token is shown only once, when it is created or rotated:

```bash
curl "https://push.example.com/message" \
  -H "X-Gotify-Key: <apptoken>" \
  -F "title=Backup" -F "message=Backup finished" -F "priority=5"
```

Only `message` is required.

## How each one thinks about access

**ntfy** is built around topics. On ntfy.sh "the topic is essentially a password": anyone who knows the name can publish and subscribe. On your own server you can add users and access tokens and lock topics down.

**Gotify** is built around users, clients and applications. An application can only send. A client, such as the phone app, can only receive and manage. Users see only the messages of applications they created. That model has more setup, and nothing is public by default.

## Priorities on the phone

ntfy has five levels, from `min` (no sound, under "Other notifications") to `max` (long vibration bursts and a pop-over).

Gotify's Android app maps 0 to no notification, 1-3 to an icon only, 4-7 to icon and sound, and 8-10 to icon, sound and vibration. Messages without a priority use the application's default.

## Running them in Docker

```bash
# ntfy
docker run -d -p 8080:80 -v /var/cache/ntfy:/var/cache/ntfy \
  binwiederhier/ntfy serve --cache-file /var/cache/ntfy/cache.db

# Gotify
docker run -d -p 8081:80 -v /var/gotify/data:/app/data gotify/server
```

Gotify keeps its SQLite database, images and certificates in `/app/data`, so that directory is what you back up. ntfy's cache file holds recent messages for clients that were offline. Both images are multi-arch.

## Where Apprise fits

[Apprise](https://github.com/caronc/apprise) is a different kind of tool: a Python library and CLI that sends one notification to many services, each described by a URL. It supports both of the servers above, as `ntfy://topic/` and `gotify://hostname/token`. Use it when one script needs to reach ntfy, Slack and email at once. It is a sender, not a push server, so you still need ntfy or Gotify behind it for phone pushes.

## Why claude-code-vps uses ntfy

The Claude Code hook in claude-code-vps has to work on a fresh server with nothing else installed. ntfy fits that:

- **No server to run.** The hook posts to ntfy.sh, so a new VPS can send pushes right after setup.
- **No account.** The only secret is the topic, stored in `~/.claude/ntfy-topic` with mode 600.
- **iOS and Android.** The phone side works whichever phone you carry.
- **One curl line.** The hook is three lines of Bash. See [Claude Code notifications](/blog/claude-code-notifications).

If you already run Gotify, the hook changes in one place: replace the curl line with the `X-Gotify-Key` call above.

## Which one to pick

- Pick **ntfy** if you want pushes working in five minutes, need iOS, or want the option to self-host later without changing your scripts.
- Pick **Gotify** if you want a self-hosted server with per-application tokens and nothing public, and everyone who reads the messages uses Android or the web UI.

## FAQ

<Faq />

## Related

- [Send push notifications with ntfy](/blog/ntfy-notifications): topics, headers and limits
- [Claude Code notifications](/blog/claude-code-notifications): the hook that uses it
- [Install Docker on Ubuntu Server](/blog/install-docker-ubuntu-server): to self-host either one
- [What gets installed](/guide/what-it-installs): every setup step of claude-code-vps
