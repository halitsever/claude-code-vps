# Moving config between your machine, this repo and the server.

MANIFEST=$REPO_DIR/dotfiles/manifest.txt
STORE=$REPO_DIR/dotfiles/home
# Starter files: created when missing, never overwritten, never captured.
SEED=$REPO_DIR/dotfiles/seed
# Present on machines that publish config. apply would roll their live settings back.
SOURCE_MARK=$HOME/.config/claude-vps/source
PLUGINS=$REPO_DIR/dotfiles/plugins.txt
INSTALLED_PLUGINS=$HOME/.claude/plugins/installed_plugins.json
# Skills you wrote yourself live in other marketplaces or sync from claude.ai, so they stay out.
PUBLIC_MARKETPLACES='anthropic-plugin-directory|claude-plugins-official'

is_text() { [[ ! -s $1 ]] || grep -Iq . "$1"; }

manifest_paths() {
  grep -vE '^\s*(#|$)' "$MANIFEST" | sed 's/[[:space:]]*$//'
}

# Home paths become @HOME@ and recent-file lists are dropped, so the repo can stay public.
scrub() {
  sed "s|$HOME|@HOME@|g" "$1" | awk '
    /^\[.*\]$/ { skip = ($0 ~ /Recent|History|recent|history/) }
    !skip
  '
}

capture_one() {
  local src=$1 dst=$2
  mkdir -p "$(dirname "$dst")"
  if is_text "$src"; then
    scrub "$src" >"$dst"
  else
    cp "$src" "$dst"
  fi
  [[ -x $src ]] && chmod +x "$dst"
  return 0
}

cmd_capture() {
  [[ -f $MANIFEST ]] || die "missing $MANIFEST"
  mkdir -p "$(dirname "$SOURCE_MARK")"
  touch "$SOURCE_MARK"
  log "Capturing config from $HOME"
  rm -rf "$STORE"
  mkdir -p "$STORE"
  local path src n=0 f
  while IFS= read -r path; do
    src=$HOME/${path%/}
    if [[ -d $src ]]; then
      while IFS= read -r -d '' f; do
        capture_one "$f" "$STORE/${f#"$HOME"/}"
        n=$((n + 1))
      done < <(find "$src" -type f -print0)
    elif [[ -f $src ]]; then
      capture_one "$src" "$STORE/$path"
      n=$((n + 1))
    else
      info "not on this machine: $path"
    fi
  done < <(manifest_paths)
  ok "$n files in dotfiles/home"
  capture_plugins
  if git -C "$REPO_DIR" rev-parse >/dev/null 2>&1; then
    git -C "$REPO_DIR" status --short -- dotfiles | sed 's/^/  /'
  fi
}

installed_plugins() {
  [[ -f $INSTALLED_PLUGINS ]] && jq -r '.plugins | keys[]' "$INSTALLED_PLUGINS"
  return 0
}

capture_plugins() {
  has jq || { warn "jq is missing, plugin list not captured"; return; }
  {
    echo '# Public Claude Code plugins, installed on servers by `claude-vps apply`.'
    installed_plugins | grep -E "@($PUBLIC_MARKETPLACES)\$" | sort
  } >"$PLUGINS"
  ok "$(grep -vc '^#' "$PLUGINS") public plugins in dotfiles/plugins.txt"
}

apply_plugins() {
  [[ -f $PLUGINS ]] || return 0
  local claude=$HOME/.local/bin/claude have id added=0
  [[ -x $claude ]] || claude=$(command -v claude) || { warn "claude not found, plugins skipped"; return 0; }
  have=$(installed_plugins)
  while IFS= read -r id; do
    grep -qxF "$id" <<<"$have" && continue
    if "$claude" plugin install "$id" --scope user >/dev/null 2>&1; then
      info "installed plugin $id"
      added=$((added + 1))
    else
      warn "could not install plugin $id, try: claude plugin install $id"
    fi
  done < <(grep -vE '^\s*(#|$)' "$PLUGINS")
  ((added)) && ok "$added plugins installed, restart Claude Code to load them"
  return 0
}

