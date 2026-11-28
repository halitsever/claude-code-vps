---
title: "Send Push Notifications From Any Script With ntfy"
titleTemplate: false
description: "Send ntfy notifications from a shell script with one curl line: topics, titles, priorities and tags, the ntfy.sh limits, and self-hosting ntfy with Docker."
date: 2026-11-28
faq:
  - q: "Do I need an account to use ntfy.sh?"
    a: "No. You pick a topic name, subscribe to it in the app and publish to it with an HTTP POST. Because there is no sign-up, the topic name acts as the password."
  - q: "How many ntfy notifications can I send for free?"
    a: "ntfy.sh allows 250 messages a day per visitor by default, with a request bucket of 60 that refills at one request every 5 seconds. Messages can be up to 4,096 bytes."
  - q: "Can I self-host ntfy with Docker?"
    a: "Yes. The binwiederhier/ntfy image runs with docker run -p 80:80 binwiederhier/ntfy serve. Map /var/cache/ntfy for the message cache and /etc/ntfy for server.yml."
  - q: "Does ntfy work on iPhone?"
    a: "Yes. ntfy has apps for Android, on Google Play and F-Droid, and for iOS on the App Store, plus a web app."
---

# Send push notifications from any script with ntfy

<p class="post-meta">Halit Sever · 28 November 2026</p>

[ntfy](https://ntfy.sh) sends a push notification to your phone from anything that can make an HTTP request. There is no account to create and no SDK to install: you pick a topic, subscribe to it in the app, and POST a message to it. claude-code-vps uses it so Claude Code can tell you when it is waiting; the same line works for backups, deploys and cron jobs.

Facts below come from the [ntfy docs](https://docs.ntfy.sh/publish/), checked on 28 November 2026.

## The one line

```bash
curl -d "Backup finished" ntfy.sh/my-topic
```

The request body is the message, and the path is the topic. Topics do not need to be created first.

## Picking a topic

ntfy's docs say it directly: "Since there is no sign-up, the topic is essentially a password." Topic names on ntfy.sh are public, so anyone who knows yours can read and send messages. Names may use letters, numbers, `_` and `-`, up to 64 characters.

Generate something long and random:

```bash
echo "claude-$(tr -dc 'a-z0-9' </dev/urandom | head -c 12)"
```

Then keep it out of your repository. claude-code-vps stores it in `~/.claude/ntfy-topic` with mode 600 and reads it at run time, so the settings file that calls the hook can be public.

## Subscribing on your phone

Install the ntfy app (Android on Google Play or F-Droid, iOS on the App Store), add a subscription and enter the topic. The web app at ntfy.sh works too.

## Titles, priorities and tags

Headers turn a plain message into something easier to scan:

```bash
curl \
  -H "Title: Claude Code" \
  -H "Priority: high" \
  -H "Tags: robot" \
  -d "Claude needs your permission" \
  ntfy.sh/my-topic
```

| Priority | Name | On the phone |
| --- | --- | --- |
| 5 | `max` / `urgent` | Really long vibration bursts, sound and a pop-over |
| 4 | `high` | Long vibration burst, sound and a pop-over |
| 3 | `default` | Short vibration and sound |
| 2 | `low` | No sound; shows when you pull the drawer down |
| 1 | `min` | No sound, under "Other notifications" |

A tag that matches an emoji short code, like `robot` or `warning`, is shown as that emoji. Other tags appear below the notification.

## A notifier for any script

Wrap the call once and use it everywhere:

```bash
#!/usr/bin/env bash
# ~/bin/notify: notify "message" [title]
topic=$(cat ~/.config/ntfy-topic 2>/dev/null) || exit 0
curl -s -m 5 -H "Title: ${2:-$(hostname)}" -d "$1" "https://ntfy.sh/$topic" >/dev/null || true
```

```bash
./long-migration.sh && notify "Migration done" || notify "Migration failed" "db01"
```

The `-m 5` timeout and `|| true` make sure a slow network never fails the job you were reporting on. This is the same shape as the [Claude Code Notification hook](/blog/claude-code-notifications), which reads Claude's message from stdin with `jq` instead of taking an argument.

## Limits on ntfy.sh

The public server has defaults that are easy to stay under for personal alerts:

- Messages up to 4,096 bytes. Longer ones become attachments.
- A bucket of 60 requests that refills at one request every 5 seconds.
- 250 messages a day per visitor on ntfy.sh.
- Attachments up to 2 MB on ntfy.sh.
- Messages are cached on the server for 12 hours by default, so a phone that was offline still gets them. Send `-H "Cache: no"` to skip the cache.

ntfy.sh also sells paid tiers with higher limits.

## Self-hosting ntfy with Docker

If you would rather not use a public server, the same API runs on your own box:

```bash
docker run -d --name ntfy \
  -v /var/cache/ntfy:/var/cache/ntfy \
  -p 8080:80 \
  binwiederhier/ntfy \
  serve --cache-file /var/cache/ntfy/cache.db
```

The image is built for amd64, armv6, armv7 and arm64. It ships without `/etc/ntfy/server.yml`; to configure access control or a base URL, write one from the [template on GitHub](https://github.com/binwiederhier/ntfy/blob/main/server/server.yml) and mount `/etc/ntfy`. Point your scripts at `http://your-server:8080/my-topic`, and add the server in the app's settings.

On a server set up by claude-code-vps, keep in mind that ports published by Docker bypass ufw rules, as Docker's own docs warn. Bind to `127.0.0.1:8080:80` and put a reverse proxy in front, or reach it over Tailscale. [Install Docker on Ubuntu Server](/blog/install-docker-ubuntu-server) has more on that.

## FAQ

<Faq />

## Related

- [Claude Code notifications](/blog/claude-code-notifications): the hook that calls ntfy when Claude waits
- [ntfy vs Gotify](/blog/ntfy-vs-gotify): when a self-hosted Gotify server fits better
- [Control Claude Code from your phone](/claude-code-on-your-phone): ntfy plus an SSH app
- [Run Claude Code on a remote server](/guide/claude-code): the topic file on a claude-code-vps server
