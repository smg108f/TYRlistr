#!/bin/bash
# Build TYRlistr.app and an ad-hoc signed DMG.
# Run on a Mac (macOS 14+) with Xcode or the Command Line Tools installed:
#
#   scripts/package-macos.sh            # version 0.2
#   VERSION=0.3 scripts/package-macos.sh
#
# Output goes to dist/: TYRlistr.app, TYRlistr-<version>.dmg and its .sha256.
# The app is ad-hoc signed, not notarized, so macOS asks people to approve it
# under System Settings > Privacy & Security the first time they open it.

set -euo pipefail

VERSION="${VERSION:-0.2}"
BUNDLE_ID="io.github.smg108f.tyrlistr"
MIN_MACOS="14.0"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
APP="$DIST/TYRlistr.app"
cd "$ROOT"

BUILD="$(git rev-list --count HEAD 2>/dev/null || echo 1)"

echo "==> Building TYRlistr $VERSION ($BUILD)"
# A universal (Apple Silicon + Intel) build needs full Xcode; fall back to this Mac's architecture.
if swift build -c release --arch arm64 --arch x86_64; then
    BIN_DIR="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)"
else
    echo "==> Universal build failed (it needs full Xcode). Building for $(uname -m) only."
    swift build -c release
    BIN_DIR="$(swift build -c release --show-bin-path)"
fi

echo "==> Assembling $APP"
rm -rf "$DIST"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/TYRlistr" "$APP/Contents/MacOS/TYRlistr"

ICON_KEY=""
if [ -f "$ROOT/assets/AppIcon.png" ]; then
    ICONSET="$DIST/AppIcon.iconset"
    mkdir -p "$ICONSET"
    for size in 16 32 128 256 512; do
        sips -z $size $size "$ROOT/assets/AppIcon.png" --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
        double=$((size * 2))
        sips -z $double $double "$ROOT/assets/AppIcon.png" --out "$ICONSET/icon_${size}x${size}@2x.png" >/dev/null
    done
    iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
    rm -rf "$ICONSET"
    ICON_KEY="<key>CFBundleIconFile</key><string>AppIcon</string>"
fi

cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>TYRlistr</string>
    <key>CFBundleDisplayName</key><string>TYRlistr</string>
    <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
    <key>CFBundleExecutable</key><string>TYRlistr</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>$VERSION</string>
    <key>CFBundleVersion</key><string>$BUILD</string>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>LSMinimumSystemVersion</key><string>$MIN_MACOS</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.productivity</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSHumanReadableCopyright</key><string>© smg108f. Licensed under the GNU AGPL v3 or later.</string>
    $ICON_KEY
</dict>
</plist>
EOF
plutil -lint "$APP/Contents/Info.plist" >/dev/null

echo "==> Ad-hoc signing"
codesign --force --sign - "$APP"
codesign --verify --strict "$APP"

echo "==> Making the DMG"
STAGE="$DIST/dmg"
mkdir -p "$STAGE"
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
DMG="$DIST/TYRlistr-$VERSION.dmg"
hdiutil create -volname "TYRlistr $VERSION" -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null
rm -rf "$STAGE"

(cd "$DIST" && shasum -a 256 "$(basename "$DMG")" > "$(basename "$DMG").sha256")

echo
echo "Done:"
echo "  $DMG"
cat "$DMG.sha256"
