---
title: "Claude Code VPS Blog: Remote Servers, SSH and Notifications"
titleTemplate: false
description: "Guides for running Claude Code on a remote server: Remote Control, installing on Linux, SSH, phone notifications with ntfy, Docker and Chrome on Ubuntu."
---

# Claude Code VPS blog

Notes on running Claude Code away from your laptop, written from the [claude-code-vps](https://github.com/halitsever/claude-code-vps) setup script and Anthropic's documentation. For the setup itself, start with [Getting started](/guide/getting-started) or [Control Claude Code from your phone](/claude-code-on-your-phone).

<ul class="post-list">
  <li>
    <a href="./claude-code-remote-control">Claude Code Remote Control vs running it on a server</a>
    <p>What Remote Control does, what it needs, where it stops, and what an always-on server adds.</p>
  </li>
  <li>
    <a href="./install-claude-code-linux">How to install Claude Code on Linux</a>
    <p>Native installer, apt, dnf, Alpine, Arch and npm, plus logging in without a browser.</p>
  </li>
  <li>
    <a href="./claude-code-notifications">Claude Code notifications: get a push when it needs you</a>
    <p>The Notification hook, its timing, and a phone push through ntfy.sh.</p>
  </li>
  <li>
    <a href="./claude-code-ssh">Claude Code over SSH: a working setup</a>
    <p>Key-only login, sessions that survive a disconnect, port forwarding and clipboard limits.</p>
  </li>
  <li>
    <a href="./ntfy-notifications">Send push notifications from any script with ntfy</a>
    <p>One curl line, topics, priorities, ntfy.sh limits and Docker self-hosting.</p>
  </li>
  <li>
    <a href="./ntfy-vs-gotify">ntfy vs Gotify: which push server for your scripts?</a>
    <p>Hosting, phone apps, tokens and priorities compared, and where Apprise fits.</p>
  </li>
  <li>
    <a href="./install-docker-ubuntu-server">Install Docker on Ubuntu Server 24.04: two ways</a>
    <p>Ubuntu's docker.io packages or Docker's repository, the docker group and ufw.</p>
  </li>
  <li>
    <a href="./install-chrome-ubuntu-server">Install Google Chrome on Ubuntu 24.04 and Ubuntu Server</a>
    <p>Google's apt repository, the .deb, ARM64, headless mode and Claude Code's Chrome integration.</p>
  </li>
</ul>
