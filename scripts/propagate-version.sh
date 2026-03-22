#!/usr/bin/env bash
# Propagates version from version.json to pubspec.yaml and build.gradle.kts
# Usage:
#   ./scripts/propagate-version.sh          # Apply changes
#   ./scripts/propagate-version.sh --check  # Check only (CI mode, exits 1 if out of sync)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Read version from version.json
VERSION=$(grep -o '"version": *"[^"]*"' "$PROJECT_DIR/version.json" | grep -o '"[^"]*"$' | tr -d '"')

if [ -z "$VERSION" ]; then
  echo "❌ Could not read version from version.json"
  exit 1
fi

# Parse semver
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
BUILD_NUMBER=$((MAJOR * 10000 + MINOR * 100 + PATCH))

echo "📦 Version: $VERSION (build: $BUILD_NUMBER)"

# Files to update
PUBSPEC="$PROJECT_DIR/pubspec.yaml"
BUILD_GRADLE="$PROJECT_DIR/android/app/build.gradle.kts"

CHECK_MODE=false
if [ "${1:-}" = "--check" ]; then
  CHECK_MODE=true
fi

ERRORS=0

# Check/update pubspec.yaml
CURRENT_PUBSPEC_VERSION=$(grep -E '^version:' "$PUBSPEC" | head -1 | awk '{print $2}')
EXPECTED_PUBSPEC_VERSION="$VERSION+$BUILD_NUMBER"

if [ "$CURRENT_PUBSPEC_VERSION" != "$EXPECTED_PUBSPEC_VERSION" ]; then
  if $CHECK_MODE; then
    echo "❌ pubspec.yaml: expected '$EXPECTED_PUBSPEC_VERSION', found '$CURRENT_PUBSPEC_VERSION'"
    ERRORS=$((ERRORS + 1))
  else
    sed -i "s/^version: .*/version: $EXPECTED_PUBSPEC_VERSION/" "$PUBSPEC"
    echo "✅ pubspec.yaml -> $EXPECTED_PUBSPEC_VERSION"
  fi
else
  echo "✅ pubspec.yaml is in sync"
fi

if $CHECK_MODE && [ $ERRORS -gt 0 ]; then
  echo ""
  echo "❌ Version is out of sync in $ERRORS file(s)"
  echo "   Run: ./scripts/propagate-version.sh"
  exit 1
fi

echo ""
echo "✅ All files in sync with version $VERSION"
