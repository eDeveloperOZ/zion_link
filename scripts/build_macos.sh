#!/bin/bash

# This script builds the macOS app and then deploys it to the GitHub release.

cd /Users/ofirozeri/development/zion_link && 
flutter clean &&
flutter build macos &&
cd build/macos/Build/Products/Release/ &&
zip -r zion_link.app.zip zion_link.app &&
open . 