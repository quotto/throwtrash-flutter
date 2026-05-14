#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FLAVOR="${FLAVOR:-development}"
IOS_DIR="$ROOT_DIR/ios/$FLAVOR"
APP_ID="${APP_ID:-net.mythrowaway.dev}"

fail() {
  local message="$1"
  echo "::error file=tool/maestro/prepare_ios_ci_env.sh::$message" >&2
  echo "$message" >&2
  exit 1
}

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    fail "$name is required"
  fi
}

write_placeholder_plist() {
  cat <<EOF >"$1"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>API_KEY</key>
  <string>local-e2e-placeholder</string>
  <key>GCM_SENDER_ID</key>
  <string>000000000000</string>
  <key>PLIST_VERSION</key>
  <string>1</string>
  <key>BUNDLE_ID</key>
  <string>$APP_ID</string>
  <key>PROJECT_ID</key>
  <string>throwtrash-e2e</string>
  <key>STORAGE_BUCKET</key>
  <string>throwtrash-e2e.appspot.com</string>
  <key>IS_ADS_ENABLED</key>
  <false/>
  <key>IS_ANALYTICS_ENABLED</key>
  <false/>
  <key>IS_APPINVITE_ENABLED</key>
  <false/>
  <key>IS_GCM_ENABLED</key>
  <false/>
  <key>IS_SIGNIN_ENABLED</key>
  <false/>
  <key>GOOGLE_APP_ID</key>
  <string>${FIREBASE_APP_ID}</string>
</dict>
</plist>
EOF
}

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

FIREBASE_APP_ID="${FIREBASE_APP_ID:-local-e2e-placeholder}"
PLIST_BUDDY_BIN="/usr/libexec/PlistBuddy"

mkdir -p "$IOS_DIR"

if [[ -n "${GOOGLE_SERVICE_INFO_PLIST:-}" ]]; then
  write_secret_file "$GOOGLE_SERVICE_INFO_PLIST" "$IOS_DIR/GoogleService-Info.plist"
else
  write_placeholder_plist "$IOS_DIR/GoogleService-Info.plist"
fi

if [[ -n "${FIREBASE_INFO:-}" ]]; then
  printf '%s' "$FIREBASE_INFO" > "$IOS_DIR/firebase.json"
else
  PROJECT_ID="$("$PLIST_BUDDY_BIN" -c 'Print :PROJECT_ID' "$IOS_DIR/GoogleService-Info.plist" 2>/dev/null)" || fail "PROJECT_ID was not found in GoogleService-Info.plist"
  GOOGLE_APP_ID="$("$PLIST_BUDDY_BIN" -c 'Print :GOOGLE_APP_ID' "$IOS_DIR/GoogleService-Info.plist" 2>/dev/null)" || fail "GOOGLE_APP_ID was not found in GoogleService-Info.plist"
  export PROJECT_ID GOOGLE_APP_ID
  python3 - <<'PY' > "$IOS_DIR/firebase.json"
import json
import os

project_id = os.environ["PROJECT_ID"]
google_app_id = os.environ["GOOGLE_APP_ID"]

print(json.dumps({
    "flutter": {
        "platforms": {
            "ios": {
                "default": {
                    "projectId": project_id,
                    "appId": google_app_id,
                    "uploadDebugSymbols": True,
                    "fileOutput": "ios/Runner/GoogleService-Info.plist",
                },
            },
            "dart": {
                "lib/firebase_options.dart": {
                    "projectId": project_id,
                    "configurations": {
                        "ios": google_app_id,
                    },
                },
            },
        },
    },
}))
PY
fi

printf 'FIREBASE_APP_ID=%s\n' "$FIREBASE_APP_ID" > "$ROOT_DIR/ios/.env"
