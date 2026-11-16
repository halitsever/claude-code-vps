#!/usr/bin/env bash
# Bootstrap: curl -fsSL https://raw.githubusercontent.com/halitsever/claude-vps/main/install.sh | sudo bash
# Extra options go after `bash -s --`, e.g. `| sudo bash -s -- --user dev --yes`.
set -Eeuo pipefail

REPO_URL=${CLAUDE_VPS_REPO:-https://github.com/halitsever/claude-vps.git}
REPO_DIR=${CLAUDE_VPS_DIR:-/opt/claude-vps}
BRANCH=${CLAUDE_VPS_BRANCH:-main}

if [[ $EUID -ne 0 ]]; then
  echo "Run this as root: curl -fsSL <url> | sudo bash" >&2
  exit 1
fi

command -v git >/dev/null || { apt-get update -q && DEBIAN_FRONTEND=noninteractive apt-get install -y -q git ca-certificates curl; }

if [[ -d $REPO_DIR/.git ]]; then
  git -C "$REPO_DIR" pull -q --ff-only
else
  git clone -q --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"
fi

exec "$REPO_DIR/bin/claude-vps" setup "$@"
