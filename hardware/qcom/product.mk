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

# A/B OTA Updater
ifeq ($(AB_OTA_UPDATER),true)
  PRODUCT_PACKAGES += \
      android.hardware.boot@1.2-impl-qti \
      android.hardware.boot@1.2-impl-qti.recovery \
      android.hardware.boot@1.2-service \
      bootctrl.$(TARGET_BOARD_PLATFORM) \
      bootctrl.$(TARGET_BOARD_PLATFORM).recovery
endif

# Audio
# Avoid hardware/qcom-caf/$(qcom_platform)/audio/configs/$(TARGET_BOARD_PLATFORM)/$(TARGET_BOARD_PLATFORM).mk
# because its upstream rules reference non-existent vendor/qcom/opensource/audio-hal/primary-hal paths.

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-service \
    com.dsi.ant@1.0.vendor \
    com.qualcomm.qti.bluetooth_audio@1.0.vendor \
    vendor.qti.hardware.btconfigstore@1.0.vendor \
    vendor.qti.hardware.btconfigstore@2.0.vendor

PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/hardware/qcom/vendor.bluetooth-qti-groups.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/vendor.bluetooth-qti-groups.rc

# Camera
PRODUCT_PACKAGES += \
    vendor.qti.hardware.camera.postproc@1.0.vendor

ifneq ($(call is-kernel-greater-than-or-equal-to,5.10),true)
  ifeq ($(TARGET_USES_64BIT_CAMERA),true)
    PRODUCT_PACKAGES += \
        android.hardware.camera.provider@2.4-impl:64 \
        android.hardware.camera.provider@2.4-service_64
  else
    PRODUCT_PACKAGES += \
        android.hardware.camera.provider@2.4-impl:32 \
        android.hardware.camera.provider@2.4-service
  endif
  TARGET_USES_CAMERA_V2_4 := true
endif

# Components
TARGET_COMMON_QTI_COMPONENTS := \
    adreno \
    audio \
    av \
    charging \
    display \
    dsprpcd \
    init \
    gps \
    keymaster \
    media \
    neuralnetworks \
    overlay \
    qseecomd \
    vibrator \
    wlan
## Filter out unwanted components
TARGET_COMMON_QTI_COMPONENTS := $(filter-out $(TARGET_UNWANTED_QTI_COMPONENTS),$(TARGET_COMMON_QTI_COMPONENTS))

# Dataservices
$(call soong_config_set,rmnetctl,old_rmnet_data,true)

# Display
$(call inherit-product, vendor/qcom/opensource/commonsys-intf/display/config/display-interfaces-product.mk)
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.4-impl \
    android.hardware.graphics.composer@2.4-service \
    android.hardware.graphics.mapper@3.0-impl-qti-display \
    android.hardware.graphics.mapper@4.0-impl-qti-display \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service \
    disable_configstore \
    gralloc.$(TARGET_BOARD_PLATFORM) \
    hwcomposer.$(TARGET_BOARD_PLATFORM) \
    libqdutils \
    libqservice \
    libtinyxml \
    memtrack.$(TARGET_BOARD_PLATFORM) \
    vendor.qti.hardware.display.allocator-service

ifeq ($(TARGET_BOARD_PLATFORM),trinket)
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.surface_flinger.has_wide_color_display=false \
    ro.surface_flinger.has_HDR_display=false \
    ro.surface_flinger.use_color_management=false
endif

# Audio HAL & Effects
PRODUCT_PACKAGES += \
    audio.primary.$(TARGET_BOARD_PLATFORM) \
    libqcompostprocbundle \
    libqcomvisualizer \
    libqcomvoiceprocessing \
    libvolumelistener

ifneq ($(TARGET_BOARD_PLATFORM),trinket)
  PRODUCT_PACKAGES += \
      audioadsprpcd
endif

# Media
PRODUCT_PACKAGES += \
    libc2dcolorconvert \
    libmm-omxcore \
    libOmxCore \
    libOmxVdec \
    libOmxVenc \
    libstagefrighthw

PRODUCT_COPY_FILES += \
    hardware/qcom-caf/sm8150/media/conf_files/$(TARGET_BOARD_PLATFORM)/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    hardware/qcom-caf/sm8150/media/conf_files/$(TARGET_BOARD_PLATFORM)/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml \
    hardware/qcom-caf/sm8150/media/conf_files/$(TARGET_BOARD_PLATFORM)/media_codecs_vendor.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_vendor.xml \
    hardware/qcom-caf/sm8150/media/conf_files/$(TARGET_BOARD_PLATFORM)/media_codecs_vendor_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_vendor_audio.xml \
    hardware/qcom-caf/sm8150/media/conf_files/$(TARGET_BOARD_PLATFORM)/mediacodec-seccomp.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediacodec.policy \
    hardware/qcom-caf/sm8150/media/conf_files/$(TARGET_BOARD_PLATFORM)/system_properties.xml:$(TARGET_COPY_OUT_VENDOR)/etc/system_properties.xml

# HIDL Vendor Libraries
PRODUCT_PACKAGES += \
    android.hardware.cas@1.1.vendor \
    android.hardware.cas@1.2.vendor \
    vendor.qti.hardware.bluetooth_audio@2.0.vendor

