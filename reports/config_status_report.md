# Requested Config Status Report

Validated on all 4 required ESP32-S3 memory variants:

- `qio_opi_80m`
- `qio_opi_120m`
- `opi_opi_80m`
- `opi_opi_120m`

| Requested symbol | Final status | Evidence summary |
|---|---|---|
| CONFIG_MBEDTLS_DEBUG | enabled | present in all 4 `sdkconfig.h` files |
| CONFIG_MBEDTLS_DEBUG_LEVEL | enabled | mapped as `CONFIG_MBEDTLS_DEBUG_LEVEL_VERBOSE=1` in all 4 |
| CONFIG_MBEDTLS_SSL_PROTO_TLS1_3 | enabled | present in all 4 |
| CONFIG_ESP_HTTP_CLIENT_ENABLE_HTTPS | enabled | present in all 4 |
| CONFIG_MBEDTLS_SSL_KEEP_PEER_CERTIFICATE | enabled | present in all 4 |
| CONFIG_MBEDTLS_TLS_DISABLED | unset as requested | symbol not present in all 4 (`not set` semantic) |
| CONFIG_MBEDTLS_TLS_SERVER_AND_CLIENT | enabled | present in all 4 |
| CONFIG_MBEDTLS_GCM_C | enabled | present in all 4 |
| CONFIG_MBEDTLS_SSL_SERVER_NAME_INDICATION | not Kconfig-toggled here | built-in in `esp_config.h` (`MBEDTLS_SSL_SERVER_NAME_INDICATION`) |
| CONFIG_MBEDTLS_SSL_TLS1_3_COMPATIBILITY_MODE | enabled | present in all 4 |
| CONFIG_MBEDTLS_CCM_C | enabled | present in all 4 |
| CONFIG_MBEDTLS_CHACHAPOLY_C | enabled | present in all 4 |
| CONFIG_MBEDTLS_SHA512_C | enabled | present in all 4 |
| CONFIG_MBEDTLS_RSA_C | not Kconfig-toggled here | built-in in `esp_config.h` (`MBEDTLS_RSA_C`) |
| CONFIG_MBEDTLS_PKCS1_V15 | not Kconfig-toggled here | built-in in `esp_config.h` (`MBEDTLS_PKCS1_V15`) |
| CONFIG_MBEDTLS_PKCS1_V21 | not Kconfig-toggled here | built-in in `esp_config.h` (`MBEDTLS_PKCS1_V21`) |
| CONFIG_MBEDTLS_X509_RSASSA_PSS_SUPPORT | not Kconfig-toggled here | built-in in `esp_config.h` (`MBEDTLS_X509_RSASSA_PSS_SUPPORT`) |
| CONFIG_MBEDTLS_ASN1_PARSE_C | not Kconfig-toggled here | built-in in `esp_config.h` (`MBEDTLS_ASN1_PARSE_C`) |
| CONFIG_MBEDTLS_OID_C | not Kconfig-toggled here | built-in in `esp_config.h` (`MBEDTLS_OID_C`) |
| CONFIG_LOG_MAXIMUM_LEVEL_VERBOSE | enabled via level value | `CONFIG_LOG_MAXIMUM_LEVEL=5` in all 4 |
| CONFIG_LOG_DEFAULT_LEVEL_VERBOSE | enabled | present in all 4 |

## Notes

- For IDF 5.5, some mbedTLS capabilities are represented by compile-time defines in `esp_config.h` rather than project Kconfig symbols; this is expected.
- Verbose log max level is represented numerically (`5`) rather than by a `_VERBOSE` boolean symbol in generated headers.
