#!/bin/bash

# This script builds the macOS app and then deploys it to the GitHub release.

cd /Users/ofirozeri/development/tachles && 
flutter clean &&
flutter build macos &&
cd build/macos/Build/Products/Release/ &&
zip -r tachles.app.zip tachles.app &&
open . 