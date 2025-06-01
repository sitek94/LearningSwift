#!/bin/bash

set -exu

version="$(cat $VERSION_FILE)"
build_number="$GITHUB_RUN_NUMBER"
date="$(date +'%a, %d %b %Y %H:%M:%S %z')"
zipName="$APP_NAME-$version.zip"

# TODO: Add more sophisticated verification 
edSignatureAndLength="length=\"$(stat -f%z "$XCODE_BUILD_PATH/$zipName")\""

echo "
    <item>
      <title>Version $version</title>
      <pubDate>$date</pubDate>
      <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
      <enclosure
        url=\"https://github.com/$GITHUB_REPOSITORY/releases/download/v$version/$zipName\"
        sparkle:version=\"$build_number\"
        sparkle:shortVersionString=\"$version\"
        $edSignatureAndLength
        type=\"application/octet-stream\"/>
    </item>
" > ITEM.txt

# Insert new item after <language>
sed -i '' -e "/<\/language>/r ITEM.txt" docs/appcast.xml
