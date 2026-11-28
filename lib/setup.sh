# `claude-vps setup`: turns a fresh Ubuntu server into a remote Claude Code workstation.

STEPS=(base user ssh firewall desktop rdp apps claude dotfiles tailscale)

declare -A STEP_DESC=(
  [base]="System update, core packages, swap, unattended upgrades"
  [user]="Sudo user with your SSH keys"
  [ssh]="Key-only SSH, no root password login"
  [firewall]="ufw with SSH and RDP open, or Tailscale only"
  [desktop]="KDE Plasma (X11 session), no display manager"
  [rdp]="xrdp on a custom port, starting Plasma"
  [apps]="Docker, Google Chrome, GitHub CLI"
  [claude]="Claude Code native install, claudegrid and ntfy notifications"
  [dotfiles]="Your KDE, Claude and shell config from this repo"
  [tailscale]="Tailscale, then SSH and RDP closed to the internet (asks first)"
)

TARGET_USER=${TARGET_USER:-}
RDP_PORT=${RDP_PORT:-53389}
RDP_PUBLIC=${RDP_PUBLIC:-1}
FIREWALL=${FIREWALL:-public}
NTFY_TOPIC=${NTFY_TOPIC:-}
TIMEZONE=${TIMEZONE:-}
ASSUME_YES=${ASSUME_YES:-0}
SKIP=${SKIP:-}
ONLY=${ONLY:-}
GENERATED_PASSWORD=''

step_wanted() {
  local s=$1
  if [[ -n $ONLY ]]; then
    [[ ",$ONLY," == *",$s,"* ]]
  else
    [[ ",$SKIP," != *",$s,"* ]]
  fi
}

preflight() {
  [[ $EUID -eq 0 ]] || die "setup needs root. Run it with sudo."
  [[ -r /etc/os-release ]] || die "cannot read /etc/os-release"
  # shellcheck disable=SC1091
  . /etc/os-release
  [[ ${ID:-} == ubuntu ]] || die "only Ubuntu is supported (found ${ID:-unknown})"
  case ${VERSION_ID:-} in
    24.04 | 25.* | 26.*) ;;
    *) warn "Ubuntu $VERSION_ID is untested, 24.04 or newer is expected" ;;
  esac
  ok "Ubuntu $VERSION_ID on $(dpkg --print-architecture)"

  if [[ -z $TARGET_USER ]]; then
    local fallback=${SUDO_USER:-}
    [[ $fallback == root ]] && fallback=''
    if [[ $ASSUME_YES == 1 ]]; then
      TARGET_USER=${fallback:-dev}
    else
      TARGET_USER=$(ask "Username for your workstation" "${fallback:-dev}")
    fi
  fi
  [[ $TARGET_USER =~ ^[a-z_][a-z0-9_-]*$ ]] || die "invalid username: $TARGET_USER"
  ok "target user: $TARGET_USER"
}

step_base() {
  run apt-get update -q
  run env DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -q
  apt_install ca-certificates curl wget git jq ripgrep fd-find tmux htop unzip zip \
    build-essential python3 python3-pip software-properties-common \
    unattended-upgrades locales
  install_node
  run systemctl enable --now unattended-upgrades

  [[ -n $TIMEZONE ]] && run timedatectl set-timezone "$TIMEZONE"

  if [[ -z $(swapon --show --noheadings) ]]; then
    local mem_gb
    mem_gb=$(awk '/MemTotal/ {printf "%d", $2/1024/1024}' /proc/meminfo)
    if ((mem_gb < 8)); then
      info "no swap and ${mem_gb}G RAM, adding a 4G swapfile"
      run fallocate -l 4G /swapfile
      run chmod 600 /swapfile
      run mkswap /swapfile
      run swapon /swapfile
      grep -q '^/swapfile' /etc/fstab || run sh -c 'echo "/swapfile none swap sw 0 0" >> /etc/fstab'
    fi
  fi
  ok "base system ready"
}

apt_candidate() { apt-cache policy "$1" | awk '/Candidate:/ {sub(/^[0-9]+:/, "", $2); print $2}'; }

