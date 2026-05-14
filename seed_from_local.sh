#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  seed_from_local.sh  –  Populate components from the known-good local build
#
#  Run this ONCE on the machine that has the original working build.
#  It copies components/arduino/ and components/arduino_tinyusb/tinyusb/ 
#  into this repo so build_package.sh can run without any external Arduino
#  clone at build time.
#
#  Usage:
#    ./seed_from_local.sh
#    ./seed_from_local.sh /path/to/other/esp32-arduino-lib-builder
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Default source – the original working build on this machine.
# Override with first argument if needed.
SOURCE_BUILD="${1:-/home/dilawar/ai_build/build_tls13_s3/esp32-arduino-lib-builder}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[seed]${NC} $*"; }
warn()  { echo -e "${YELLOW}[seed] WARN:${NC} $*"; }
die()   { echo -e "${RED}[seed] ERROR:${NC} $*" >&2; exit 1; }

[ -d "$SOURCE_BUILD" ] || die "Source build not found at: $SOURCE_BUILD
Usage: $0 [/path/to/esp32-arduino-lib-builder]"

# ── Arduino core ──────────────────────────────────────────────────────────────
ARDUINO_SRC="$SOURCE_BUILD/components/arduino"
ARDUINO_DST="$SCRIPT_DIR/components/arduino"

if [ -d "$ARDUINO_DST" ] && [ -n "$(ls -A "$ARDUINO_DST" 2>/dev/null)" ]; then
    warn "components/arduino already populated – skipping (delete it first to re-seed)"
else
    [ -d "$ARDUINO_SRC" ] || die "Arduino source not found at: $ARDUINO_SRC"
    info "Copying Arduino source ($ARDUINO_SRC) ..."
    mkdir -p "$ARDUINO_DST"
    rsync -a --exclude='.git' "$ARDUINO_SRC/" "$ARDUINO_DST/"
    info "Arduino source copied."
fi

# ── TinyUSB ───────────────────────────────────────────────────────────────────
TUSB_SRC="$SOURCE_BUILD/components/arduino_tinyusb/tinyusb"
TUSB_DST="$SCRIPT_DIR/components/arduino_tinyusb/tinyusb"

if [ -d "$TUSB_DST" ] && [ -n "$(ls -A "$TUSB_DST" 2>/dev/null)" ]; then
    warn "components/arduino_tinyusb/tinyusb already populated – skipping"
else
    [ -d "$TUSB_SRC" ] || die "TinyUSB source not found at: $TUSB_SRC"
    info "Copying TinyUSB source ($TUSB_SRC) ..."
    mkdir -p "$TUSB_DST"
    rsync -a --exclude='.git' "$TUSB_SRC/" "$TUSB_DST/"
    info "TinyUSB source copied."
fi

# ── managed_components (pinned lock) ─────────────────────────────────────────
MANAGED_SRC="$SOURCE_BUILD/managed_components"
MANAGED_DST="$SCRIPT_DIR/managed_components"

if [ -d "$MANAGED_DST" ] && [ -n "$(ls -A "$MANAGED_DST" 2>/dev/null)" ]; then
    warn "managed_components already populated – skipping"
elif [ -d "$MANAGED_SRC" ]; then
    info "Copying managed_components (pinned IDF component cache) ..."
    mkdir -p "$MANAGED_DST"
    rsync -a --exclude='.git' "$MANAGED_SRC/" "$MANAGED_DST/"
    info "managed_components copied."
fi

# ── dependencies.lock (for reproducible managed component pins) ───────────────
LOCK_SRC="$SOURCE_BUILD/dependencies.lock"
LOCK_DST="$SCRIPT_DIR/dependencies.lock"

if [ ! -f "$LOCK_DST" ] && [ -f "$LOCK_SRC" ]; then
    info "Copying dependencies.lock ..."
    cp "$LOCK_SRC" "$LOCK_DST"
fi

echo ""
info "Seeding complete. You can now run:  ./build_package.sh"
