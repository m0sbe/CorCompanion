#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
APP="${1:-$ROOT/dist/CorCompanion.app}"
SETTINGS="$ROOT/Config/BuildSettings.env"

while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" == \#* ]] && continue
  case "$key" in
    ARCHITECTURE|MIN_MACOS_VERSION) typeset -g "$key=$value" ;;
  esac
done < "$SETTINGS"

EXECUTABLE="$APP/Contents/MacOS/CorelCompanion"
PLIST="$APP/Contents/Info.plist"
[[ -f "$EXECUTABLE" && -f "$PLIST" ]] || {
  print -u2 "Invalid app bundle: $APP"
  exit 1
}

ARCHS=$(lipo -archs "$EXECUTABLE")
[[ "$ARCHS" == "$ARCHITECTURE" ]] || {
  print -u2 "Unexpected architectures: $ARCHS (expected only $ARCHITECTURE)"
  exit 1
}

PLIST_MIN=$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$PLIST")
[[ "$PLIST_MIN" == "$MIN_MACOS_VERSION" ]] || {
  print -u2 "Info.plist requires macOS $PLIST_MIN (expected $MIN_MACOS_VERSION)"
  exit 1
}

LOAD_MIN=$(otool -l "$EXECUTABLE" | awk '
  $1 == "cmd" && $2 == "LC_BUILD_VERSION" { in_build = 1; next }
  in_build && $1 == "minos" { print $2; exit }
')
[[ "$LOAD_MIN" == "$MIN_MACOS_VERSION" ]] || {
  print -u2 "Binary requires macOS $LOAD_MIN (expected $MIN_MACOS_VERSION)"
  exit 1
}

# Some file-provider folders restore an empty FinderInfo attribute after signing.
# It is not app content and must be stripped before signature verification.
xattr -dr com.apple.FinderInfo "$APP" 2>/dev/null || true
codesign --verify --deep --strict "$APP"
print "Compatibility OK: $ARCHITECTURE, macOS $MIN_MACOS_VERSION or newer"