# claudegrid needs Node 20+, Ubuntu 24.04 ships 18, so older releases get NodeSource's Node 22.
install_node() {
  local candidate
  candidate=$(apt_candidate nodejs)
  if ((${candidate%%.*} < 20)); then
    info "Ubuntu's Node.js $candidate is too old, adding the NodeSource repo for Node 22"
    run install -d -m 755 /etc/apt/keyrings
    run sh -c 'curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor --yes -o /etc/apt/keyrings/nodesource.gpg'
    if [[ $DRY_RUN != 1 ]]; then
      cat >/etc/apt/sources.list.d/nodesource.sources <<'EOF'
Types: deb
URIs: https://deb.nodesource.com/node_22.x
Suites: nodistro
Components: main
Signed-By: /etc/apt/keyrings/nodesource.gpg
EOF
    fi
    run apt-get update -q
    candidate=$(apt_candidate nodejs)
  fi
  # NodeSource's nodejs bundles npm and conflicts with Ubuntu's npm package.
  if [[ $candidate == *nodesource* ]]; then
    apt_install nodejs
  else
    apt_install nodejs npm
  fi
}

step_user() {
  if id "$TARGET_USER" >/dev/null 2>&1; then
    ok "user $TARGET_USER already exists"
  else
    run adduser --disabled-password --gecos '' "$TARGET_USER"
    local pass=''
    if [[ $ASSUME_YES != 1 && -r /dev/tty ]]; then
      pass=$(ask_secret "Password for $TARGET_USER (used for sudo and RDP login, empty = generate)")
    fi
    if [[ -z $pass ]]; then
      pass=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)
      GENERATED_PASSWORD=$pass
    fi
    [[ $DRY_RUN == 1 ]] || printf '%s:%s\n' "$TARGET_USER" "$pass" | chpasswd
    ok "created $TARGET_USER"
  fi
  run usermod -aG sudo "$TARGET_USER"

  local home
  home=$(user_home "$TARGET_USER")
  if [[ ! -s $home/.ssh/authorized_keys && -s /root/.ssh/authorized_keys ]]; then
    run install -d -m 700 -o "$TARGET_USER" -g "$TARGET_USER" "$home/.ssh"
    run install -m 600 -o "$TARGET_USER" -g "$TARGET_USER" /root/.ssh/authorized_keys "$home/.ssh/authorized_keys"
    ok "copied root's SSH keys to $TARGET_USER"
  fi
}

step_ssh() {
  local home
  home=$(user_home "$TARGET_USER")
  if [[ ! -s $home/.ssh/authorized_keys ]]; then
    warn "$TARGET_USER has no SSH key yet, leaving password login on so you are not locked out"
    return
  fi
  # sshd keeps the first value it reads, so this file has to sort before the cloud image defaults.
  local conf=/etc/ssh/sshd_config.d/10-claude-vps.conf
  local want=$'PasswordAuthentication no\nKbdInteractiveAuthentication no\nPermitRootLogin prohibit-password'
  if [[ -f $conf && $(cat "$conf") == "$want" ]]; then
    ok "SSH already accepts keys only"
    return
  fi
  if [[ $DRY_RUN == 1 ]]; then
    info "would write $conf"
  else
    printf '%s\n' "$want" >"$conf"
  fi
  run sshd -t
  run systemctl reload ssh
  ok "SSH accepts keys only"
}

step_firewall() {
  apt_install ufw
  # `update` re-runs this step, so a server moved to Tailscale must not get its public ports back.
  if [[ $FIREWALL == tailscale ]]; then
    run ufw allow in on tailscale0
    run ufw --force enable
    ok "firewall on, SSH and RDP over Tailscale only"
    return
  fi
  run ufw allow OpenSSH
  if [[ $RDP_PUBLIC == 1 ]]; then
    run ufw allow "$RDP_PORT/tcp" comment 'xrdp'
  else
    info "RDP port stays closed, reach it through an SSH tunnel"
  fi
  run ufw --force enable
  ok "firewall on"
}

step_desktop() {
  local pkgs
  mapfile -t pkgs < <(apt_available kde-plasma-desktop plasma-session-x11 kwin-x11 \
    konsole dolphin kate ark gwenview okular spectacle plasma-nm fonts-noto fonts-noto-color-emoji \
    fonts-jetbrains-mono breeze-gtk-theme kde-config-gtk-style)
  apt_install "${pkgs[@]}"
  # Nobody sits in front of a server, so skip the login screen and boot to a console.
  if systemctl list-unit-files sddm.service >/dev/null 2>&1; then
    run systemctl disable --now sddm || true
  fi
  run systemctl set-default multi-user.target
  ok "KDE Plasma installed"
}

