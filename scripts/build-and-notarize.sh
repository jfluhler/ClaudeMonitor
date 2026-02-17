#!/bin/bash
set -euo pipefail

# ClaudeMonitor — Build, Archive, Export & Notarize
#
# PREREQUISITES (one-time setup):
#
#   1. "Developer ID Application" certificate installed in Keychain
#
#   2. App Store Connect API key credentials stored for notarytool:
#         xcrun notarytool store-credentials "ClaudeMonitor-notarize" \
#           --key "/path/to/AuthKey_XXXXXX.p8" \
#           --key-id "YOUR_KEY_ID" \
#           --issuer "YOUR_ISSUER_ID"

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVE_PATH="$PROJECT_DIR/build/ClaudeMonitor.xcarchive"
EXPORT_DIR="$PROJECT_DIR/build/export"
KEYCHAIN_PROFILE="ClaudeMonitor-notarize"
TEAM_ID="T58N9R3B7C"

# Verify Developer ID cert exists
if ! security find-identity -v -p codesigning | grep -q "Developer ID Application"; then
    echo "ERROR: No 'Developer ID Application' certificate found."
    echo "Create one at: https://developer.apple.com/account/resources/certificates/add"
    echo ""
    echo "For local dev builds without notarization, just run:"
    echo "  xcodebuild -project ClaudeMon.xcodeproj -scheme ClaudeMon build"
    exit 1
fi

echo "==> Cleaning..."
rm -rf "$PROJECT_DIR/build"

echo "==> Archiving..."
xcodebuild archive \
  -project "$PROJECT_DIR/ClaudeMon.xcodeproj" \
  -scheme ClaudeMon \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  ENABLE_HARDENED_RUNTIME=YES \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="Developer ID Application" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  PROVISIONING_PROFILE_SPECIFIER="" \
  | tail -5

echo "==> Exporting..."
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_DIR" \
  -exportOptionsPlist "$PROJECT_DIR/ExportOptions.plist" \
  | tail -5

APP_PATH="$EXPORT_DIR/ClaudeMonitor.app"

if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: Exported app not found at $APP_PATH"
  exit 1
fi

ZIP_PATH="$EXPORT_DIR/ClaudeMonitor.zip"

echo "==> Zipping for notarization..."
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

echo "==> Submitting for notarization..."
xcrun notarytool submit "$ZIP_PATH" \
  --keychain-profile "$KEYCHAIN_PROFILE" \
  --wait

echo "==> Stapling notarization ticket..."
xcrun stapler staple "$APP_PATH"

echo ""
echo "==> Done! Notarized app at:"
echo "    $APP_PATH"
echo ""
echo "To install:"
echo "    cp -R \"$APP_PATH\" /Applications/"
echo ""
echo "To distribute as DMG:"
echo "    hdiutil create -volname ClaudeMonitor -srcfolder \"$APP_PATH\" -ov -format UDZO build/ClaudeMonitor.dmg"
