#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-esp32s3}"

cd "$SCRIPT_DIR"

if [[ ! -f "build.sh" ]]; then
  echo "Error: build.sh not found in $SCRIPT_DIR"
  exit 1
fi

if [[ ! -f "esp-idf/export.sh" ]]; then
  echo "Error: esp-idf/export.sh not found. Ensure esp-idf is initialized."
  exit 1
fi

if [[ ! -f "esp-idf/version.txt" ]]; then
  echo "Error: esp-idf/version.txt not found."
  exit 1
fi

export IDF_VERSION
IDF_VERSION="$(cat esp-idf/version.txt)"

source esp-idf/export.sh

echo "Building target: $TARGET"
./build.sh -s -t "$TARGET"

echo
echo "Build completed. Artifacts in dist/:"
ls -1 dist/*.tar.xz
