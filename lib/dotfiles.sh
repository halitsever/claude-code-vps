# Moving config between your machine, this repo and the server.

MANIFEST=$REPO_DIR/dotfiles/manifest.txt
STORE=$REPO_DIR/dotfiles/home

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
  if git -C "$REPO_DIR" rev-parse >/dev/null 2>&1; then
    git -C "$REPO_DIR" status --short -- dotfiles | sed 's/^/  /'
  fi
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
  if ((changed)); then
    ok "$changed files updated, old copies in ${backup/#$HOME/\~}"
    info "log out of the desktop and back in to see KDE changes"
  else
    ok "already up to date"
  fi
}

cmd_sync() {
  log "Pulling $(git -C "$REPO_DIR" remote get-url origin 2>/dev/null || echo repo)"
  git -C "$REPO_DIR" pull -q --ff-only
  cmd_apply
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
