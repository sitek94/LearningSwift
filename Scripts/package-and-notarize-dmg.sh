#!/bin/bash

# Package and Notarize DMG

# Package
mkdir -p dist
cp -R build/Build/Products/Release/LearningSwift.app dist/
hdiutil create -volname "LearningSwift" -srcfolder dist -ov -format UDZO dist/LearningSwift.dmg

# Notarize
xcrun notarytool submit dist/LearningSwift.dmg \
  --apple-id "$APPLE_ID" \
  --password "$APPLE_ID_PASSWORD" \
  --team-id "$APPLE_TEAM_ID" \
  --wait

# Staple
xcrun stapler staple dist/LearningSwift.dmg

