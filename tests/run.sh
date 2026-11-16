#!/usr/bin/env bash
# Runs every tests/test_*.sh, each file in its own shell. Usage: bash tests/run.sh
cd "$(dirname "$0")/.." || exit 1
status=0
for f in tests/test_*.sh; do
  bash -c '. tests/lib.sh; . "$1"; run_tests "$1"' _ "$f" || status=1
done
exit "$status"
