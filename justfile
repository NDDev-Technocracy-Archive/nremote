set shell := ["bash", "-euo", "pipefail", "-c"]

# Lists the available project commands.
default:
    @just --list

# Fetches the locked Cargo dependencies on the prepared native executor.
setup:
    cargo fetch --locked

# Checks source contracts and workflow security without builds or network access.
check: check-contracts check-ci

# Applies formatting to the command interface.
fix:
    just --fmt

# Builds and tests the vendored shared library with the selected compiler.
test: build-shared test-shared

# Runs source, peer protocol, native, application and UI verification on a prepared desktop executor.
verify: check check-protocol test resolve-ui generate-bridge build analyze-ui

# Builds the Flutter application with build.py's existing platform and packaging policy.
build:
    python3 ./build.py --flutter

# Checks the local product, configuration, protocol and toolchain contracts.
[group('source')]
check-contracts:
    just --fmt --check
    python3 scripts/brand.py --check
    bash .github/scripts/ci-empty-configuration.sh
    python3 scripts/check_protocol_parity.py --offline
    node scripts/check_commitlint_config.mjs
    bash .github/scripts/ci-toolchain-parity.sh

# Lints every workflow, preserves the CI audit scope and scans complete Git history.
[group('source')]
check-ci:
    actionlint .github/workflows/*.yml
    zizmor --offline --no-progress .github/workflows/ci.yml .github/workflows/build.yml .github/workflows/security.yml .github/workflows/ui.yml .github/dependabot.yml
    shellcheck .github/scripts/ci-*.sh
    GIT_NO_LAZY_FETCH=1 gitleaks git --no-banner --redact .

# Checks both the local and pinned remote server protocol; a failed fetch fails verification.
[group('native')]
check-protocol:
    python3 scripts/check_protocol_parity.py

# Builds the vendored library from its original working directory.
[group('native')]
[working-directory('libs/hbb_common')]
build-shared:
    cargo build --locked --all-targets

# Runs every existing vendored-library target, including wire-signing compatibility tests.
[group('native')]
[working-directory('libs/hbb_common')]
test-shared:
    cargo test --locked --all-targets

# Resolves the unchanged Flutter manifest on a prepared native executor.
[group('native')]
[working-directory('flutter')]
resolve-ui:
    flutter pub get

# Generates and checks the existing Rust-to-Dart bridge outputs.
[group('native')]
generate-bridge:
    bash .github/scripts/ci-generate-bridge.sh

# Runs the existing Flutter analysis errors gate.
[group('native')]
[working-directory('flutter')]
analyze-ui:
    flutter analyze --no-fatal-infos --no-fatal-warnings

# Builds the existing Android ARM library and debug-signed release APK on a Java17 executor.
[group('native')]
build-android: build-android-library build-android-apk

# Builds and copies the Android ARM native library using the declared NDK sysroot.
[group('native')]
build-android-library:
    bash .github/scripts/ci-android-library.sh

# Packages the existing Android ARM APK with the prepared Java17 runtime and debug key.
[group('native')]
build-android-apk:
    bash .github/scripts/ci-android-apk.sh
