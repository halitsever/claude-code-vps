---
title: "Install Docker on Ubuntu Server 24.04: Two Ways"
titleTemplate: false
description: "Install Docker on Ubuntu Server 24.04 from Ubuntu's docker.io package or Docker's own repository, set up the docker group and mind ufw."
date: 2026-11-28
faq:
  - q: "Should I install docker.io or docker-ce on Ubuntu?"
    a: "docker.io and docker-compose-v2 come from Ubuntu's archive and update with the rest of the system. docker-ce comes from Docker's own repository and tracks Docker's releases more closely. Pick one; Docker's docs tell you to remove docker.io before installing docker-ce."
  - q: "How do I run Docker without sudo on Ubuntu?"
    a: "Add your user to the docker group with sudo usermod -aG docker $USER, then log out and back in. Membership in the docker group gives root-level access to the machine."
  - q: "Does ufw block Docker ports?"
    a: "No. Docker's docs say ports published by containers bypass ufw and firewalld rules. Bind published ports to 127.0.0.1 or add rules to the DOCKER-USER chain."
  - q: "Which Ubuntu versions does Docker support?"
    a: "Docker's install page lists 64-bit Ubuntu 22.04 LTS, 24.04 LTS, 26.04 LTS and 26.10."
---

# Install Docker on Ubuntu Server 24.04: two ways

<p class="post-meta">Halit Sever · 28 November 2026</p>

There are two ways to install Docker on an Ubuntu server: Ubuntu's own `docker.io` package, or Docker's `docker-ce` packages from Docker's apt repository. Both give you a working `docker` command. They differ in who builds the packages and how fast they update.

claude-code-vps uses the first one. This post shows exactly what its setup script runs, then the Docker repository route, then the two things people miss on servers: the `docker` group and the firewall.

## Option 1: Ubuntu's packages (what claude-code-vps runs)

The `apps` step in [`lib/setup.sh`](https://github.com/halitsever/claude-code-vps/blob/main/lib/setup.sh) installs these packages from Ubuntu's archive, keeping only the ones the release ships:

```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2 docker-buildx
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
```

- `docker.io` is the engine and the CLI.
- `docker-compose-v2` gives you `docker compose`.
- `docker-buildx` gives you `docker buildx`.

Why this route: the packages come through the same apt sources and the same `unattended-upgrades` as the rest of the server, with no extra repository or key to manage. The script runs on Ubuntu 24.04, 25.x and 26.x, and the package check means a name missing from one release does not break the run.

## Option 2: Docker's own repository

If you want Docker's current release and the official plugins, use Docker's repository. First remove the Ubuntu packages if they are installed, because the two sets conflict:

```bash
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc docker-buildx podman-docker containerd runc | cut -f1)
```

Add Docker's key and source:

```bash
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update
```

Install:

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Docker's [install page](https://docs.docker.com/engine/install/ubuntu/) lists 64-bit Ubuntu 22.04, 24.04, 26.04 and 26.10 as supported, checked on 28 November 2026. Removing Docker later does not delete `/var/lib/docker`, where images, containers and volumes live.

## Check that it works

```bash
sudo systemctl status docker
sudo docker run hello-world
docker compose version
```

## Docker without sudo

```bash
sudo usermod -aG docker "$USER"
```

Log out and back in, or start a new SSH session, for the group to apply. Then `docker ps` works without `sudo`.

Be aware of what that grants. Docker's post-install docs warn that the `docker` group gives root-level privileges: anyone in it can mount the host's filesystem into a container. On a single-user server like a Claude Code workstation, that user already has sudo, so nothing new is exposed. On a shared machine, think twice.

## Docker and ufw

claude-code-vps turns on ufw with only SSH and RDP open. Docker does not respect that for published ports. From Docker's docs: ports you expose with Docker "bypass ufw and firewalld rules".

So this is reachable from the internet even with ufw on:

```bash
docker run -d -p 5432:5432 postgres
```

And this is reachable only from the server itself:

```bash
docker run -d -p 127.0.0.1:5432:5432 postgres
```

For development servers, binding to `127.0.0.1` and reaching the port through an SSH tunnel (`ssh -L 5432:localhost:5432 dev@<server-ip>`) is the simplest safe default. If you need firewall rules for containers, Docker expects them in the `DOCKER-USER` chain with `iptables`.

## Letting Claude Code use Docker

Once your user is in the `docker` group, Claude Code running as that user can run `docker compose up`, build images and run tests in containers. On claude-code-vps this is in place after setup. `claude-vps doctor` checks Docker along with Claude Code, tmux, xrdp, Plasma, ufw, ntfy and autosync.

## FAQ

<Faq />

## Related

- [Install Google Chrome on Ubuntu](/blog/install-chrome-ubuntu-server): the other package the `apps` step adds
- [Install Claude Code on Linux](/blog/install-claude-code-linux): the agent that uses it
- [Claude Code over SSH](/blog/claude-code-ssh): port forwarding for services in containers
- [What gets installed](/guide/what-it-installs): every setup step
