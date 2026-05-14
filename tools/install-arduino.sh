#/bin/bash

source ./tools/config.sh

#
# VERIFY VENDORED ARDUINO
#
if [ ! -d "$AR_COMPS/arduino" ]; then
	echo "ERROR: components/arduino is missing."
	echo "This repository must carry the Arduino source instead of cloning it at build time."
	exit 1
fi

if [ -d "$AR_COMPS/arduino/.git" ]; then
	echo "Using vendored Arduino source from '$AR_COMPS/arduino'"
	export AR_COMMIT=$(git -C "$AR_COMPS/arduino" rev-parse --short HEAD || echo "")
	if [ -n "$AR_BRANCH" ]; then
		echo "Vendored Arduino branch preference: '$AR_BRANCH'"
	fi
else
	echo "Using vendored Arduino source from '$AR_COMPS/arduino' (non-git tree)"
	export AR_COMMIT="vendored"
fi

echo "Current dirs in Arduino"
ls -la "$AR_COMPS/arduino/libraries"

#
# remove code and libraries not needed/wanted for Tasmota framework
#
rm -rf "$AR_COMPS/arduino/docs"
rm -rf "$AR_COMPS/arduino/idf_component_examples"
rm -rf "$AR_COMPS/arduino/package"
rm -rf "$AR_COMPS/arduino/tests"
rm -rf "$AR_COMPS/arduino/tools/pre-commit"
rm -rf "$AR_COMPS/arduino/cores/esp32/chip-debug-report.cpp"
rm -rf "$AR_COMPS/arduino/cores/esp32/chip-debug-report.h"
rm -rf "$AR_COMPS/arduino/libraries/Matter"
rm -rf "$AR_COMPS/arduino/libraries/RainMaker"
rm -rf "$AR_COMPS/arduino/libraries/Insights"
rm -rf "$AR_COMPS/arduino/libraries/ESP_I2S"
rm -rf "$AR_COMPS/arduino/libraries/SPIFFS"
rm -rf "$AR_COMPS/arduino/libraries/WiFiProv"
rm -rf "$AR_COMPS/arduino/libraries/ESP32"
rm -rf "$AR_COMPS/arduino/libraries/ESP_SR"
rm -rf "$AR_COMPS/arduino/libraries/ESP_NOW"
rm -rf "$AR_COMPS/arduino/libraries/TFLiteMicro"
rm -rf "$AR_COMPS/arduino/libraries/OpenThread"
rm -rf "$AR_COMPS/arduino/libraries/Zigbee"

echo "Current dirs in Arduino (after cleanup)"
ls -la "$AR_COMPS/arduino/libraries"

if [ $? -ne 0 ]; then exit 1; fi
