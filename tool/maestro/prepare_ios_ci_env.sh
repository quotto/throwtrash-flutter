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

: "${GOOGLE_SERVICE_INFO_PLIST:?GOOGLE_SERVICE_INFO_PLIST is required}"
FIREBASE_APP_ID="${FIREBASE_APP_ID:-local-e2e-placeholder}"
PLIST_BUDDY_BIN="/usr/libexec/PlistBuddy"

mkdir -p "$IOS_DIR"

write_secret_file "$GOOGLE_SERVICE_INFO_PLIST" "$IOS_DIR/GoogleService-Info.plist"

if [[ -n "${FIREBASE_INFO:-}" ]]; then
  printf '%s' "$FIREBASE_INFO" > "$IOS_DIR/firebase.json"
else
  PROJECT_ID="$("$PLIST_BUDDY_BIN" -c 'Print :PROJECT_ID' "$IOS_DIR/GoogleService-Info.plist")"
  GOOGLE_APP_ID="$("$PLIST_BUDDY_BIN" -c 'Print :GOOGLE_APP_ID' "$IOS_DIR/GoogleService-Info.plist")"
  export PROJECT_ID GOOGLE_APP_ID
  python3 - <<'PY' > "$IOS_DIR/firebase.json"
import json
import os

print(json.dumps({
    "flutter": {
        "platforms": {
            "ios": {
                "default": {
                    "projectId": os.environ["PROJECT_ID"],
                    "appId": os.environ["GOOGLE_APP_ID"],
                    "uploadDebugSymbols": True,
                    "fileOutput": "ios/Runner/GoogleService-Info.plist",
                },
            },
            "dart": {
                "lib/firebase_options.dart": {
                    "projectId": os.environ["PROJECT_ID"],
                    "configurations": {
                        "ios": os.environ["GOOGLE_APP_ID"],
                    },
                },
            },
        },
    },
}))
PY
fi

if [[ -n "${FIREBASE_OPTIONS:-}" ]]; then
  write_secret_file "$FIREBASE_OPTIONS" "$ROOT_DIR/lib/firebase_options.dart"
fi

printf 'FIREBASE_APP_ID=%s\n' "$FIREBASE_APP_ID" > "$ROOT_DIR/ios/.env"
