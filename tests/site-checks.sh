#!/usr/bin/env bash
# ABOUTME: Build-verification tests for the Chicago guide site.
# ABOUTME: Builds the site to a temp dir and asserts on the generated output.
set -uo pipefail
cd "$(dirname "$0")/.." || { echo "FAIL: cannot cd to repo root"; exit 1; }

OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT

# Tailwind output is gitignored; build it if missing so hugo can find it.
if [ ! -f assets/css/tailwind-output.css ]; then
  npx tailwindcss -i ./assets/css/tailwind-input.css -o ./assets/css/tailwind-output.css --minify
fi

# Isolate hugo's caches per run so concurrent builds can't race each other.
if ! HUGO_CACHEDIR="$OUT/hugo-cache" HUGO_RESOURCEDIR="$OUT/hugo-resources" hugo --quiet --destination "$OUT"; then
  echo "FAIL: hugo build failed"
  exit 1
fi

PASS=0
FAIL=0

# check <desc> <file-glob relative to OUT> <fixed-string>
check() {
  local desc="$1" file="$2" pattern="$3"
  # shellcheck disable=SC2206 # glob expansion is intentional
  local files=($OUT/$file)
  if [ ! -e "${files[0]}" ]; then
    echo "FAIL: $desc (no files matched '$file')"
    FAIL=$((FAIL + 1))
    return
  fi
  if grep -qF -- "$pattern" "${files[@]}"; then
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
  # shellcheck disable=SC2206 # glob expansion is intentional
  local files=($OUT/$file)
  if [ ! -e "${files[0]}" ]; then
    echo "FAIL: $desc (no files matched '$file')"
    FAIL=$((FAIL + 1))
    return
  fi
  if grep -qE -- "$pattern" "${files[@]}"; then
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

# --- robots + sitemap ---
check_re "robots.txt allows all crawlers" "robots.txt" "^Disallow: *$"
check "robots.txt references sitemap" "robots.txt" "Sitemap: https://chicago.harperreed.com/sitemap.xml"
check_file "sitemap generated" "sitemap.xml"

# --- sticky nav / scrolling ---
check "anchored headings clear sticky nav" "css/bundle.*.css" "scroll-margin-top"

# --- tinylytics graceful degradation ---
check "tinylytics line hidden when empty" "css/bundle.*.css" ":has(.tinylytics_hits:empty)"
check "tinylytics kudos button hidden when empty" "css/bundle.*.css" "tinylytics_kudos:empty"

echo ""
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
