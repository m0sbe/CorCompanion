#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
APP="$ROOT/dist/CorCompanion.app"
DMG="$ROOT/dist/CorCompanion.dmg"
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/corcompanion-dmg.XXXXXX")
trap 'rm -rf "$STAGE"' EXIT

[[ -d "$APP" ]] || "$ROOT/scripts/build-app.sh"
ditto "$APP" "$STAGE/CorCompanion.app"
ln -sfn /Applications "$STAGE/Applications"

# The workspace may be backed by a file provider that attaches Finder metadata
# after build-app.sh finishes. Strip it and create the final signature in
# the local staging directory so the app stored inside the DMG stays valid.
xattr -cr "$STAGE/CorCompanion.app"
xattr -dr com.apple.FinderInfo "$STAGE/CorCompanion.app" 2>/dev/null || true
codesign --force --deep --sign - "$STAGE/CorCompanion.app"
"$ROOT/scripts/verify-compatibility.sh" "$STAGE/CorCompanion.app"

hdiutil create -volname "CorCompanion" -srcfolder "$STAGE" -ov -format UDZO "$DMG"
echo "$DMG"
