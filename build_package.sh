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

# ── verify components present ─────────────────────────────────────────────────
MISSING=0
if [ ! -d "components/arduino" ]; then
    warn "components/arduino is missing."
    MISSING=1
fi
if [ ! -d "components/arduino_tinyusb/tinyusb" ]; then
    warn "components/arduino_tinyusb/tinyusb is missing."
    MISSING=1
fi

if [ "$MISSING" -eq 1 ]; then
    die "One or more required component directories are absent.
    
    If you are on the machine that has the original working build, run:
        ./seed_from_local.sh
    
    Then re-run this script.
    
    If you cloned this repo fresh, you need to add the components:
        git submodule update --init --recursive
    or copy them manually into components/arduino/ and
    components/arduino_tinyusb/tinyusb/"
fi

# ── install / verify ESP-IDF ──────────────────────────────────────────────────
if [ ! -d "esp-idf" ]; then
    info "ESP-IDF not found – installing (this takes a while on first run)..."
    # install-esp-idf.sh clones and pins the commit, installs toolchain
    source ./tools/install-esp-idf.sh
else
    info "ESP-IDF already present, sourcing environment..."
    source esp-idf/export.sh
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

./build.sh -s -t esp32s3

BUILD_EXIT=$?
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
