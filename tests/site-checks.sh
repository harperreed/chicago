#!/usr/bin/env bash
# ABOUTME: Build-verification tests for the Chicago guide site.
# ABOUTME: Builds the site to a temp dir and asserts on the generated output.
set -uo pipefail
cd "$(dirname "$0")/.."

OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT

# Tailwind output is gitignored; build it if missing so hugo can find it.
if [ ! -f assets/css/tailwind-output.css ]; then
  npx tailwindcss -i ./assets/css/tailwind-input.css -o ./assets/css/tailwind-output.css --minify
fi

if ! hugo --quiet --destination "$OUT"; then
  echo "FAIL: hugo build failed"
  exit 1
fi

PASS=0
FAIL=0

# check <desc> <file-glob relative to OUT> <fixed-string>
check() {
  local desc="$1" file="$2" pattern="$3"
  # shellcheck disable=SC2086 # glob expansion is intentional
  if cat $OUT/$file 2>/dev/null | grep -qF -- "$pattern"; then
    echo "ok: $desc"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $desc ('$pattern' not found in $file)"
    FAIL=$((FAIL + 1))
  fi
}

# check_re <desc> <file-glob relative to OUT> <extended-regex>
check_re() {
  local desc="$1" file="$2" pattern="$3"
  # shellcheck disable=SC2086
  if cat $OUT/$file 2>/dev/null | grep -qE -- "$pattern"; then
    echo "ok: $desc"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $desc (regex '$pattern' not matched in $file)"
    FAIL=$((FAIL + 1))
  fi
}

# check_file <desc> <file relative to OUT>
check_file() {
  local desc="$1" file="$2"
  if [ -f "$OUT/$file" ]; then
    echo "ok: $desc"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $desc ($file missing)"
    FAIL=$((FAIL + 1))
  fi
}

# --- baseline ---
check_file "homepage builds" "index.html"
check "site title present" "index.html" "Harper&#39;s Incomplete Chicago Guide"

echo ""
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
