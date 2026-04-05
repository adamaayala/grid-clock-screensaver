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
#
# Get an app-specific password at appleid.apple.com
# ---------------------------------------------------------------------------

VERSION="${1:?Usage: $0 <version> <apple-id> <app-specific-password>}"
APPLE_ID="${2:?Usage: $0 <version> <apple-id> <app-specific-password>}"
APP_PASSWORD="${3:?Usage: $0 <version> <apple-id> <app-specific-password>}"

TEAM_ID="9YVVV2SNR4"
PROJECT="Grid Clock.xcodeproj"
SCHEME="Grid Clock"
BUILD_DIR="./build"
NOTARIZE_ZIP="$BUILD_DIR/GridClock-notarize.zip"
RELEASE_ZIP="$BUILD_DIR/GridClock-${VERSION}.saver.zip"

echo "==> Cleaning build directory"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "==> Building Release"
xcodebuild build \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  CURRENT_PROJECT_VERSION="$VERSION" \
  MARKETING_VERSION="$VERSION" \
  BUILD_DIR="$(pwd)/$BUILD_DIR/xcode"

SAVER="$BUILD_DIR/xcode/Release/Grid Clock.saver"

if [ ! -d "$SAVER" ]; then
  echo "Error: built .saver not found at $SAVER"
  exit 1
fi

echo "==> Verifying code signature"
codesign --verify --deep --strict "$SAVER"
codesign -dv "$SAVER" 2>&1 | grep "Developer ID"

echo "==> Zipping for notarization submission"
ditto -c -k --keepParent "$SAVER" "$NOTARIZE_ZIP"

echo "==> Submitting for notarization"
xcrun notarytool submit "$NOTARIZE_ZIP" \
  --apple-id "$APPLE_ID" \
  --password "$APP_PASSWORD" \
  --team-id "$TEAM_ID" \
  --wait

echo "==> Stapling notarization ticket"
xcrun stapler staple "$SAVER"

echo "==> Verifying staple"
xcrun stapler validate "$SAVER"

echo "==> Packaging for release"
ditto -c -k --keepParent "$SAVER" "$RELEASE_ZIP"

echo ""
echo "Done: $RELEASE_ZIP"
echo ""
echo "Create GitHub release with:"
echo "  gh release create v${VERSION} \"$RELEASE_ZIP\" --title \"Grid Clock ${VERSION}\" --notes \"Release ${VERSION}\""
