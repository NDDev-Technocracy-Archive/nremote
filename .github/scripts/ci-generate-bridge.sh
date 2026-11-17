#!/usr/bin/env bash
set -euo pipefail
flutter_rust_bridge_codegen \
  --rust-input ./src/flutter_ffi.rs \
  --dart-output ./flutter/lib/generated_bridge.dart \
  --c-output ./flutter/macos/Runner/bridge_generated.h
test -s ./flutter/lib/generated_bridge.dart
