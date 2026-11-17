#!/usr/bin/env bash
set -euo pipefail
# cargo-ndk 3.1.2 points the C compiler at the NDK but not bindgen,
# which otherwise parses the runner's own glibc headers for an
# Android target. Newer glibc headers declare __float128, which
# clang rejects for aarch64-linux-android. Bindings for Android
# belong to the NDK's bionic sysroot.
export BINDGEN_EXTRA_CLANG_ARGS_aarch64_linux_android="--sysroot=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/sysroot"
./flutter/ndk_arm64.sh
mkdir -p ./flutter/android/app/src/main/jniLibs/arm64-v8a
cp ./target/aarch64-linux-android/release/liblibnremote.so \
   ./flutter/android/app/src/main/jniLibs/arm64-v8a/libnremote.so
cp "${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so" \
   ./flutter/android/app/src/main/jniLibs/arm64-v8a/
