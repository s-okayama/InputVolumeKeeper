#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="InputVolumeKeeper"
BUILD_DIR="$SCRIPT_DIR/build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

rm -rf "$BUILD_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$SCRIPT_DIR/Resources/Info.plist" "$APP_BUNDLE/Contents/"
cp "$SCRIPT_DIR/Resources/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"

swiftc -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    -framework Cocoa \
    -framework Carbon \
    "$SCRIPT_DIR/Sources/main.swift"

echo "Build complete: $APP_BUNDLE"

pkill -f "$APP_NAME.app" 2>/dev/null || true
sleep 1

rm -rf "/Applications/$APP_NAME.app"
cp -r "$APP_BUNDLE" /Applications/

echo "Installed to /Applications/$APP_NAME.app"
