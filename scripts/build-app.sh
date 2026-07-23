#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
cd "$ROOT"

SETTINGS="$ROOT/Config/BuildSettings.env"
if [[ ! -f "$SETTINGS" ]]; then
  print -u2 "Missing build settings: $SETTINGS"
  exit 1
fi

while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" == \#* ]] && continue
  case "$key" in
    APP_VERSION|BUILD_NUMBER|ARCHITECTURE|MIN_MACOS_VERSION)
      typeset -g "$key=$value"
      ;;
  esac
done < "$SETTINGS"

: "${APP_VERSION:?APP_VERSION is required}"
: "${BUILD_NUMBER:?BUILD_NUMBER is required}"
: "${ARCHITECTURE:?ARCHITECTURE is required}"
: "${MIN_MACOS_VERSION:?MIN_MACOS_VERSION is required}"

if [[ "$ARCHITECTURE" != "arm64" ]]; then
  print -u2 "Only arm64 releases are supported (got: $ARCHITECTURE)"
  exit 1
fi

TARGET_TRIPLE="${ARCHITECTURE}-apple-macosx${MIN_MACOS_VERSION}"
swift build -c release --triple "$TARGET_TRIPLE"
BIN_DIR=$(swift build -c release --triple "$TARGET_TRIPLE" --show-bin-path)

OUTPUT_APP="$ROOT/dist/CorCompanion.app"
BUILD_STAGE=$(mktemp -d "${TMPDIR:-/tmp}/corcompanion-app.XXXXXX")
trap 'rm -rf "$BUILD_STAGE"' EXIT
APP="$BUILD_STAGE/CorCompanion.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/CorelCompanion" "$APP/Contents/MacOS/CorelCompanion"
cp "$ROOT/Config/Info.plist" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $APP_VERSION" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :LSMinimumSystemVersion $MIN_MACOS_VERSION" "$APP/Contents/Info.plist"
if [[ -f "$ROOT/CorelCompanion/Resources/AppIcon.icns" ]]; then
  cp "$ROOT/CorelCompanion/Resources/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
fi

RESOURCE_BUNDLE=$(find "$BIN_DIR" -type d -name 'CorelCompanion_CorelCompanion.bundle' -print -quit)
if [[ -n "$RESOURCE_BUNDLE" ]]; then
  cp -R "$RESOURCE_BUNDLE" "$APP/Contents/Resources/"
fi

xattr -cr "$APP"
xattr -dr com.apple.FinderInfo "$APP" 2>/dev/null || true
codesign --force --deep --sign - "$APP"
"$ROOT/scripts/verify-compatibility.sh" "$APP"

# Copy only the already signed bundle into the file-provider-backed workspace.
rm -rf "$OUTPUT_APP"
ditto "$APP" "$OUTPUT_APP"
echo "$OUTPUT_APP"