cmd_publish() {
  cmd_capture
  if [[ -z $(git -C "$REPO_DIR" status --porcelain -- dotfiles) ]]; then
    ok "nothing changed"
    return
  fi
  git -C "$REPO_DIR" add dotfiles
  git -C "$REPO_DIR" commit -q -m "chore: update dotfiles from $(hostname -s)"
  git -C "$REPO_DIR" push -q
  ok "pushed, servers pick it up on their next sync"
}

render() {
  if is_text "$1"; then
    sed "s|@HOME@|$HOME|g" "$1"
  else
    cat "$1"
  fi
}

cmd_apply() {
  [[ -d $STORE ]] || die "no captured config in $STORE, run capture on your machine first"
  if [[ -e $SOURCE_MARK && ${1:-} != --force ]]; then
    warn "this machine publishes config, so applying would roll your live settings back"
    info "run 'claude-vps apply --force' if that is really what you want"
    return 0
  fi
  log "Applying config to $HOME"
  local backup
  backup=$HOME/.local/state/claude-vps/backup-$(date +%Y%m%d-%H%M%S)
  local tmp changed=0 f rel target
  tmp=$(mktemp)
  while IFS= read -r -d '' f; do
    rel=${f#"$STORE"/}
    target=$HOME/$rel
    render "$f" >"$tmp"
    [[ -f $target ]] && cmp -s "$tmp" "$target" && continue
    if [[ -f $target ]]; then
      mkdir -p "$(dirname "$backup/$rel")"
      cp -p "$target" "$backup/$rel"
    fi
    mkdir -p "$(dirname "$target")"
    cp "$tmp" "$target"
    [[ -x $f ]] && chmod +x "$target"
    info "updated $rel"
    changed=$((changed + 1))
  done < <(find "$STORE" -type f -print0)
  rm -f "$tmp"
  apply_plugins
  if [[ -d $SEED ]]; then
    while IFS= read -r -d '' f; do
      rel=${f#"$SEED"/}
      target=$HOME/$rel
      [[ -e $target ]] && continue
      mkdir -p "$(dirname "$target")"
      cp "$f" "$target"
      info "created $rel"
      changed=$((changed + 1))
    done < <(find "$SEED" -type f -print0)
  fi
  if ((changed)); then
    ok "$changed files updated, old copies in ${backup/#$HOME/\~}"
    info "log out of the desktop and back in to see KDE changes"
  else
    ok "already up to date"
  fi
}

cmd_sync() {
  local before after
  before=$(cat "$REPO_DIR/VERSION")
  log "Pulling $(git -C "$REPO_DIR" remote get-url origin 2>/dev/null || echo repo)"
  git -C "$REPO_DIR" pull -q --ff-only
  after=$(cat "$REPO_DIR/VERSION")
  cmd_apply "$@"
  if [[ $before != "$after" ]]; then
    warn "claude-vps $before is now $after. Run 'sudo claude-vps update' to apply new setup steps"
  fi
}

cmd_autosync() {
  local unit_dir=$HOME/.config/systemd/user
  case ${1:-} in
    on)
      mkdir -p "$unit_dir"
      cat >"$unit_dir/claude-vps-sync.service" <<EOF
[Unit]
Description=Pull claude-vps config and apply it

[Service]
Type=oneshot
ExecStart=$REPO_DIR/bin/claude-vps sync
EOF
      cat >"$unit_dir/claude-vps-sync.timer" <<'EOF'
[Unit]
Description=Run claude-vps sync every 30 minutes

[Timer]
OnBootSec=2min
OnUnitActiveSec=30min
Persistent=true

[Install]
WantedBy=timers.target
EOF
      systemctl --user daemon-reload
      systemctl --user enable --now claude-vps-sync.timer
      # Lingering keeps user timers running while nobody is logged in.
      loginctl enable-linger "$USER" 2>/dev/null || warn "run 'sudo loginctl enable-linger $USER' so it also runs while you are logged out"
      ok "autosync every 30 minutes"
      ;;
    off)
      systemctl --user disable --now claude-vps-sync.timer 2>/dev/null || true
      rm -f "$unit_dir"/claude-vps-sync.{service,timer}
      systemctl --user daemon-reload
      ok "autosync off"
      ;;
    *) systemctl --user list-timers claude-vps-sync.timer --no-pager 2>/dev/null || info "autosync is off" ;;
  esac
}
