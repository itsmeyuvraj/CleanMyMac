#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "$DIR"

echo "=============================================="
echo " Building MacCleaner (Native Apple Silicon)   "
echo "=============================================="

# 1. Compile with Swift Package Manager in release mode
echo "==> Compiling Release Products..."
swift build -c release

BIN_DIR="$(swift build -c release --show-bin-path)"
APP_BUNDLE="MacCleaner.app"

echo "==> Packaging ${APP_BUNDLE}..."
rm -rf "$APP_BUNDLE"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy binary
cp "${BIN_DIR}/MacCleanerApp" "${APP_BUNDLE}/Contents/MacOS/MacCleanerApp"

# Copy Info.plist
cp "Resources/Info.plist" "${APP_BUNDLE}/Contents/Info.plist"

# Copy Icon if present
if [ -f "Resources/AppIcon.icns" ]; then
    cp "Resources/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
fi

# Ad-hoc code sign for macOS local execution
echo "==> Signing ${APP_BUNDLE}..."
codesign --force --deep --sign - "$APP_BUNDLE"

# CLI binary symlink
mkdir -p build
cp "${BIN_DIR}/mac-cleaner" "build/mac-cleaner"

echo ""
echo "=============================================="
echo " Build Succeeded!"
echo " GUI App : ${DIR}/${APP_BUNDLE}"
echo " CLI Tool: ${DIR}/build/mac-cleaner"
echo "=============================================="
echo ""
echo "To launch the GUI app: open MacCleaner.app"
echo "To run the CLI tool   : ./build/mac-cleaner --help"
echo ""
