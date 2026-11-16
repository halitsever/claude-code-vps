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

# Stand-ins for a working tailscale CLI on a server that already has it.
fake_tailscale() {
  stub tailscale '[[ $1 == ip ]] && echo 100.121.162.28; exit 0'
  stub systemctl 'exit 0'
  stub ufw 'exit 0'
}

test_step_skips_with_yes() {
  fake_tailscale
  ASSUME_YES=1
  assert_ok step_tailscale
  assert_eq "$(cat "$STUB_LOG")" ""
}

test_step_noop_when_locked_down() {
  fake_tailscale
  FIREWALL=tailscale
  can_prompt() { return 0; }
  ask() { echo ASKED >>"$STUB_LOG"; }
  assert_ok step_tailscale
  assert_fail grep -q ASKED "$STUB_LOG"
}

test_step_asks_and_respects_no() {
  fake_tailscale
  FIREWALL=public
  can_prompt() { return 0; }
  ask() { echo ASKED >>"$STUB_LOG"; echo n; }
  assert_ok step_tailscale
  assert_ok grep -q ASKED "$STUB_LOG"
  assert_fail grep -q 'tailscale up' "$STUB_LOG"
}

test_wait_times_out() {
  stub ss 'exit 0'
  assert_fail wait_for_tailnet_peer 1 22
}

test_wait_sees_peer() {
  stub ss 'echo "0 0 100.121.162.28:22 100.92.102.89:62684"'
  assert_ok wait_for_tailnet_peer 5 22
}

test_flow_keeps_ports_open_without_peer() {
  fake_tailscale
  stub ss 'exit 0'
  TAILNET_WAIT=1 SETUP_CONF=$TMP/conf TARGET_USER=dev
  ask() { echo y; }
  assert_ok tailscale_flow
  assert_ok grep -q 'tailscale up' "$STUB_LOG"
  assert_fail grep -q '^ufw' "$STUB_LOG"
}

test_flow_locks_down_after_peer_and_yes() {
  fake_tailscale
  stub ss 'echo "0 0 100.121.162.28:22 100.92.102.89:62684"'
  TAILNET_WAIT=5 SETUP_CONF=$TMP/conf TARGET_USER=dev
  ask() { echo y; }
  assert_ok tailscale_flow
  assert_ok grep -qx 'ufw allow in on tailscale0' "$STUB_LOG"
}

test_flow_default_answer_keeps_ports_open() {
  fake_tailscale
  stub ss 'echo "0 0 100.121.162.28:22 100.92.102.89:62684"'
  TAILNET_WAIT=5 SETUP_CONF=$TMP/conf TARGET_USER=dev
  ask() { echo ""; }
  assert_ok tailscale_flow
  assert_fail grep -q '^ufw' "$STUB_LOG"
}

test_wait_without_tty_waits_full_timeout() {
  stub ss 'exit 0'
  local start=$SECONDS
  assert_fail wait_for_tailnet_peer 2 22 </dev/null
  ((SECONDS - start >= 2)) || fail "returned after $((SECONDS - start))s, expected the full 2s wait"
}

test_wait_without_tty_polls_slowly() {
  stub ss 'exit 0'
  assert_fail wait_for_tailnet_peer 2 22 </dev/null
  local calls
  calls=$(grep -c '^ss' "$STUB_LOG")
  ((calls <= 3)) || fail "ss ran $calls times in 2s, expected a 2s poll"
}
