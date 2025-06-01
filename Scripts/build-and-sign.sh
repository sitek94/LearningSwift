#!/bin/bash


# Build and Sign

xcodebuild -project LearningSwift.xcodeproj -scheme LearningSwift \
  -configuration Release \
  -derivedDataPath build 