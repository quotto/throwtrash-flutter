#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FLAVOR="${FLAVOR:-development}"
APP_ID="${APP_ID:-net.mythrowaway.dev}"
REPORT_DIR="${REPORT_DIR:-$ROOT_DIR/.maestro-results}"
FLOW_DIR="${FLOW_DIR:-$ROOT_DIR/maestro/flows/scenarios}"
TMPDIR="${TMPDIR:-$ROOT_DIR/.tmp}"
DERIVED_DATA_DIR="${DERIVED_DATA_DIR:-$ROOT_DIR/.derived-data}"
XCODEBUILD_LOG="${XCODEBUILD_LOG:-$TMPDIR/xcodebuild-$FLAVOR.log}"
IB_SUPPORT_DIR="${IB_SUPPORT_DIR:-$ROOT_DIR/.e2e-home/Library/Developer/Xcode/UserData/IB Support}"
MAESTRO_DRIVER_STARTUP_TIMEOUT="${MAESTRO_DRIVER_STARTUP_TIMEOUT:-180000}"
ALARM_API_KEY="${ALARM_API_KEY:-local-e2e-placeholder}"
TRASH_SEARCH_API_KEY="${TRASH_SEARCH_API_KEY:-}"
PREFERRED_IOS_MAJOR="${PREFERRED_IOS_MAJOR:-18}"
MAESTRO_BIN="$(command -v maestro)"
POD_BIN="$(command -v pod)"
XCODEBUILD_BIN="$(command -v xcodebuild)"
if command -v fvm >/dev/null 2>&1; then
  FLUTTER_CMD=(fvm flutter)
elif command -v flutter >/dev/null 2>&1; then
  FLUTTER_CMD=(flutter)
else
  echo "flutter command was not found" >&2
  exit 1
fi
GOOGLE_SERVICE_INFO_PLIST_PATH="$ROOT_DIR/ios/$FLAVOR/GoogleService-Info.plist"
FIREBASE_INFO_PATH="$ROOT_DIR/ios/$FLAVOR/firebase.json"

mkdir -p \
  "$REPORT_DIR/debug" \
  "$REPORT_DIR/artifacts" \
  "$TMPDIR" \
  "$DERIVED_DATA_DIR" \
  "$IB_SUPPORT_DIR"
export TMPDIR
export MAESTRO_DRIVER_STARTUP_TIMEOUT

if [[ -d "${HOME:-}/Library/Developer/CoreSimulator/Devices" ]]; then
  ln -sfn "$HOME/Library/Developer/CoreSimulator/Devices" "$IB_SUPPORT_DIR/Simulator Devices"
fi

if [[ ! -f "$ROOT_DIR/ios/.env" ]]; then
  echo "ios/.env is required" >&2
  exit 1
fi

if [[ ! -f "$GOOGLE_SERVICE_INFO_PLIST_PATH" ]]; then
  echo "ios/$FLAVOR/GoogleService-Info.plist is required" >&2
  exit 1
fi

if [[ ! -f "$FIREBASE_INFO_PATH" ]]; then
  echo "ios/$FLAVOR/firebase.json is required" >&2
  exit 1
fi

if ! grep -q '<key>API_KEY</key>' "$GOOGLE_SERVICE_INFO_PLIST_PATH"; then
  echo "ios/$FLAVOR/GoogleService-Info.plist must contain API_KEY" >&2
  exit 1
fi

if grep -q '<string>local-e2e-placeholder</string>' "$GOOGLE_SERVICE_INFO_PLIST_PATH"; then
  echo "ios/$FLAVOR/GoogleService-Info.plist contains placeholder API_KEY; restore a real Firebase config before running Maestro E2E" >&2
  exit 1
fi

if [[ "$(tr -d '[:space:]' < "$FIREBASE_INFO_PATH")" == "{}" ]]; then
  echo "ios/$FLAVOR/firebase.json is empty; restore a real Firebase config before running Maestro E2E" >&2
  exit 1
fi

resolve_simulator_id() {
  if [[ -n "${SIMULATOR_ID:-}" ]]; then
    echo "$SIMULATOR_ID"
    return
  fi

  local preferred_id
  preferred_id="$(
    xcrun simctl list devices available | awk -F '[()]' -v major="$PREFERRED_IOS_MAJOR" '
      /iPhone/ && $0 !~ /unavailable/ && $2 ~ ("^" major "\\.") { print $4; exit }
    '
  )"
  if [[ -n "$preferred_id" ]]; then
    echo "$preferred_id"
    return
  fi

  preferred_id="$(
    xcrun simctl list devices available | awk -F '[()]' '
      /iPhone/ && $0 !~ /unavailable/ && $2 ~ /^17\./ { print $4; exit }
    '
  )"
  if [[ -n "$preferred_id" ]]; then
    echo "$preferred_id"
    return
  fi

  xcrun simctl list devices available | awk -F '[()]' '/iPhone/ && $0 !~ /unavailable/ { print $4; exit }'
}

SIMULATOR_ID="$(resolve_simulator_id)"
if [[ -z "$SIMULATOR_ID" ]]; then
  echo "available iPhone simulator was not found" >&2
  exit 1
fi

while IFS= read -r booted_id; do
  if [[ -n "$booted_id" && "$booted_id" != "$SIMULATOR_ID" ]]; then
    xcrun simctl shutdown "$booted_id" >/dev/null 2>&1 || true
  fi
done < <(xcrun simctl list devices available | awk -F '[()]' '/Booted/ { print $2 }')

xcrun simctl bootstatus "$SIMULATOR_ID" -b >/dev/null 2>&1 || {
  xcrun simctl boot "$SIMULATOR_ID"
  xcrun simctl bootstatus "$SIMULATOR_ID" -b
}
open -a Simulator --args -CurrentDeviceUDID "$SIMULATOR_ID" >/dev/null 2>&1 || true

"${FLUTTER_CMD[@]}" pub get
(
  cd "$ROOT_DIR/ios"
  "$POD_BIN" install
)

# flutter build ios は環境によって停止することがあるため、xcodebuild を直接利用する。
"$XCODEBUILD_BIN" \
  -workspace "$ROOT_DIR/ios/Runner.xcworkspace" \
  -scheme "$FLAVOR" \
  -configuration "Debug-$FLAVOR" \
  -sdk iphonesimulator \
  -destination "id=$SIMULATOR_ID" \
  -derivedDataPath "$DERIVED_DATA_DIR" \
  FLAVOR="$FLAVOR" \
  TARGETED_DEVICE_FAMILY=1 \
  build >"$XCODEBUILD_LOG" 2>&1 || {
    tail -200 "$XCODEBUILD_LOG" >&2
    exit 1
  }

APP_PATH="$DERIVED_DATA_DIR/Build/Products/Debug-$FLAVOR-iphonesimulator/Runner.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Runner.app was not found at $APP_PATH" >&2
  exit 1
fi

xcrun simctl uninstall "$SIMULATOR_ID" "$APP_ID" >/dev/null 2>&1 || true
xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"

CURRENT_MONTH_LABEL="$(date '+%Y年%-m月')"

"$MAESTRO_BIN" test \
  "$FLOW_DIR" \
  --format JUNIT \
  --output "$REPORT_DIR/junit.xml" \
  --debug-output "$REPORT_DIR/debug" \
  --flatten-debug-output \
  --test-output-dir "$REPORT_DIR/artifacts" \
  --udid "$SIMULATOR_ID" \
  -e APP_ID="$APP_ID" \
  -e CURRENT_MONTH_LABEL="$CURRENT_MONTH_LABEL"
