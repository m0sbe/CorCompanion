#!/bin/zsh
set -euo pipefail

ROOT="${0:A:h:h}"
DMG="$ROOT/dist/CorCompanion.dmg"
CHECKSUM="$DMG.sha256"

"$ROOT/scripts/build-app.sh"
"$ROOT/scripts/create-dmg.sh"

cd "$ROOT/dist"
shasum -a 256 "${DMG:t}" > "${CHECKSUM:t}"

print "GitHub release artifacts:"
print "  $DMG"
print "  $CHECKSUM"
print "SHA-256: $(awk '{ print $1 }' "$CHECKSUM")"
