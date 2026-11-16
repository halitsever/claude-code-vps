# Tests for lib/tailscale.sh.

test_is_tailnet_ip() {
  assert_ok is_tailnet_ip 100.64.0.1
  assert_ok is_tailnet_ip 100.127.255.254
  assert_fail is_tailnet_ip 100.63.0.1
  assert_fail is_tailnet_ip 100.128.0.1
  assert_fail is_tailnet_ip 82.147.85.101
}

test_peer_seen_mapped_v6() {
  stub ss 'echo "0 0 [::ffff:100.121.162.28]:53389 [::ffff:100.92.102.89]:62650"'
  assert_ok tailnet_peer_seen 22 53389
}

test_peer_seen_plain_v4() {
  stub ss 'echo "0 0 100.121.162.28:22 100.92.102.89:62684"'
  assert_ok tailnet_peer_seen 22 53389
}

test_peer_ignores_public_and_other_ports() {
  stub ss 'echo "0 0 [::ffff:188.132.232.187]:53389 [::ffff:82.147.85.101]:49698"; echo "0 0 100.121.162.28:5432 100.92.102.89:1"'
  assert_fail tailnet_peer_seen 22 53389
}

test_lockdown_calls_ufw_in_order() {
  stub ufw 'exit 0'
  RDP_PORT=53389 SETUP_CONF=$TMP/conf
  assert_ok lockdown_firewall
  assert_eq "$(cat "$STUB_LOG")" $'ufw allow in on tailscale0\nufw delete allow OpenSSH\nufw delete allow 22/tcp\nufw delete allow 53389/tcp'
  assert_ok grep -qx 'FIREWALL=tailscale' "$SETUP_CONF"
}

test_lockdown_survives_missing_rule() {
  stub ufw '[[ "$*" == "delete allow 22/tcp" ]] && exit 1; exit 0'
  SETUP_CONF=$TMP/conf
  assert_ok lockdown_firewall
  assert_ok grep -qx 'ufw delete allow 53389/tcp' "$STUB_LOG"
}
