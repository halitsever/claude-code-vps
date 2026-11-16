# Versions: `update` brings a machine to the latest release, `release` cuts one.

CHANGELOG=$REPO_DIR/CHANGELOG.md

changelog_section() {
  awk -v v="$1" '
    $0 ~ "^## \\[?" v "\\]?([ ]|$)" { on = 1; next }
    on && /^## / { exit }
    on
  ' "$CHANGELOG"
}

cmd_update() {
  [[ $EUID -eq 0 ]] || die "update runs the setup steps, so it needs root: sudo claude-vps update"
  local owner before after
  owner=$(stat -c %U "$REPO_DIR")
  before=$(cat "$REPO_DIR/VERSION")
  log "Checking for a new claude-vps (installed: $before)"
  runuser -u "$owner" -- git -C "$REPO_DIR" pull -q --ff-only
  after=$(cat "$REPO_DIR/VERSION")
  if [[ $before == "$after" ]]; then
    ok "already on $after, re-running setup to repair anything missing"
  else
    ok "$before -> $after"
    changelog_section "$after" | sed 's/^/  /'
  fi
  # Run the freshly pulled code, not the copy already loaded in this shell.
  exec "$REPO_DIR/bin/claude-vps" setup --yes --user "$owner" "$@"
}

cmd_release() {
  local v=${1:-}
  [[ $v =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "usage: claude-vps release X.Y.Z"
  [[ -z $(git -C "$REPO_DIR" status --porcelain) ]] || die "commit or stash your changes first"
  [[ -n $(changelog_section "$v") ]] || die "add a '## $v' section to CHANGELOG.md first"
  git -C "$REPO_DIR" rev-parse -q --verify "refs/tags/v$v" >/dev/null && die "v$v already exists"
  if [[ $(cat "$REPO_DIR/VERSION") != "$v" ]]; then
    printf '%s\n' "$v" >"$REPO_DIR/VERSION"
    git -C "$REPO_DIR" commit -q -m "chore: release v$v" -- VERSION
  fi
  git -C "$REPO_DIR" tag -a "v$v" -m "v$v"
  git -C "$REPO_DIR" push -q origin HEAD "v$v"
  ok "v$v pushed. GitHub creates the release, servers get it with 'sudo claude-vps update'"
}
