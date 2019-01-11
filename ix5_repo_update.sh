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

apply_commit() {
    test $(git cat-file -t $1) == commit
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
echo "         applying ix5 patches...                  "
echo ""


pushd $ANDROOT/kernel/sony/msm-4.9/kernel
# Enable wakeup_gesture in dtsi table
# You need to discard vendor-sony-kernel or the build system will use
# precompiled dtb files, thus rendering this patch useless
git am < $PATCHES_PATH/kernel-dtsi-wakeup.patch
# tone: panel: set min brightness to 1.2mA
git am < $PATCHES_PATH/panel-minimum-brightness.patch
#tone: Enable ToF sensor for kagura and keyaki
git am < $PATCHES_PATH/kernel-enable-tof-sensor.patch
#tone: Enable RGBCIR sensor
git am < $PATCHES_PATH/kernel-rgbcr-sensor.patch
popd

# pushd $ANDROOT/kernel/sony/msm-4.9/kernel/arch/arm64/configs/sony
# Tone: use DRM for display
# git am < $PATCHES_PATH/defconfig-tone-use-drm.patch
# popd

pushd $ANDROOT/packages/apps/Bluetooth
# Disable email module for BluetoothInstrumentionTest
git am < $PATCHES_PATH/bluetooth-disable-email-test.patch
popd

pushd $ANDROOT/packages/apps/Launcher3
# Launcher3QuickStep: Remove useless QuickSearchbar
git am < $PATCHES_PATH/launcher3quickstep-remove-quicksearchbar.patch
popd

pushd $ANDROOT/packages/apps/ExtendedSettings
LINK=$HTTP && LINK+="://git.ix5.org/felix/sony-extendedsettings"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5
# Add deep sleep preference
git fetch $LINK d3df653da9e70ece8fca9de64cdc0100baf8b24c && git cherry-pick FETCH_HEAD
popd

pushd $ANDROOT/frameworks/base
# Enable development settings by default
git am < $PATCHES_PATH/enable-development-settings-by-default.patch
popd

pushd $ANDROOT/device/sony/common
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-common"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5
# git checkout 'selinux-enforcing'
# Switch selinux to enforcing
git fetch $LINK 1fc8e752c33ae07fe8c8f6d48abb2d1324b64536 && git cherry-pick FETCH_HEAD
set +e
if [ $(git tag -l "selinux-enforcing-temp-tag") ]; then
    git tag -d selinux-enforcing-temp-tag
fi
set -e
git tag selinux-enforcing-temp-tag
# TEMP: Set PRODUCT_FULL_TREBLE_OVERRIDE false
git fetch $LINK 0db7d41ae0d76f4d2a8627622921936d4e0626a8 && git cherry-pick FETCH_HEAD
set +e
if [ $(git tag -l "treble-override-temp-tag") ]; then
    git tag -d treble-override-temp-tag
fi
set -e
git tag treble-override-temp-tag

# git checkout 'add-vendor-ix5'
# Include vendor-ix5
git fetch $LINK b115cc3f7f98c1d26a6bd8b84422706128e3d0b7 && git cherry-pick FETCH_HEAD
# git checkout 'disable-privapp-perms-enforce'
# Disable: enforce privapp permissions
#git fetch $LINK 1418cfe786dbd046c13a0e2783af954056a45094 && git cherry-pick FETCH_HEAD

# git checkout 'tether-ipac-fix'
# marijns ipacm fix
#git fetch $LINK f75d5f0b81e3c011c05c75db7e55ddc22c432f39 && git cherry-pick FETCH_HEAD

popd

pushd $ANDROOT/device/sony/tone
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-tone"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'disable-verity-no-forceencrypt'
# Change forceencrypt to encryptable for userdata
git fetch $LINK af592265685fddf24100cbc1fdcdcb5bfd2260c1 && git cherry-pick FETCH_HEAD
# Disable dm-verity
git fetch $LINK b611c8d91a374f246be393d89f20bbf3fc2ab9f7 && git cherry-pick FETCH_HEAD

# Revert "media_profiles: increase video recording framerate"
#git revert a8cf2908fa80def497f9f312edd86402954627b8 --no-edit
popd


pushd $ANDROOT/system/sepolicy
#LINK=$HTTP && LINK+="://android.googlesource.com/system/sepolicy"
# HACK: Allow non-vendor PeripheralManager
# Change-Id: Iab6210b1501c01fa8f9006ce2a358b01a971d5db
#git fetch $LINK  refs/changes/92/861692/1 && git cherry-pick FETCH_HEAD
LINK=$HTTP && LINK+="://git.ix5.org/felix/aosp-system-sepolicy"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

#  HACK: Allow non-vendor PeripheralManager
git fetch $LINK 0dc858312a5606667a7d171a05a954a900a48384 && git cherry-pick FETCH_HEAD
popd


pushd $ANDROOT/device/sony/sepolicy

LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-sepolicy"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# TODO: Pick proper commits, branch is WIP right now
#git checkout ix5/broad-updates

# git checkout 'dt2w'
# Add contexts for wakeup_gesture
#git fetch $LINK 2cca619f81b7cfa9fbac9c209db1e752362f7ada && git cherry-pick FETCH_HEAD
popd


pushd $ANDROOT/device/sony/kagura
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-kagura"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'dt2w'
# Re-enable tap to wake
git fetch $LINK 90a80f6e42bfd2feca40fbdc8e2b046ff654032a && git cherry-pick FETCH_HEAD
# Turn dt2w off by default in settings
git fetch $LINK bc9df19ac1561281f2b10238d9007a803cfaaa06 && git cherry-pick FETCH_HEAD
# git checkout 'brightness'
# Set minimum brightness values to 2 and 1
git fetch $LINK 449f9eccfd292d968a98d08546062aedbf6e1a2d && git cherry-pick FETCH_HEAD
# git checkout 'rgbcir'
# Add preliminary RGBCIR calibration file
git fetch $LINK a0253f3de75c52bccb9275ee7eda6cd2f9db539c && git cherry-pick FETCH_HEAD
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
