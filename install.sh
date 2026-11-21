#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
APP="KalimaDaily"
BUNDLE="build/$APP.app"

echo "==> Building (release)"
swift build -c release
BIN="$(swift build -c release --show-bin-path)/$APP"

echo "==> Making icon"
rm -rf build && mkdir -p build/AppIcon.iconset "$BUNDLE/Contents/MacOS" "$BUNDLE/Contents/Resources"
swift scripts/icon.swift build/icon.png
for s in 16 32 128 256 512; do
  sips -z $s $s build/icon.png --out build/AppIcon.iconset/icon_${s}x${s}.png >/dev/null
  sips -z $((s*2)) $((s*2)) build/icon.png --out build/AppIcon.iconset/icon_${s}x${s}@2x.png >/dev/null
done
iconutil -c icns build/AppIcon.iconset -o "$BUNDLE/Contents/Resources/AppIcon.icns"

echo "==> Assembling app bundle"
cp "$BIN" "$BUNDLE/Contents/MacOS/$APP"
cat > "$BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleName</key><string>Kalima Daily</string>
<key>CFBundleDisplayName</key><string>Kalima Daily</string>
<key>CFBundleIdentifier</key><string>com.kalima.daily</string>
<key>CFBundleExecutable</key><string>KalimaDaily</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>1.0</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSMinimumSystemVersion</key><string>13.0</string>
<key>NSHighResolutionCapable</key><true/>
<key>NSPrincipalClass</key><string>NSApplication</string>
</dict></plist>
PLIST
codesign --force --deep --sign - "$BUNDLE"

echo "==> Installing to /Applications"
pkill -x "$APP" 2>/dev/null || true
rm -rf "/Applications/$APP.app"
cp -R "$BUNDLE" "/Applications/$APP.app"

echo "==> Desktop shortcut"
rm -f "$HOME/Desktop/$APP.app"
ln -s "/Applications/$APP.app" "$HOME/Desktop/$APP.app"

echo "==> Launching"
open "/Applications/$APP.app"
