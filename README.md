# ESP32_Arduino_Lib_Builder

Cellular-Path maintained builder for the ESP32-S3 Arduino framework with full **TLS 1.3** support (mbedTLS 3.x via ESP-IDF 5.5).

## Quick Start (single command)

```bash
./build_package.sh
```

That's it. The script handles everything on first run:
1. Verifies `components/arduino/` and TinyUSB are present (see [Components](#components) if missing)
2. Installs ESP-IDF **pinned** to commit `d47e9ffd41` on `tasmota/esp-idf@release/v5.5`
3. Builds the ESP32-S3 framework with TLS 1.3 enabled
4. Produces `dist/framework-arduinoespressif32-esp32s3-release_v5.5-d47e9ffd41.tar.xz`

Expect **30–90 minutes** on first run. Subsequent runs take ~10–20 minutes.

---

## Components

Large source trees are not committed to this repository.
On your local dev machine populate them once with:

```bash
./seed_from_local.sh
```

This copies `components/arduino/` and `components/arduino_tinyusb/tinyusb/` from
the known-good local build at `/home/dilawar/ai_build/build_tls13_s3/esp32-arduino-lib-builder/`.

To use a custom path:

```bash
./seed_from_local.sh /path/to/esp32-arduino-lib-builder
```

### Arduino core

| Property | Value |
|----------|-------|
| Source   | `Cellular-Path/arduino-esp32` (fork of `Rapid-Prototypes-LLC/arduino-esp32-exp`) |
| Branch   | `main` |
| Commit   | `5c35a34` |
| Version  | `3.3.5` |

### TinyUSB

| Property | Value |
|----------|-------|
| Source   | `hathach/tinyusb` |
| Vendored at | `release/0.19.0` (commit `331c26340`) |

### ESP-IDF

| Property | Value |
|----------|-------|
| Source   | `tasmota/esp-idf` |
| Branch   | `release/v5.5` |
| **Pinned commit** | `d47e9ffd41` |

---

## Build Configuration (ESP32-S3 TLS 1.3)

Key defconfig fragment `configs/defconfig.esp32s3_tls13_custom`:

```
CONFIG_MBEDTLS_SSL_PROTO_TLS1_3=y
CONFIG_ESP_HTTP_CLIENT_ENABLE_HTTPS=y
CONFIG_MBEDTLS_SSL_TLS1_3_COMPATIBILITY_MODE=y
CONFIG_MBEDTLS_GCM_C=y
CONFIG_MBEDTLS_CHACHAPOLY_C=y
CONFIG_MBEDTLS_SHA512_C=y
```

---

## Prerequisites

```bash
sudo apt-get install -y git ninja-build python3 python3-pip jq cmake
```

All other tools (xtensa toolchain, Python packages) are installed automatically.

---

## Repository Structure

```
cellular_path_builder/
├── build_package.sh         ← SINGLE ENTRY POINT
├── seed_from_local.sh       ← one-time component seeder (local dev only)
├── build.sh                 ← core build orchestrator
├── CMakeLists.txt
├── partitions.csv
├── components/
│   ├── arduino/             ← populated by seed_from_local.sh
│   ├── arduino_tinyusb/     ← tinyusb/ populated by seed_from_local.sh
│   └── fb_gfx/
├── configs/
│   ├── builds.json
│   ├── defconfig.esp32s3_tls13_custom   ← TLS 1.3 key config
│   └── defconfig.*
├── main/
└── tools/
    ├── config.sh            ← IDF_COMMIT default = d47e9ffd41
    ├── install-esp-idf.sh
    ├── install-arduino.sh   ← verifies vendored source (no external clone)
    ├── update-components.sh ← verifies vendored TinyUSB
    └── archive-build.sh / copy-*.sh
```

---

## Updating

### Change IDF commit
Edit the default in `tools/config.sh`, delete `esp-idf/`, re-run `./build_package.sh`.

### Change Arduino source
Update `components/arduino/` and re-run `./build_package.sh`.
