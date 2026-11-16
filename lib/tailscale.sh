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
