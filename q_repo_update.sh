#!/bin/bash

# exit script immediately if a command fails
set -e


ANDROOT=$PWD
HTTP=https
RESOLVED_REPO_PATH="$ANDROOT/$(dirname $(readlink $0))"
PATCHES_PATH=$RESOLVED_REPO_PATH/patches

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

commit_exists() {
    _sha1=$1
    git rev-parse --quiet --verify $_sha1^{commit}
}

apply_commit() {
    _commit=$1
    if commit_exists $_commit
    then
        git cherry-pick $_commit
    else
        git fetch $LINK $_commit && git cherry-pick $_commit
    fi
}

apply_gerrit_cl_commit() {
    _cl=$1
    _commit=$2
    if commit_exists $_commit
    then
        git cherry-pick $_commit
    else
        git fetch $LINK $_cl && git cherry-pick FETCH_HEAD
    fi
}

apply_pull_commit() {
    _pull=$1
    _commit=$2
    if commit_exists $_commit
    then
        git cherry-pick $_commit
    else
        git fetch $LINK pull/$_pull/head && git cherry-pick $_commit
    fi
}

echo ""
echo "         d8b          888888888"
echo "         Y8P          888"
echo "                      888"
echo "         888 888  888 8888888b."
echo "         888 ´Y8bd8P´      ´Y88b"
echo "         888   X88K          888"
echo "         888 .d8´´8b. Y88b  d88P"
echo "         888 888  888  ´Y8888P´"
echo ""
echo ""
echo "         applying ix5 patches..."
echo ""


pushd $ANDROOT/kernel/sony/msm-4.9/kernel
# Enable wakeup_gesture in dtsi table
# You need to discard vendor-sony-kernel or the build system will use
# precompiled dtb files, thus rendering this patch useless
#git am < $PATCHES_PATH/kernel-dtsi-wakeup.patch
# tone: panel: set min brightness to 1.2mA
git am < $PATCHES_PATH/panel-minimum-brightness.patch
popd

pushd $ANDROOT/kernel/sony/msm-4.9/common-kernel
# KernelConfig: Fix BUILD_KERNEL
git am < $PATCHES_PATH/q-common-kernel-fix-build-kernel-var.patch
popd

pushd $ANDROOT/build/make
# releasetools: Allow flashing downgrades
git am < $PATCHES_PATH/build-releasetools-allow-flashing-downgrades.patch

LINK=$HTTP && LINK+="://android.googlesource.com/platform/build"
# core/main: Strip bitness before existence check
apply_gerrit_cl_commit refs/changes/26/975126/2 0cad187889d47e3555b60fcc822a5cba6d15387f
popd

pushd $ANDROOT/build/soong
# Android.bp: Fake Windows libwinpthread deps
git am < $PATCHES_PATH/q-build-soong-fake-libwinpthread.patch
popd

pushd $ANDROOT/packages/apps/Bluetooth
# Disable email module for BluetoothInstrumentionTest
git am < $PATCHES_PATH/q-bluetooth-disable-email-test.patch
popd

pushd $ANDROOT/packages/apps/Launcher3
# Launcher3QuickStep: Remove useless QuickSearchbar
git am < $PATCHES_PATH/launcher3quickstep-remove-quicksearchbar.patch
popd

pushd $ANDROOT/frameworks/base
# Enable development settings by default
git am < $PATCHES_PATH/enable-development-settings-by-default.patch
popd

pushd $ANDROOT/hardware/interfaces
# FIXME: compatibility: Allow radio@1.1
git am < $PATCHES_PATH/hardware-interfaces-allow-radio-1-1-.patch
popd

pushd $ANDROOT/device/sony/common
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-common"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'add-vendor-ix5'
# Include vendor-ix5 via common.mk
apply_commit 891d072a7e515d7e69b075b587a7baf569b54b14

# init: Remove verity statements
apply_commit 6c33a4a8f5fe4615235df9d7abcfe3644f299672

# TODO: Remove me once merged into Q/master
# git checkout 'vintf-enforce'
# Enforce usage of vintf manifest
apply_commit 5df1a36972a8709f76463f8fe184d472e75d93a1

# git checkout 'vintf-healthd'
# common-treble: Remove healthd vintf exclude
apply_commit a6b628e6a2b4c33233860960d874a176c340229b

# git checkout 'vintf-remove-mediacas'
# vintf: Remove duplicate IMediaCas HAL
apply_commit 1f5ab5b3487567bf542a6cd40bd8cc9d5db17d75

