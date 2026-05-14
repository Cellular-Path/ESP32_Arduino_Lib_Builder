#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  build_package.sh  –  Cellular-Path ESP32-S3 TLS 1.3 Framework Builder
#  Single entry point: run this script to produce the .tar.xz package.
#
#  Usage:
#    ./build_package.sh               # build with defaults
#    IDF_COMMIT=d47e9ffd41 ./build_package.sh   # explicit IDF pin
#
#  Output:  dist/framework-arduinoespressif32-esp32s3-*.tar.xz
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ── colour helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[build_package]${NC} $*"; }
warn()  { echo -e "${YELLOW}[build_package] WARN:${NC} $*"; }
die()   { echo -e "${RED}[build_package] ERROR:${NC} $*" >&2; exit 1; }

# ── pre-flight checks ─────────────────────────────────────────────────────────
for cmd in python3 git ninja jq; do
    command -v "$cmd" >/dev/null 2>&1 || die "$cmd is required but not installed."
done

# ── defaults ──────────────────────────────────────────────────────────────────
export IDF_COMMIT="${IDF_COMMIT:-d47e9ffd41}"
export IDF_BRANCH="${IDF_BRANCH:-release/v5.5}"

info "IDF_COMMIT = $IDF_COMMIT"
info "IDF_BRANCH = $IDF_BRANCH"

# ── provision components if absent ──────────────────────────────────────────
# Pinned sources – change these if you fork or bump versions.
ARDUINO_REPO="${ARDUINO_REPO:-https://github.com/Rapid-Prototypes-LLC/arduino-esp32-exp.git}"
ARDUINO_COMMIT="${ARDUINO_COMMIT:-5c35a34}"
TINYUSB_REPO="${TINYUSB_REPO:-https://github.com/hathach/tinyusb.git}"
TINYUSB_TAG="${TINYUSB_TAG:-0.19.0}"

# Local seed path (dev machine shortcut – skips GitHub clones if present)
LOCAL_SEED="/home/dilawar/ai_build/build_tls13_s3/esp32-arduino-lib-builder"

provision_arduino() {
    if [ -d "$LOCAL_SEED/components/arduino" ]; then
        info "Seeding Arduino source from local build..."
        mkdir -p components/arduino
        rsync -a --exclude='.git' "$LOCAL_SEED/components/arduino/" components/arduino/
    else
        info "Cloning Arduino core ($ARDUINO_REPO @ $ARDUINO_COMMIT) ..."
        git clone --depth 200 "$ARDUINO_REPO" components/arduino
        git -C components/arduino checkout "$ARDUINO_COMMIT"
    fi
}

provision_tinyusb() {
    if [ -d "$LOCAL_SEED/components/arduino_tinyusb/tinyusb" ]; then
        info "Seeding TinyUSB from local build..."
        mkdir -p components/arduino_tinyusb/tinyusb
        rsync -a --exclude='.git' "$LOCAL_SEED/components/arduino_tinyusb/tinyusb/" components/arduino_tinyusb/tinyusb/
    else
        info "Cloning TinyUSB ($TINYUSB_TAG) ..."
        git clone --depth 1 --branch "$TINYUSB_TAG" "$TINYUSB_REPO" \
            components/arduino_tinyusb/tinyusb
    fi
}

if [ ! -d "components/arduino" ] || [ -z "$(ls -A components/arduino 2>/dev/null)" ]; then
    warn "components/arduino missing – provisioning automatically..."
    provision_arduino
    info "Arduino source ready."
fi

if [ ! -d "components/arduino_tinyusb/tinyusb" ] || [ -z "$(ls -A components/arduino_tinyusb/tinyusb 2>/dev/null)" ]; then
    warn "TinyUSB missing – provisioning automatically..."
    provision_tinyusb
    info "TinyUSB ready."
fi

# ── install / verify ESP-IDF ──────────────────────────────────────────────────
# Pre-export IDF_PATH so config.sh never sees it as unbound under set -u
export IDF_PATH="$SCRIPT_DIR/esp-idf"

if [ ! -d "esp-idf" ]; then
    info "ESP-IDF not found – installing (this takes a while on first run)..."
    # Tools scripts were not written for strict mode; relax -u around source calls
    set +u
    source ./tools/install-esp-idf.sh
    set -u
else
    info "ESP-IDF already present, sourcing environment..."
    set +u
    source esp-idf/export.sh
    set -u
    # Confirm pinned commit
    CURRENT_COMMIT=$(git -C esp-idf rev-parse --short HEAD 2>/dev/null || echo "unknown")
    if [ "$CURRENT_COMMIT" != "$IDF_COMMIT" ]; then
        warn "Installed ESP-IDF commit $CURRENT_COMMIT differs from pinned $IDF_COMMIT"
        warn "Consider deleting esp-idf/ and re-running to get the exact pinned version."
    fi
fi

# ── export IDF_VERSION (required by archive-build.sh) ────────────────────────
export IDF_VERSION=$(cat esp-idf/version.txt 2>/dev/null || echo "5.5.1")
info "IDF_VERSION = $IDF_VERSION"

# ── build ─────────────────────────────────────────────────────────────────────
info "Starting ESP32-S3 build (target=esp32s3, TLS 1.3 enabled)..."
info "This will take 30-90 minutes on first run."

set +u
./build.sh -s -t esp32s3
BUILD_EXIT=$?
set -u

if [ $BUILD_EXIT -ne 0 ]; then
    die "build.sh exited with code $BUILD_EXIT"
fi

# ── report output ─────────────────────────────────────────────────────────────
info "Build complete!"
echo ""
echo "Output packages:"
ls -lh dist/*.tar.xz 2>/dev/null || warn "No .tar.xz found in dist/ – check build log."
echo ""
info "Done."
