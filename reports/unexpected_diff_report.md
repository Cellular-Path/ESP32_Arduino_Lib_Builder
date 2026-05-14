# Unexpected Diff Report

- Baseline: `/mnt/d/Projects/Cellular-Path_USA/TestCode/arda_built_package/extracted/framework-arduinoespressif32`
- New: `out/framework-arduinoespressif32`
- Raw diff file: `reports/diff_raw.txt`
- Raw diff line count: `219`

## Classification

### Expected differences

- `versions.txt` and package metadata reflect the requested pins (`d47e9ffd41`, `5c35a34`, TinyUSB `331c26340`).
- `sdkconfig.h` differs for all 4 S3 memory variants due to intentional TLS1.3/logging config changes.
- Many `arduino_tinyusb` header/library deltas are expected because the final successful build used TinyUSB `0.19.0` content to preserve no-source-edit compatibility in this builder line.

### Unexpected differences (remaining)

- Baseline contains extra non-S3 content not produced in this S3-only build (for example additional `esp32` family folders/files).
- Some managed component headers/libs differ beyond TLS scope (for example `esp-dsp`, `esp32-camera`, `littlefs`, and broad `.a` binary drift).

## Conclusion

- Unexpected diff set is **not empty**.
- Primary drivers are baseline scope mismatch (multi-target baseline vs S3-only output) and dependency graph/toolchain drift versus the reference package.
- Full line-by-line evidence is preserved in `reports/diff_raw.txt`.