# git checkout 'vintf-target-level-4'
# vintf: Set target-level=4 for Q
apply_commit 0a21146905c7f9bfbd3791855b791d6642345fb2

# git checkout 'vintf-radio-1-1-'
# vintf: Lower radio version to 1.1
apply_commit 25d4d23c987cb6ff63c0462ff6ced0d389deec7b

# git checkout 'remove-packages'
# common-packages: Remove p2p_supplicant.conf
apply_commit 16b818d79d1fab29bb24dc8a9281621e88c52cce
# common-packages: Remove libemoji
apply_commit b5790e2affe1e0707e0cfaef4b550e3b17fc5acf
# common-treble: nfc: Remove @1.1-impl
apply_commit f0bc81b29670a8b6402dc1c26b47da60a0ea4701

LINK=$HTTP && LINK+="://github.com/sonyxperiadev/device-sony-common"
# TODO: Remove me once merged into Q/master

# https://github.com/sonyxperiadev/device-sony-common/pull/608
# Remove gps_debug.conf
apply_pull_commit 608 37f78456f546d59507b58af140e943d617863cc6

# https://github.com/sonyxperiadev/device-sony-common/pull/609
# qcom/utils.mk: Use ?= for definitions
apply_pull_commit 609 5ed2a553e443f617c79c6e7bd2bb6a8ebc218ff4

# https://github.com/sonyxperiadev/device-sony-common/pull/610
# [Q-COMPAT] Move kernel includes to common.mk
apply_pull_commit 610 1bf9381b197fde93b3d74dd30fb7579aae84c2f7
# common.mk: Make BUILD_KERNEL customizable
apply_pull_commit 610 673508ec65ba23256e7ca0e376ba130ce3ae9859

# https://github.com/sonyxperiadev/device-sony-common/pull/617
# odm: Use PRODUCT_ODM_PROPERTIES for version
apply_pull_commit 617 ed050fa6f371128d4b1524e3e2c90e89eafb5de2
# odm: Only build if SONY_BUILD_ODM is set
apply_pull_commit 617 5f010feaa144219d4ab903a7b63d43dc373e739a
# odm: Include qti blobs in common-odm
apply_commit f8fe5fb700c9e6410a1d4be3696ec1dd90f49841

# https://github.com/sonyxperiadev/device-sony-common/pull/616
# power: No subsystem stats in user builds
apply_pull_commit 616 76fc5c2fb36a3f1bfe24d51daa04caeb5ce14fdb

# https://github.com/sonyxperiadev/device-sony-common/pull/615
# power: Add interface info to .rc
apply_pull_commit 615 bcc1358c046cfac4b06a0faa3c0350e1d412760b
# power: Fix unused var in Hints.cpp
apply_pull_commit 615 ff71c5951b3ace5c48eef2ab094c3955af0105d4

# https://github.com/sonyxperiadev/device-sony-common/pull/613
# init: Change toybox SELinux run context
apply_pull_commit 613 aa92c5824275d9b848f563aebe9b4a2a66c0eb76
# init: Wipe updated xattr from /persist/
apply_pull_commit 613 305913cf13ee4d405783fd35d20ce47341313f2c

# https://github.com/sonyxperiadev/device-sony-common/pull/620
# common-packages: Add netutils-wrapper
apply_pull_commit 620 68fb5cd8288242315869a77588c6a37900f7bcfe

# https://github.com/sonyxperiadev/device-sony-common/pull/606
# Revert "common-prop: Enable dmic fluence for voicerec case"
apply_pull_commit 606 fe3f8ffb83a0f0a729aa8294c3fc8b39961d4bd4
popd


pushd $ANDROOT/device/sony/sepolicy
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-sepolicy"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'q-sepolicy-version'
# Q: TEMP: Set sepolicy version to match master
apply_commit 64501e76d4daced00ef64f4a9bb08e99b7ad650e

# git checkout 'toybox-vendor-init'
# Add vendor_toolbox context
apply_commit 8bfd45c7f845ab357e7117382ebf189e06d16d33
# vendor_toolbox: Allow removing xattr from /persist
apply_commit 46959678c910300d687fcc72cd5a2aae0af6e28f
# vendor_init: Strip unneeded toybox-related permissions
apply_commit 96ae44e5fa6784f50f6e63f5a5762d723080ebff

