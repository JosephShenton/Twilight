#!/bin/bash
echo "[*] Compiling Twilight..."
$(which xcodebuild) clean build -sdk `xcrun --sdk iphoneos --show-sdk-path` -arch arm64
mv build/Release-iphoneos/Twilight.app Twilight.app
mkdir Payload
mv Twilight.app Payload/Twilight.app
echo "[*] Zipping into .ipa"
zip -r9 Twilight.ipa Payload/Twilight.app
rm -rf build Payload
echo "[*] Done! Install .ipa with Impactor"