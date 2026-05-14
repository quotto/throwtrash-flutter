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

: "${FIREBASE_INFO:?FIREBASE_INFO is required}"
: "${GOOGLE_SERVICE_INFO_PLIST:?GOOGLE_SERVICE_INFO_PLIST is required}"
FIREBASE_APP_ID="${FIREBASE_APP_ID:-local-e2e-placeholder}"

mkdir -p "$IOS_DIR"

printf '%s' "$FIREBASE_INFO" > "$IOS_DIR/firebase.json"
printf '%s' "$GOOGLE_SERVICE_INFO_PLIST" | decode_base64 > "$IOS_DIR/GoogleService-Info.plist"
printf 'FIREBASE_APP_ID=%s\n' "$FIREBASE_APP_ID" > "$ROOT_DIR/ios/.env"
