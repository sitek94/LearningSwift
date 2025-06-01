#!/bin/bash

set -ex

xcodebuild -project LearningSwift.xcodeproj -scheme LearningSwift \
  -configuration Release \
  -derivedDataPath build

# Verify the build
file "$BUILD_DIR/$XCODE_BUILD_PATH/$APP_NAME.app/Contents/MacOS/$APP_NAME"