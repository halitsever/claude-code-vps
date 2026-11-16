# Tests for the firewall parts of lib/setup.sh.

test_firewall_tailscale_mode() {
  stub ufw 'exit 0'
  stub apt-get 'exit 0'
  FIREWALL=tailscale
  assert_ok step_firewall
  assert_fail grep -q 'allow OpenSSH' "$STUB_LOG"
  assert_fail grep -q 'allow 53389' "$STUB_LOG"
  assert_ok grep -qx 'ufw allow in on tailscale0' "$STUB_LOG"
}

test_firewall_public_mode_unchanged() {
  stub ufw 'exit 0'
  stub apt-get 'exit 0'
  FIREWALL=public RDP_PUBLIC=1 RDP_PORT=53389
  assert_ok step_firewall
  assert_ok grep -qx 'ufw allow OpenSSH' "$STUB_LOG"
  assert_ok grep -q 'ufw allow 53389/tcp' "$STUB_LOG"
}

test_conf_roundtrip_keeps_firewall() {
  SETUP_CONF=$TMP/conf FIREWALL=tailscale
  save_setup_conf
  unset FIREWALL
  . "$SETUP_CONF"
  assert_eq "$FIREWALL" tailscale
}
