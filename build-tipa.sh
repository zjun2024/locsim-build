#!/usr/bin/env bash
#
# Build the trimmed LocSim tree into an installable .tipa.
#   macOS + Xcode 15 + ldid (brew install ldid)
#
#   ./build-tipa.sh
#
# Output: build/LocSim.tipa  ->  payload/Geranium.app
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME=Geranium
SCHEME=Geranium
PROJECT=LocSimOnly.xcodeproj
CONFIG=Release
OUT=build
TIP_NAME=LocSim

command -v xcodebuild >/dev/null 2>&1 || { echo "xcodebuild not found (need macOS + Xcode 15)" >&2; exit 1; }
command -v ldid >/dev/null 2>&1 || { echo "ldid not found (brew install ldid)" >&2; exit 1; }

rm -rf "$OUT"
mkdir -p "$OUT"

xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -derivedDataPath "$OUT/DerivedData" \
    -destination 'generic/platform=iOS' \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    build

APP_SRC="$OUT/DerivedData/Build/Products/$CONFIG-iphoneos/$APP_NAME.app"
[ -d "$APP_SRC" ] || { echo "build product missing: $APP_SRC" >&2; exit 1; }

APP_DST="$OUT/$APP_NAME.app"
rm -rf "$APP_DST"
cp -R "$APP_SRC" "$APP_DST"

# No Apple signing material: TrollStore installs and ad-hoc-signs itself.
rm -rf "$APP_DST/_CodeSignature" "$APP_DST/embedded.mobileprovision"

# Install the app entitlements (com.apple.locationd.simulation lives here).
ldid -S"entitlements.plist" "$APP_DST/$APP_NAME"

# The bundled root helper gets the same file access + platform entitlements.
if [ -f "$APP_DST/GeraniumRootHelper" ]; then
    chmod 755 "$APP_DST/GeraniumRootHelper"
    ldid -S"entitlements.plist" "$APP_DST/GeraniumRootHelper"
fi

rm -rf Payload
mkdir -p Payload
cp -R "$APP_DST" "Payload/$APP_NAME.app"
rm -f "$OUT/$TIP_NAME.tipa"
(cd Payload && zip -qry "../$OUT/$TIP_NAME.tipa" "$APP_NAME.app")
rm -rf Payload

echo
echo "built: $(pwd)/$OUT/$TIP_NAME.tipa"
echo "check: ldid -e $OUT/$APP_NAME.app/$APP_NAME | grep locationd"