# FM
ifeq ($(call device-has-characteristic,fm),true)
  PRODUCT_PACKAGES += \
      FMRadio \
      libfmjni
endif

# GPS
TARGET_USES_$(call upper,$(qcom_platform))_GPS := true
ifeq ($(call is-kernel-less-than-or-equal-to,5.4),true)
  PRODUCT_SOONG_NAMESPACES += hardware/qcom/$(qcom_platform)/gps
  $(call inherit-product-if-exists, hardware/qcom/$(qcom_platform)/gps/gps_vendor_product.mk)
  TARGET_USES_OLD_GPS := true
else
  PRODUCT_SOONG_NAMESPACES += vendor/qcom/opensource/gps/$(qcom_platform)
  $(call inherit-product-if-exists, vendor/qcom/opensource/gps/$(qcom_platform)/gps_vendor_product.mk)
endif

# Kernel
TARGET_USES_KERNEL_PLATFORM := false

# Keymaster
PRODUCT_PACKAGES += \
    libkeymaster_messages.vendor

# Linked by Adreno/EGL blobs for fallback if 3.0 doesn't exist
PRODUCT_PACKAGES += \
    vendor.qti.hardware.display.allocator@3.0.vendor \
    vendor.qti.hardware.display.mapper@2.0.vendor

# Media
$(call inherit-product-if-exists, hardware/qcom-caf/$(qcom_platform)/media/product.mk)
TARGET_DISABLE_C2_CODEC := false

# Power
TARGET_PROVIDES_POWERHAL := true

# QCOM Common Product Hook
ifneq ($(ROM_INCLUDES_QCOM_COMMON),true)
  include $(COMMON_PATH)/hardware/qcom/utils.mk
  $(call inherit-product-if-exists, hardware/qcom-caf/common/common.mk)
  $(call inherit-product-if-exists, vendor/qcom/opensource/data-ipa-cfg-mgr-legacy-um/ipacm_vendor_product.mk)

  ifneq (,$(filter keymaster,$(TARGET_COMMON_QTI_COMPONENTS)))
    $(call inherit-product-if-exists, vendor/qcom/common/vendor/keymaster/keymaster-vendor.mk)
  endif

endif

# QCOM Data
PRODUCT_PACKAGES += \
    librmnetctl

# QTI VNDK Framework Detect
PRODUCT_ODM_PROPERTIES += \
    ro.vendor.qti.va_odm.support=1

PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.qti.va_aosp.support=1

PRODUCT_PACKAGES += \
    libvndfwk_detect_jni.qti \
    libqti_vndfwk_detect \
    libvndfwk_detect_jni.qti.vendor \
    libqti_vndfwk_detect.vendor \
    libqti_vndfwk_detect_vendor

# RIL
PRODUCT_PACKAGES += \
    libqsap_sdk \
    qti-telephony-hidl-wrapper \
    qti-telephony-hidl-wrapper-prd \
    qti_telephony_hidl_wrapper.xml \
    qti_telephony_hidl_wrapper_prd.xml \
    qti-telephony-utils \
    qti_telephony_utils.xml

# Soong
PRODUCT_SOONG_NAMESPACES += \
    hardware/qcom-caf/$(qcom_platform) \
    hardware/qcom-caf/$(qcom_platform)/audio \
    hardware/qcom-caf/$(qcom_platform)/display \
    hardware/qcom-caf/$(qcom_platform)/media \
    hardware/qcom-caf/bootctrl \
    vendor/qcom/opensource/commonsys/display \
    vendor/qcom/opensource/data-ipa-cfg-mgr-legacy-um \
    vendor/qcom/opensource/dataservices \
    vendor/qcom/opensource/display \
    vendor/qcom/opensource/thermal-engine \
    vendor/qcom/opensource/vibrator \
    packages/apps/FMRadio/jni/fmr

ifeq ($(call is-kernel-less-than-or-equal-to,5.4),true)
  PRODUCT_SOONG_NAMESPACES += \
      vendor/qcom/opensource/commonsys-intf/display
endif

# Telephony: IMS framework
PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/hardware/qcom/permissions/privapp-permissions-ims.xml:$(TARGET_COPY_OUT_SYSTEM_EXT)/etc/permissions/privapp-permissions-ims.xml

# Thermal
PRODUCT_SOONG_NAMESPACES += \
    hardware/qcom-caf/thermal

PRODUCT_PACKAGES += \
    android.hardware.thermal@2.0-service.qti

# WLAN
PRODUCT_SOONG_NAMESPACES += \
    hardware/qcom-caf/wlan

PRODUCT_COPY_FILES += \
    $(COMMON_PATH)/hardware/qcom/bin/cnss-daemon_moto:$(TARGET_COPY_OUT_VENDOR)/bin/cnss-daemon_moto \
    external/wpa_supplicant_8/wpa_supplicant/wpa_supplicant_template.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf

# Vendor
$(call inherit-product, vendor/motorola/common/hardware/qcom/qcom-vendor.mk)

# VINTF
ifeq ($(call is-kernel-greater-than-or-equal-to,5.10),true)
  TARGET_USES_TETHER_V1_1 := true
endif
