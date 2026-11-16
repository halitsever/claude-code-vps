# Shared helpers for every claude-vps command.

if [[ -t 1 ]]; then
  C_RESET=$'\e[0m' C_DIM=$'\e[2m' C_BOLD=$'\e[1m'
  C_ACCENT=$'\e[38;5;209m' C_OK=$'\e[32m' C_WARN=$'\e[33m' C_ERR=$'\e[31m'
else
  C_RESET='' C_DIM='' C_BOLD='' C_ACCENT='' C_OK='' C_WARN='' C_ERR=''
fi

DRY_RUN=${DRY_RUN:-0}
QUIET=${QUIET:-0}

log() { [[ $QUIET == 1 ]] || printf '%s==>%s %s\n' "$C_ACCENT" "$C_RESET" "$*"; }
ok() { [[ $QUIET == 1 ]] || printf '  %s✓%s %s\n' "$C_OK" "$C_RESET" "$*"; }
info() { [[ $QUIET == 1 ]] || printf '  %s%s%s\n' "$C_DIM" "$*" "$C_RESET"; }
warn() { printf '  %s!%s %s\n' "$C_WARN" "$C_RESET" "$*" >&2; }
die() { printf '%serror:%s %s\n' "$C_ERR" "$C_RESET" "$*" >&2; exit 1; }

run() {
  if [[ $DRY_RUN == 1 ]]; then
    printf '  %s$ %s%s\n' "$C_DIM" "$*" "$C_RESET"
  else
    "$@"
  fi
}

has() { command -v "$1" >/dev/null 2>&1; }

# Reads from the terminal, since stdin is the script itself under curl | bash.
ask() {
  local prompt=$1 default=${2:-} reply
  if [[ ! -r /dev/tty ]]; then
    printf '%s' "$default"
    return
  fi
  read -r -p "$prompt${default:+ [$default]}: " reply </dev/tty
  printf '%s' "${reply:-$default}"
}

ask_secret() {
  local prompt=$1 reply
  read -r -s -p "$prompt: " reply </dev/tty
  printf '\n' >/dev/tty
  printf '%s' "$reply"
}

apt_install() {
  run env DEBIAN_FRONTEND=noninteractive apt-get install -y -q "$@"
}

# Keeps only packages this Ubuntu release actually ships.
apt_available() {
  local pkg out=()
  for pkg in "$@"; do
    apt-cache show "$pkg" >/dev/null 2>&1 && out+=("$pkg")
  done
  [[ ${#out[@]} -eq 0 ]] || printf '%s\n' "${out[@]}"
}

as_user() {
  run runuser -l "$TARGET_USER" -c "$1"
}

user_home() { getent passwd "$1" | cut -d: -f6; }