step_rdp() {
  apt_install xrdp xorgxrdp
  run adduser xrdp ssl-cert
  local before
  before=$(md5sum /etc/xrdp/xrdp.ini 2>/dev/null)
  if [[ $DRY_RUN == 1 ]]; then
    info "would set xrdp port to $RDP_PORT"
  else
    sed -i "0,/^port=/s/^port=.*/port=$RDP_PORT/" /etc/xrdp/xrdp.ini
    sed -i 's/^max_bpp=.*/max_bpp=32/' /etc/xrdp/xrdp.ini
    mkdir -p /etc/polkit-1/rules.d
    # Without this, every RDP login asks for a password to "create a color managed device".
    cat >/etc/polkit-1/rules.d/45-claude-vps-colord.rules <<'EOF'
polkit.addRule(function (action, subject) {
  if (action.id.indexOf("org.freedesktop.color-manager.") === 0 && subject.isInGroup("users")) {
    return polkit.Result.YES;
  }
});
EOF
  fi
  run usermod -aG users "$TARGET_USER"

  local home
  home=$(user_home "$TARGET_USER")
  if [[ $DRY_RUN != 1 ]]; then
    cat >"$home/.xsession" <<'EOF'
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=KDE
export DESKTOP_SESSION=plasma
exec startplasma-x11
EOF
    chown "$TARGET_USER:$TARGET_USER" "$home/.xsession"
  fi
  run systemctl enable xrdp
  # A restart drops open RDP connections, so only do it when something changed.
  if [[ $before != "$(md5sum /etc/xrdp/xrdp.ini 2>/dev/null)" ]] || ! systemctl is-active --quiet xrdp; then
    run systemctl restart xrdp
  fi
  ok "xrdp listening on $RDP_PORT"
}

step_apps() {
  local docker_pkgs
  mapfile -t docker_pkgs < <(apt_available docker.io docker-compose-v2 docker-buildx)
  apt_install "${docker_pkgs[@]}"
  run systemctl enable --now docker
  run usermod -aG docker "$TARGET_USER"

  apt_install gh

  local arch
  arch=$(dpkg --print-architecture)
  if [[ $arch == amd64 || $arch == arm64 ]]; then
    if ! has google-chrome; then
      run install -d -m 755 /etc/apt/keyrings
      run sh -c 'curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor --yes -o /etc/apt/keyrings/google-chrome.gpg'
      if [[ $DRY_RUN != 1 ]]; then
        cat >/etc/apt/sources.list.d/google-chrome.sources <<EOF
Types: deb
URIs: https://dl.google.com/linux/chrome/deb/
Suites: stable
Components: main
Architectures: $arch
Signed-By: /etc/apt/keyrings/google-chrome.gpg
EOF
      fi
      run apt-get update -q
      apt_install google-chrome-stable
    fi
  else
    info "Chrome has no $arch build, skipping it"
  fi
  ok "Docker, gh and browser ready"
}

step_claude() {
  if as_user 'test -x ~/.local/bin/claude' 2>/dev/null && [[ $DRY_RUN != 1 ]]; then
    ok "Claude Code already installed"
  else
    as_user 'curl -fsSL https://claude.ai/install.sh | bash'
    ok "Claude Code installed to ~/.local/bin/claude"
  fi
  install_claudegrid

  local home
  home=$(user_home "$TARGET_USER")
  if [[ -z $NTFY_TOPIC && $ASSUME_YES != 1 && ! -s $home/.claude/ntfy-topic ]]; then
    NTFY_TOPIC=$(ask "ntfy.sh topic for phone notifications (empty = skip)" "")
  fi
  if [[ -n $NTFY_TOPIC && $DRY_RUN != 1 ]]; then
    install -d -m 700 -o "$TARGET_USER" -g "$TARGET_USER" "$home/.claude"
    printf '%s\n' "$NTFY_TOPIC" >"$home/.claude/ntfy-topic"
    chown "$TARGET_USER:$TARGET_USER" "$home/.claude/ntfy-topic"
    chmod 600 "$home/.claude/ntfy-topic"
    ok "ntfy topic saved"
  fi
}

# The .deb ships the Konsole profile and app menu entry, so the KDE desktop picks it up without extra setup.
install_claudegrid() {
  local deb=/tmp/claudegrid.deb qdbus
  run curl -fsSL -o "$deb" https://github.com/halitsever/claudegrid/releases/latest/download/claudegrid.deb
  # Konsole splits panes over D-Bus, the package name differs between Ubuntu releases.
  mapfile -t qdbus < <(apt_available qdbus-qt6 qt6-tools-dev-tools | head -n1)
  apt_install "$deb" "${qdbus[@]}"
  run rm -f "$deb"
  ok "claudegrid installed, run it from Konsole or with: claudegrid"
}

