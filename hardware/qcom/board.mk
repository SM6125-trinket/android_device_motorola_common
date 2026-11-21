# QCOM Platform selector
ifeq ($(TARGET_KERNEL_VERSION), 5.10)
  qcom_platform := sm8450
else ifeq ($(TARGET_KERNEL_VERSION), 5.4)
  qcom_platform := sm8350
else ifeq ($(TARGET_KERNEL_VERSION), 4.19)
  qcom_platform := sm8250
else
  qcom_platform := sm8150
endif

# Platform
BOARD_USES_QCOM_HARDWARE := true
QCOM_BOARD_PLATFORMS += $(TARGET_BOARD_PLATFORM)

# Audio
BOARD_USES_ALSA_AUDIO ?= true
AUDIO_FEATURE_ENABLED_INSTANCE_ID := true

# Display
-include hardware/qcom-caf/$(qcom_platform)/display/config/display-board.mk
TARGET_USES_GRALLOC1 ?= true
TARGET_USES_GRALLOC4 ?= true
TARGET_USES_HWC2 ?= true
TARGET_USES_QTI_MAPPER_2_0 ?= true
TARGET_USES_QTI_MAPPER_EXTENSIONS_1_1 ?= true
TARGET_USES_DRM_PP ?= true

# FM
ifeq ($(call device-has-characteristic,fm),true)
  BOARD_HAVE_QCOM_FM := true
endif

# GPS
-include hardware/qcom/$(qcom_platform)/gps/gps_vendor_board.mk
BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE ?= default
TARGET_USES_HARDWARE_QCOM_GPS := false

# Kernel
BOARD_KERNEL_CMDLINE += \
    androidboot.console=ttyMSM0 \
    androidboot.hardware=qcom \
    service_locator.enable=1

TARGET_COMPILE_WITH_MSM_KERNEL := true

# Media
TARGET_USES_ION := true

# Wi-Fi
BOARD_WLAN_DEVICE ?= qcwcn
BOARD_WPA_SUPPLICANT_DRIVER ?= NL80211
WPA_SUPPLICANT_VERSION ?= VER_0_8_X
BOARD_WPA_SUPPLICANT_PRIVATE_LIB ?= lib_driver_cmd_qcwcn
BOARD_HOSTAPD_DRIVER ?= NL80211
BOARD_HOSTAPD_PRIVATE_LIB ?= lib_driver_cmd_qcwcn
WIFI_DRIVER_DEFAULT ?= qca_cld3
WIFI_DRIVER_STATE_CTRL_PARAM ?= "/dev/wlan"
WIFI_DRIVER_STATE_ON ?= "ON"
WIFI_DRIVER_STATE_OFF ?= "OFF"
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY ?= true

# QCOM Common Board Hook
ifneq ($(ROM_INCLUDES_QCOM_COMMON),true)
    include device/motorola/common/hardware/qcom/utils.mk
    include hardware/qcom-caf/common/os_pickup_sepolicy_vndr.mk
    -include device/lineage/sepolicy/libperfmgr/sepolicy.mk
    DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += hardware/qcom-caf/common/vendor_framework_compatibility_matrix.xml
endif

TARGET_FS_CONFIG_GEN += device/motorola/common/hardware/qcom/qcom_aids.fs

# Recovery
## Configure recovery updater library
ifeq ($(call device-has-characteristic,ufs),true)
  ifeq ($(call is-kernel-greater-than-or-equal-to,5.4),true)
    SOONG_CONFIG_NAMESPACES += ufsbsg
    SOONG_CONFIG_ufsbsg := ufsframework
    SOONG_CONFIG_ufsbsg_ufsframework := bsg
  endif
endif
