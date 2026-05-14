#/bin/bash

source ./tools/config.sh

TINYUSB_REPO_DIR="$AR_COMPS/arduino_tinyusb/tinyusb"

#
# VERIFY VENDORED TINYUSB
#
echo "Checking vendored TinyUSB..."
if [ ! -d "$TINYUSB_REPO_DIR" ]; then
       echo "ERROR: components/arduino_tinyusb/tinyusb is missing."
       echo "Vendor a pinned TinyUSB tree into the repository before building."
       exit 1
fi

if [ -d "$TINYUSB_REPO_DIR/.git" ]; then
       tinyusb_commit=$(git -C "$TINYUSB_REPO_DIR" rev-parse --short HEAD || echo "")
       echo "Using vendored TinyUSB commit: ${tinyusb_commit:-unknown}"
else
       echo "Using vendored TinyUSB source tree (non-git)"
fi