step_dotfiles() {
  # The user owns the clone so `claude-vps sync` works without sudo.
  run chown -R "$TARGET_USER:$TARGET_USER" "$REPO_DIR"
  run git config --system --add safe.directory "$REPO_DIR"
  run ln -sf "$REPO_DIR/bin/claude-vps" /usr/local/bin/claude-vps
  if [[ -e $(user_home "$TARGET_USER")/.config/claude-vps/source ]]; then
    info "this machine is where your config comes from, leaving its files alone"
  else
    as_user "'$REPO_DIR/bin/claude-vps' apply"
  fi
}

summary() {
  local ip
  if [[ $FIREWALL == tailscale ]]; then
    ip=$(tailscale ip -4 2>/dev/null | head -n1) || true
    ip=${ip:-<tailscale-ip>}
  else
    ip=$(curl -fsS -m 4 https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')
  fi
  printf '\n%s%s  Done.%s\n\n' "$C_BOLD" "$C_ACCENT" "$C_RESET"
  printf '  SSH        ssh %s@%s\n' "$TARGET_USER" "$ip"
  printf '  Desktop    RDP to %s:%s as %s\n' "$ip" "$RDP_PORT" "$TARGET_USER"
  [[ -n $GENERATED_PASSWORD ]] && printf '  Password   %s%s%s  (change it with passwd)\n' "$C_BOLD" "$GENERATED_PASSWORD" "$C_RESET"
  printf '  Claude     ssh in, run tmux, then claude and follow the login link\n'
  printf '  Grid       claudegrid in Konsole over RDP, or claudegrid -b tmux over SSH\n'
  printf '  Updates    claude-vps sync   (or: claude-vps autosync on)\n\n'
  return 0
}

# Options from the last run, so `update` keeps a custom port or user.
SETUP_CONF=/etc/claude-vps.conf

save_setup_conf() {
  [[ $DRY_RUN == 1 ]] && return
  printf 'TARGET_USER=%q\nRDP_PORT=%q\nRDP_PUBLIC=%q\nFIREWALL=%q\nTIMEZONE=%q\nSKIP=%q\n' \
    "$TARGET_USER" "$RDP_PORT" "$RDP_PUBLIC" "$FIREWALL" "$TIMEZONE" "$SKIP" >"$SETUP_CONF"
}

cmd_setup() {
  # shellcheck disable=SC1090
  if [[ -r $SETUP_CONF ]]; then . "$SETUP_CONF"; fi
  while (($#)); do
    case $1 in
      -u | --user) TARGET_USER=$2; shift ;;
      --rdp-port) RDP_PORT=$2; shift ;;
      --rdp-private) RDP_PUBLIC=0 ;;
      --ntfy-topic) NTFY_TOPIC=$2; shift ;;
      --timezone) TIMEZONE=$2; shift ;;
      --skip) SKIP=$2; shift ;;
      --only) ONLY=$2; shift ;;
      --no-desktop) SKIP="${SKIP:+$SKIP,}desktop,rdp" ;;
      -y | --yes) ASSUME_YES=1 ;;
      -n | --dry-run) DRY_RUN=1 ;;
      -h | --help) usage_setup; return ;;
      *) die "unknown option for setup: $1" ;;
    esac
    shift
  done

  log "Preflight"
  preflight
  local s
  for s in "${STEPS[@]}"; do
    step_wanted "$s" || { info "skipping $s"; continue; }
    log "${STEP_DESC[$s]}"
    "step_$s"
  done
  save_setup_conf
  summary
}

usage_setup() {
  cat <<EOF
Usage: sudo claude-vps setup [options]

  -u, --user NAME        workstation user (default: \$SUDO_USER or asks)
      --rdp-port PORT    xrdp port (default: 53389)
      --rdp-private      keep the RDP port closed, use an SSH tunnel
                         (Tailscale is offered at the end, or later: sudo claude-vps tailscale)
      --ntfy-topic NAME  ntfy.sh topic for "Claude is waiting" pushes
      --timezone TZ      e.g. Europe/Istanbul
      --no-desktop       skip KDE and xrdp, terminal only
      --skip a,b         skip steps
      --only a,b         run only these steps
  -y, --yes              no questions, use defaults
  -n, --dry-run          print what would run

Steps: ${STEPS[*]}
EOF
}
