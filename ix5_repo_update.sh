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
popd

# pushd $ANDROOT/kernel/sony/msm-4.9/kernel/arch/arm64/configs/sony
# Tone: use DRM for display
# git am < $PATCHES_PATH/defconfig-tone-use-drm.patch
# popd

pushd $ANDROOT/packages/apps/Bluetooth
# Disable email module for BluetoothInstrumentionTest
git am < $PATCHES_PATH/bluetooth-disable-email-test.patch
popd

pushd $ANDROOT/device/sony/common
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-common"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
# git checkout 'selinux-enforcing'
# Switch selinux to enforcing
git fetch $LINK 1fc8e752c33ae07fe8c8f6d48abb2d1324b64536 && git cherry-pick FETCH_HEAD
# TEMP: Set PRODUCT_FULL_TREBLE_OVERRIDE false
git fetch $LINK 0db7d41ae0d76f4d2a8627622921936d4e0626a8 && git cherry-pick FETCH_HEAD
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

# git checkout 'use-sde'
# Testing: switch to new SDE display HAL
# git fetch $LINK f9d8df7f57f26fe3c5a665e51199ee087e406190 && git cherry-pick FETCH_HEAD

# LINK=$HTTP && LINK+="://github.com/sjllls/device-sony-tone"
# (git remote --verbose | grep -q $LINK) || git remote add sjlls-tone $LINK

# Bump CPU frequency and increase min_cpus for video de/encoding
# git fetch $LINK c657e25fff3887e71b316cff1f7000aa268e5d18 && git cherry-pick FETCH_HEAD

popd


pushd $ANDROOT/device/sony/sepolicy

LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-sepolicy"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'vendor-updates'
# TEMPORARY: Allow per_mgr and friends to use system binder.
# Change-Id: I7d7da5eecdc4b469129638de90de92b538eb2b5e
git fetch $LINK 5de7bb29e03f515faf704af6178a759e93e034a3 && git cherry-pick FETCH_HEAD
# More odd permission leaks.
# Change-Id: I5a828edc4554c85bea6a4d8838c9b39c36f68466
git fetch $LINK 5bed36fc0a432ddb5cc32891185c06df282f03ec && git cherry-pick FETCH_HEAD
# TEMP: add more perms
git fetch $LINK f9e568a080a48131604900f825dc1efe2516a1f9 && git cherry-pick FETCH_HEAD
# TEMP: more hacks for qcilam
git fetch $LINK 7efaf67f0f83bef113e7a18ff39f84a0f928f080 && git cherry-pick FETCH_HEAD
# Update cameraserver policy
git fetch $LINK 18370a5bbe8f26ba19165af4c549fc1f01929a5d && git cherry-pick FETCH_HEAD

# Add contexts for wakeup_gesture
git fetch $LINK 12aa9f31bb4ab9f422e3e95a2d003b4665bb67b1 && git cherry-pick FETCH_HEAD
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
popd

pushd $ANDROOT/device/sony/common
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-common"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'add-vendor-ix5'
# Include vendor-ix5
git fetch $LINK b115cc3f7f98c1d26a6bd8b84422706128e3d0b7 && git cherry-pick FETCH_HEAD
# Include vendor-ix5 CommonConfig.mk (to set selinux to "enforcing")
#git fetch $LINK c65fe0d8322a189af8fc8f937d5cd4ef6403eca3 && git cherry-pick FETCH_HEAD

# git checkout 'disable-privapp-perms-enforce'
# Disable: enforce privapp permissions
#git fetch $LINK 1418cfe786dbd046c13a0e2783af954056a45094 && git cherry-pick FETCH_HEAD
# git checkout 'odm-ver-1'
# Temporarily set expected odm version to 1
# git fetch $LINK 8ea28fddf82a63e9776fe94317233459fe8f3f42 && git cherry-pick FETCH_HEAD

# git checkout 'sde-msm8998'
# [temp] Set QCOM_MEDIA_ROOT for legacy devices
#git fetch $LINK ce3d0729a81c53180d547b5bdef385bd231bb5ae && git cherry-pick FETCH_HEAD

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
