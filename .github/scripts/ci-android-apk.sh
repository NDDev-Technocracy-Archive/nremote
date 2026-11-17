#!/usr/bin/env bash
set -euo pipefail
export PATH="${JAVA_HOME}/bin:${PATH}"
sed -i 's/org.gradle.jvmargs=-Xmx1024M/org.gradle.jvmargs=-Xmx2g/g' ./flutter/android/gradle.properties
sed -i 's/signingConfigs.release/signingConfigs.debug/g' ./flutter/android/app/build.gradle
cd flutter
flutter build apk --release --target-platform android-arm64 --split-per-abi
mkdir -p ../dist
mv build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
   ../dist/nremote-android-arm64-debugsigned.apk
du -sh ../dist/*
