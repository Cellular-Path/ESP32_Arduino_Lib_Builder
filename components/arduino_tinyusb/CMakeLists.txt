if(CONFIG_TINYUSB_ENABLED)

  ### variables ###
  #################

  if(IDF_TARGET STREQUAL "esp32s2")
    set(compile_options
        "-DCFG_TUSB_MCU=OPT_MCU_ESP32S2"
        "-DCFG_TUSB_DEBUG=${CONFIG_TINYUSB_DEBUG_LEVEL}"
      "-Wno-error=implicit-function-declaration"
        "-Wno-type-limits" # needed for the vanila tinyusb with turned off classes
    )
  elseif(IDF_TARGET STREQUAL "esp32s3")
    set(compile_options
        "-DCFG_TUSB_MCU=OPT_MCU_ESP32S3"
        "-DCFG_TUSB_DEBUG=${CONFIG_TINYUSB_DEBUG_LEVEL}"
      "-Wno-error=implicit-function-declaration"
        "-Wno-type-limits" # needed for the vanila tinyusb with turned off classes
    )
  elseif(IDF_TARGET STREQUAL "esp32p4")
    set(compile_options
        "-DCFG_TUSB_MCU=OPT_MCU_ESP32P4"
        "-DCFG_TUSB_DEBUG=${CONFIG_TINYUSB_DEBUG_LEVEL}"
      "-Wno-error=implicit-function-declaration"
        "-Wno-type-limits" # needed for the vanila tinyusb with turned off classes
    )
  endif()

  # TinyUSB has different portable driver layouts across versions.
  if(EXISTS "${COMPONENT_DIR}/tinyusb/src/portable/synopsys/dwc2/dcd_dwc2.c")
    set(portable_srcs
        "${COMPONENT_DIR}/tinyusb/src/portable/synopsys/dwc2/dcd_dwc2.c"
        "${COMPONENT_DIR}/tinyusb/src/portable/synopsys/dwc2/dwc2_common.c"
        "${COMPONENT_DIR}/tinyusb/src/portable/synopsys/dwc2/hcd_dwc2.c")
    set(portable_includes
        "${COMPONENT_DIR}/tinyusb/src/portable/synopsys/dwc2")
  elseif(EXISTS "${COMPONENT_DIR}/tinyusb/src/portable/espressif/esp32s2/dcd_esp32s2.c")
    set(portable_srcs
        "${COMPONENT_DIR}/tinyusb/src/portable/espressif/esp32s2/dcd_esp32s2.c")
    if(EXISTS "${COMPONENT_DIR}/tinyusb/src/portable/st/synopsys/dcd_synopsys.c")
      list(APPEND portable_srcs
           "${COMPONENT_DIR}/tinyusb/src/portable/st/synopsys/dcd_synopsys.c")
    endif()
    set(portable_includes
        "${COMPONENT_DIR}/tinyusb/src/portable/espressif/esp32s2"
        "${COMPONENT_DIR}/tinyusb/src/portable/st/synopsys")
  else()
    message(FATAL_ERROR "Unsupported TinyUSB source layout for arduino_tinyusb component")
  endif()

  set(srcs
      # tusb:
      ${portable_srcs}
      # common
      "${COMPONENT_DIR}/tinyusb/src/tusb.c"
      "${COMPONENT_DIR}/tinyusb/src/common/tusb_fifo.c"
      # device
      "${COMPONENT_DIR}/tinyusb/src/device/usbd.c"
      "${COMPONENT_DIR}/tinyusb/src/class/cdc/cdc_device.c"
      "${COMPONENT_DIR}/tinyusb/src/class/hid/hid_device.c"
      "${COMPONENT_DIR}/tinyusb/src/class/midi/midi_device.c"
      "${COMPONENT_DIR}/tinyusb/src/class/msc/msc_device.c"
      "${COMPONENT_DIR}/tinyusb/src/class/video/video_device.c"
      "${COMPONENT_DIR}/tinyusb/src/class/dfu/dfu_rt_device.c"
      "${COMPONENT_DIR}/tinyusb/src/class/dfu/dfu_device.c"
      "${COMPONENT_DIR}/tinyusb/src/class/vendor/vendor_device.c"
      "${COMPONENT_DIR}/tinyusb/src/class/net/ncm_device.c"
      "${COMPONENT_DIR}/tinyusb/src/class/net/ecm_rndis_device.c"
      "${COMPONENT_DIR}/tinyusb/src/class/usbtmc/usbtmc_device.c"
      # host
      "${COMPONENT_DIR}/tinyusb/src/host/usbh.c"
      "${COMPONENT_DIR}/tinyusb/src/host/hub.c"
      "${COMPONENT_DIR}/tinyusb/src/class/cdc/cdc_host.c"
      "${COMPONENT_DIR}/tinyusb/src/class/hid/hid_host.c"
      "${COMPONENT_DIR}/tinyusb/src/class/midi/midi_host.c"
      "${COMPONENT_DIR}/tinyusb/src/class/msc/msc_host.c"
      "${COMPONENT_DIR}/tinyusb/src/class/vendor/vendor_host.c"
      )

  if(EXISTS "${COMPONENT_DIR}/tinyusb/src/device/usbd_control.c")
    list(APPEND srcs "${COMPONENT_DIR}/tinyusb/src/device/usbd_control.c")
  endif()

  set(includes_private
      # tusb:
      #"${COMPONENT_DIR}/tinyusb/lib/networking/"
      "${COMPONENT_DIR}/tinyusb/hw/bsp/"
      "${COMPONENT_DIR}/tinyusb/src/"
      "${COMPONENT_DIR}/tinyusb/src/device"
      "${COMPONENT_DIR}/tinyusb/src/host"
      ${portable_includes}
      )

  idf_component_get_property(FREERTOS_ORIG_INCLUDE_PATH freertos
                             ORIG_INCLUDE_PATH)
  set(includes_public
      # tusb:
      "${FREERTOS_ORIG_INCLUDE_PATH}"
      "${COMPONENT_DIR}/tinyusb/src/"
      # espressif:
      "${COMPONENT_DIR}/include")

  set(requires esp_rom freertos soc)
  set(priv_requires arduino main)

  idf_component_register(
    INCLUDE_DIRS ${includes_public} 
    PRIV_INCLUDE_DIRS ${includes_private} 
    SRCS ${srcs} 
    REQUIRES ${requires} 
    PRIV_REQUIRES ${priv_requires}
    )
  target_compile_options(${COMPONENT_TARGET} PRIVATE ${compile_options})

else()

  idf_component_register()

endif()
