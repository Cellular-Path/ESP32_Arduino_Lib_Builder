# Version Parity Report

| Item | Required | Actual | Evidence |
|---|---|---|---|
| ESP-IDF repo/branch/commit | tasmota/esp-idf / release/v5.5 / d47e9ffd | tasmota/esp-idf / release/v5.5 / d47e9ffd41 | `esp-idf git rev-parse --short HEAD => d47e9ffd41` |
| Arduino repo/branch/commit | Rapid-Prototypes-LLC/arduino-esp32-exp / main / 5c35a34 | Rapid-Prototypes-LLC/arduino-esp32-exp / main / 5c35a34 | `components/arduino git rev-parse --short HEAD => 5c35a34` |
| TinyUSB commit | baseline-compatible, no source edits | 0.19.0 / 331c26340 | `components/arduino_tinyusb/tinyusb git rev-parse --short HEAD => 331c26340` |
| Arduino core version marker | 3.3.5 + IDF SHA suffix policy | 3.3.5 with IDF SHA in versions.txt | `core_version.h` contains `ARDUINO_ESP32_GIT_DESC 3.3.5` |
| IDF version macros in package | IDF v5.5 baseline line | `ESP_IDF_VERSION_MAJOR 5`, `MINOR 5`, `PATCH 0`, `ESP_IDF_VERSION_STR "v5.5-dev-3518-gd47e9ffd41"` | `out/.../esp_idf_version.h` grep |
| Package version ledger | include pinned SHA | `esp-idf: d47e9ffd41`, `arduino: main 5c35a34`, `tinyusb: 0.19.0 331c26340` | `out/framework-arduinoespressif32/tools/esp32-arduino-libs/versions.txt` |

## Notes

- IDF and Arduino pin parity is satisfied.
- TinyUSB commit differs from some baselines that ship 0.20.0 content; this was required to keep this builder line compiling without TinyUSB source edits.
