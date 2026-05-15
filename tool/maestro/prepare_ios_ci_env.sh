#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FLAVOR="${FLAVOR:-development}"
IOS_DIR="$ROOT_DIR/ios/$FLAVOR"

decode_base64() {
  if base64 --help 2>&1 | grep -q -- '--decode'; then
    base64 --decode
  else
    base64 -D
  fi
}

write_secret_file() {
  local content="$1"
  local output_path="$2"
  local temp_path
  temp_path="$(mktemp)"

  if printf '%s' "$content" | decode_base64 >"$temp_path" 2>/dev/null; then
    mv "$temp_path" "$output_path"
    return
  fi

  rm -f "$temp_path"
  printf '%s' "$content" >"$output_path"
}

: "${FIREBASE_INFO:?FIREBASE_INFO is required}"
: "${GOOGLE_SERVICE_INFO_PLIST:?GOOGLE_SERVICE_INFO_PLIST is required}"
: "${FIREBASE_OPTIONS:?FIREBASE_OPTIONS is required}"
: "${FIREBASE_APP_ID:?FIREBASE_APP_ID is required}"

mkdir -p "$IOS_DIR"

printf '%s' "$FIREBASE_INFO" > "$IOS_DIR/firebase.json"
write_secret_file "$GOOGLE_SERVICE_INFO_PLIST" "$IOS_DIR/GoogleService-Info.plist"
write_secret_file "$FIREBASE_OPTIONS" "$ROOT_DIR/lib/firebase_options.dart"
printf 'FIREBASE_APP_ID=%s\n' "$FIREBASE_APP_ID" > "$ROOT_DIR/ios/.env"