# git checkout 'kernel-socket'
# kernel: debugfs_wlan only in debug builds
apply_commit 444894b98f8d14c3f0b64a1ba23b19a907638b2f

# git checkout 'remove-dupe-idc-keylayout-noconflict'
# [NOCONFLICT] Remove duplicated idc file defs
apply_commit a8729c24ead8c84c881d0ab4546a2c89832de6c1

# git checkout 'remove-nontreble-remnants'
# netutils: Remove unused legacy access
apply_commit 7f708f5aea5babb8009be49f1e5b4094cfff21ed

# git checkout 'genfscon-remove-sysfs-net'
# genfscon: Remove duplicate sysfs_net entries
apply_commit c086d8a5bd1daa4d27717154e76c97044c8e958c
popd


pushd $ANDROOT/device/sony/tone
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-tone"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'disable-verity-no-forceencrypt'
# Change forceencrypt to encryptable for userdata
apply_commit af592265685fddf24100cbc1fdcdcb5bfd2260c1
# Disable dm-verity
apply_commit b611c8d91a374f246be393d89f20bbf3fc2ab9f7
popd

# git checkout 'q-bdroid-property-length'
# bdroid_buildcfg: Fix PROPERTY_VALUE_MAX definition
apply_commit cf984bcab9ff623d07ea838b5f393281f157f1af

# git checkout 'q-product-build-bootimg'
# platform: Build boot image
apply_commit 19f8a85dcd7d2f1412579b1f0d8da7400552882f

# git checkout 'treble-buildvars'
# platform/Platform: Enable VNDK, linker ns
apply_commit 25e58e5989bb4f50845e83b0349811102b5a69b3
popd


pushd $ANDROOT/device/sony/kagura
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-kagura"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'lunch'
# Switch from add_lunch_combo to COMMON_LUNCH_CHOICES
apply_commit 383d2594a89ca7076df06a701d3cf5c76fff9e3e

# git checkout 'dt2w'
# Re-enable tap to wake
#apply_commit 90a80f6e42bfd2feca40fbdc8e2b046ff654032a
# Turn dt2w off by default in settings
#apply_commit bc9df19ac1561281f2b10238d9007a803cfaaa06
# git checkout 'brightness'
# Set minimum brightness values to 2 and 1
apply_commit 449f9eccfd292d968a98d08546062aedbf6e1a2d
# git checkout 'rgbcir'
# Add preliminary RGBCIR calibration file
#apply_commit a0253f3de75c52bccb9275ee7eda6cd2f9db539c
popd

pushd $ANDROOT/vendor/qcom/opensource/camera
LINK=$HTTP && LINK+="://github.com/sonyxperiadev/camera"
# https://github.com/sonyxperiadev/camera/pull/113
# Makefiles: Remove "eng" from LOCAL_MODULE_TAGS
apply_pull_commit 113 7e0b2f7224d60726ff828d9a008dce4c7d345633
popd

pushd $ANDROOT/vendor/qcom/opensource/location
LINK=$HTTP && LINK+="://github.com/sonyxperiadev/vendor-qcom-opensource-location"
# https://github.com/sonyxperiadev/vendor-qcom-opensource-location/pull/19
# loc_api: Fix: Use lu in log format
apply_pull_commit 19 173655ffc2775dca6f808020e859850e47311a1b
popd

pushd $ANDROOT/hardware/qcom/display/sde
LINK=$HTTP && LINK+="://github.com/sonyxperiadev/hardware-qcom-display"
# https://github.com/sonyxperiadev/hardware-qcom-display/pull/22
# hwc2: Fix compile errors in switch statement.
apply_pull_commit 22 7da54855b89a67a2f43514f62bedce49f1a4b3c3
# libqdutils: Fix duplicated header
apply_pull_commit 22 32827304b117684a3cd2a2ff3d8d115ffc0246f1
#  Makefile: Add -fPIC to common_flags
apply_pull_commit 22 b3bdde9600dda7f41da63b2c55e14afd77fc5af8
popd

# because "set -e" is used above, when we get to this point, we know
# all patches were applied successfully.
echo ""
echo "         d8b          888888888"
echo "         Y8P          888"
echo "                      888"
echo "         888 888  888 8888888b."
echo "         888 ´Y8bd8P´      ´Y88b"
echo "         888   X88K          888"
echo "         888 .d8´´8b. Y88b  d88P"
echo "         888 888  888  ´Y8888P´"
echo ""
echo ""
echo "         all ix5 patches applied successfully!"
echo ""


set +e
