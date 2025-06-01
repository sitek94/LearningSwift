#!/bin/bash

set -ex

version="$(cat $VERSION_FILE)"
build_number="$GITHUB_RUN_NUMBER"

xcodebuild -project LearningSwift.xcodeproj -scheme LearningSwift \
  -configuration Release \
  -derivedDataPath build \
  MARKETING_VERSION="$version" \
  CURRENT_PROJECT_VERSION="$build_number"

# Verify the build
file "$BUILD_DIR/$XCODE_BUILD_PATH/$APP_NAME.app/Contents/MacOS/$APP_NAME"