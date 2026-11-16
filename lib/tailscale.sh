# `claude-vps tailscale` and the last setup step: join a tailnet, then close public SSH and RDP.

# Tailscale hands out addresses from the CGNAT range 100.64.0.0/10.
is_tailnet_ip() {
  local a b
  IFS=. read -r a b _ <<<"$1"
  [[ $a == 100 && $b =~ ^[0-9]+$ ]] && ((b >= 64 && b <= 127))
}

# True when someone is connected to one of the given local ports from the tailnet.
tailnet_peer_seen() {
  local local_addr peer want
  while read -r _ _ local_addr peer _; do
    peer=${peer%:*}
    peer=${peer#[}
    peer=${peer%]}
    peer=${peer#::ffff:}
    for want in "$@"; do
      [[ ${local_addr##*:} == "$want" ]] && is_tailnet_ip "$peer" && return 0
    done
  done < <(ss -tnH state established 2>/dev/null)
  return 1
}

# Rules are deleted by spec, so a rule that was never added is not an error.
lockdown_firewall() {
  run ufw allow in on tailscale0
  local rule
  for rule in OpenSSH 22/tcp "$RDP_PORT/tcp"; do
    run ufw delete allow "$rule" >/dev/null || true
  done
  FIREWALL=tailscale
  save_setup_conf
  ok "SSH and RDP now only answer over Tailscale"
}

TAILNET_WAIT=${TAILNET_WAIT:-300}

can_prompt() { [[ $ASSUME_YES != 1 && -r /dev/tty ]]; }

# Waits until a tailnet peer is connected to one of the ports. Enter gives up early.
wait_for_tailnet_peer() {
  local timeout=$1
  shift
  local deadline=$((SECONDS + timeout)) tty=0
  # /dev/tty can be readable by mode yet fail to open without a controlling terminal.
  { : </dev/tty; } 2>/dev/null && tty=1
  while ((SECONDS < deadline)); do
    tailnet_peer_seen "$@" && return 0
    if ((tty)); then
      read -r -t 2 _ </dev/tty && return 1
    else
      sleep 2
    fi
  done
  tailnet_peer_seen "$@"
}

tailscale_flow() {
  if ! has tailscale; then
    run sh -c 'curl -fsSL https://tailscale.com/install.sh | sh'
  fi
  run systemctl enable --now tailscaled
  info "open the link below to add this server to your tailnet"
  run tailscale up || die "tailscale up failed, run it again with: sudo claude-vps tailscale"
  local ip
  ip=$(tailscale ip -4 2>/dev/null | head -n1)
  ok "on the tailnet as ${ip:-unknown}"

  info "install Tailscale on your own computer, sign in with the same account, then connect:"
  info "  ssh ${TARGET_USER:-<user>}@${ip}    or RDP to ${ip}:${RDP_PORT}"
  info "waiting up to $((TAILNET_WAIT / 60)) minutes for that connection, press Enter to skip"
  if [[ $DRY_RUN != 1 ]] && wait_for_tailnet_peer "$TAILNET_WAIT" 22 "$RDP_PORT"; then
    ok "saw a connection over Tailscale"
    local reply
    reply=$(ask "Close SSH and RDP to the internet, allow them only over Tailscale? [y/N]" "")
    if [[ $reply =~ ^[Yy] ]]; then
      lockdown_firewall
    else
      info "ports stay open. close them later with: sudo claude-vps tailscale"
    fi
  else
    warn "no connection over Tailscale yet, so SSH and RDP stay open to the internet"
    info "once you can connect over Tailscale, run: sudo claude-vps tailscale"
  fi
  # A node key that expires drops the server off the tailnet, which locks out a closed server.
  warn "Tailscale keys expire after 180 days. Turn that off for this server under"
  warn "  https://login.tailscale.com/admin/machines  ->  ...  ->  Disable key expiry"
}

step_tailscale() {
  if ! can_prompt; then
    info "skipped, set it up later with: sudo claude-vps tailscale"
    return
  fi
  if [[ $FIREWALL == tailscale ]] && tailscale status >/dev/null 2>&1; then
    ok "on Tailscale, public ports closed"
    return
  fi
  local reply
  reply=$(ask "Set up Tailscale now, so SSH and RDP can be closed to the internet? [Y/n]" "")
  if [[ $reply =~ ^[Nn] ]]; then
    info "skipped, set it up later with: sudo claude-vps tailscale"
    return
  fi
  tailscale_flow
}

cmd_tailscale() {
  [[ $EUID -eq 0 ]] || die "tailscale changes the firewall, so it needs root: sudo claude-vps tailscale"
  # shellcheck disable=SC1090
  if [[ -r $SETUP_CONF ]]; then . "$SETUP_CONF"; fi
  tailscale_flow
}
