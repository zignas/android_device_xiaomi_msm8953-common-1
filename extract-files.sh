#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2018-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

LINEAGE_ROOT="${MY_DIR}"/../../..

HELPER="${LINEAGE_ROOT}/vendor/lineage/build/tools/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=false

ONLY_COMMON=
ONLY_TARGET=
SECTION=
KANG=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-common )
                ONLY_COMMON=true
                ;;
        --only-target )
                ONLY_TARGET=true
                ;;
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

if [ -z "${ONLY_TARGET}" ]; then
    # Initialize the helper for common device
    setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${LINEAGE_ROOT}" true "${CLEAN_VENDOR}"

    extract "${MY_DIR}/proprietary-files-qc.txt" "${SRC}" \
            "${KANG}" --section "${SECTION}"
fi

if [ -z "${ONLY_COMMON}" ] && [ -s "${MY_DIR}/../${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${LINEAGE_ROOT}" false "${CLEAN_VENDOR}"

    extract "${MY_DIR}/../${DEVICE}/proprietary-files.txt" "${SRC}" \
            "${KANG}" --section "${SECTION}"
fi

DEVICE_BLOB_ROOT="$LINEAGE_ROOT"/vendor/"$VENDOR"/"$DEVICE"/proprietary

if [ "$DEVICE" = "tissot" ]; then
patchelf --remove-needed libbacktrace.so "$DEVICE_BLOB_ROOT"/vendor/lib64/hw/gf_fingerprint.default.so
patchelf --remove-needed libunwind.so "$DEVICE_BLOB_ROOT"/vendor/lib64/hw/gf_fingerprint.default.so
patchelf --remove-needed libkeystore_binder.so "$DEVICE_BLOB_ROOT"/vendor/lib64/hw/gf_fingerprint.default.so
patchelf --remove-needed libsoftkeymasterdevice.so "$DEVICE_BLOB_ROOT"/vendor/lib64/hw/gf_fingerprint.default.so
patchelf --remove-needed libsoftkeymaster.so "$DEVICE_BLOB_ROOT"/vendor/lib64/hw/gf_fingerprint.default.so
patchelf --remove-needed libkeymaster_messages.so "$DEVICE_BLOB_ROOT"/vendor/lib64/hw/gf_fingerprint.default.so

sed -i "s/libbinder.so/libbindfp.so/" "$DEVICE_BLOB_ROOT"/vendor/lib64/libgoodixfingerprintd_binder.so
patchelf --remove-needed libbacktrace.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libgoodixfingerprintd_binder.so
patchelf --remove-needed libunwind.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libgoodixfingerprintd_binder.so
patchelf --remove-needed libkeystore_binder.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libgoodixfingerprintd_binder.so
patchelf --remove-needed libsoftkeymasterdevice.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libgoodixfingerprintd_binder.so
patchelf --remove-needed libsoftkeymaster.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libgoodixfingerprintd_binder.so

patchelf --remove-needed libbacktrace.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so
patchelf --remove-needed libunwind.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so
patchelf --remove-needed libkeystore_binder.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so
patchelf --remove-needed libsoftkeymasterdevice.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so
patchelf --remove-needed libsoftkeymaster.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so
patchelf --remove-needed libkeymaster_messages.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so

patchelf --remove-needed libbacktrace.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0.so
patchelf --remove-needed libunwind.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0.so
patchelf --remove-needed libkeystore_binder.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0.so
patchelf --remove-needed libsoftkeymasterdevice.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0.so
patchelf --remove-needed libsoftkeymaster.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0.so
patchelf --remove-needed libkeymaster_messages.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0.so

fi

if [ "$DEVICE" = "mido" ] || [ "$DEVICE" = "tissot" ]; then
    # Hax for cam configs
    CAMERA2_SENSOR_MODULES="$LINEAGE_ROOT"/vendor/"$VENDOR"/"$DEVICE"/proprietary/vendor/lib/libmmcamera2_sensor_modules.so
    sed -i "s|/system/etc/camera/|/vendor/etc/camera/|g" "$CAMERA2_SENSOR_MODULES"
fi

"$MY_DIR"/setup-makefiles.sh
