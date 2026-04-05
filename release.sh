#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Grid Clock Screensaver — build, notarize, and package for release
#
# Usage:
#   ./release.sh <version> <apple-id> <app-specific-password>
#
# Example:
#   ./release.sh 1.0.0 you@example.com xxxx-xxxx-xxxx-xxxx
# ---------------------------------------------------------------------------

VERSION="${1:?Usage: $0 <version> <apple-id> <app-specific-password>}"
APPLE_ID="${2:?Usage: $0 <version> <apple-id> <app-specific-password>}"
APP_PASSWORD="${3:?Usage: $0 <version> <apple-id> <app-specific-password>}"

TEAM_ID="9YVVV2SNR4"
SCHEME="Grid Clock"
PROJECT="Grid Clock.xcodeproj"
ARCHIVE_PATH="./build/GridClock.xcarchive"
EXPORT_PATH="./build/export"
SAVER_PATH="$EXPORT_PATH/Grid Clock.saver"
ZIP_PATH="./build/GridClock-${VERSION}.saver.zip"

echo "==> Cleaning build directory"
rm -rf ./build
mkdir -p ./build

echo "==> Archiving (version $VERSION)"
xcodebuild archive \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -archivePath "$ARCHIVE_PATH" \
  CURRENT_PROJECT_VERSION="$VERSION" \
  MARKETING_VERSION="$VERSION"

echo "==> Exporting with Developer ID"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist ExportOptions.plist

echo "==> Submitting for notarization"
xcrun notarytool submit "$SAVER_PATH" \
  --apple-id "$APPLE_ID" \
  --password "$APP_PASSWORD" \
  --team-id "$TEAM_ID" \
  --wait

echo "==> Stapling notarization ticket"
xcrun stapler staple "$SAVER_PATH"

echo "==> Zipping for distribution"
ditto -c -k --keepParent "$SAVER_PATH" "$ZIP_PATH"

echo ""
echo "Done: $ZIP_PATH"
echo "Upload this file to a GitHub Release tagged v${VERSION}"
