# Test helpers. Every test function runs in its own subshell with a temp dir and stub binaries first on PATH.

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
REPO_DIR=$ROOT
# shellcheck source=../lib/common.sh
. "$ROOT/lib/common.sh"
# shellcheck source=../lib/setup.sh
. "$ROOT/lib/setup.sh"
# shellcheck source=../lib/tailscale.sh
[[ -r $ROOT/lib/tailscale.sh ]] && . "$ROOT/lib/tailscale.sh"

fail() {
  printf '    %s\n' "$*" >&2
  : >>"$TMP/.failed"
}

assert_eq() { [[ $1 == "$2" ]] || fail "expected [$2], got [$1]"; }

# The subshell is a plain command, so set -e inside it behaves as it does in claude-vps itself.
assert_ok() {
  (set -eu -o pipefail; "$@") >>"$TMP/out" 2>&1
  local rc=$?
  [[ $rc == 0 ]] || fail "expected success (rc $rc): $*"
}

assert_fail() {
  (set -eu -o pipefail; "$@") >>"$TMP/out" 2>&1
  local rc=$?
  # 127 means the function does not exist, which must not pass as an expected failure.
  [[ $rc != 0 && $rc != 127 ]] || fail "expected failure (rc $rc): $*"
}

# Writes a fake command that logs "name args" to $STUB_LOG, then runs the given body.
stub() {
  printf '#!/usr/bin/env bash\necho "%s $*" >>"$STUB_LOG"\n%s\n' "$1" "$2" >"$STUB_DIR/$1"
  chmod +x "$STUB_DIR/$1"
}

run_tests() {
  local t failed=0 count=0
  for t in $(declare -F | awk '$3 ~ /^test_/ {print $3}'); do
    count=$((count + 1))
    # Run outside an `if`, since bash ignores set -e for everything inside a condition.
    (
      TMP=$(mktemp -d)
      STUB_DIR=$TMP/bin STUB_LOG=$TMP/stub.log QUIET=1
      export STUB_LOG
      mkdir "$STUB_DIR" && : >"$STUB_LOG"
      PATH="$STUB_DIR:$PATH"
      "$t"
      [[ ! -e $TMP/.failed ]] || { sed 's/^/    | /' "$TMP/out" 2>/dev/null >&2; exit 1; }
    )
    if (($? == 0)); then
      printf 'PASS %s\n' "$t"
    else
      printf 'FAIL %s\n' "$t"
      failed=$((failed + 1))
    fi
  done
  printf '%s: %d passed, %d failed\n' "$1" $((count - failed)) "$failed"
  ((failed == 0))
}
