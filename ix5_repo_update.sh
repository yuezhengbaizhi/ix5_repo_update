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

echo "+++                                               +++"
echo "+++      applying ***ix5*** patches               +++"
echo "+++                                               +++"


pushd $ANDROOT/kernel/sony/msm-4.9/kernel
# Enable wakeup_gesture in dtsi table
# You need to discard vendor-sony-kernel or the build system will use
# precompiled dtb files, thus rendering this patch useless
git am < $PATCHES_PATH/kernel-dtsi-wakeup.patch
popd

pushd $ANDROOT/kernel/sony/msm-4.9/kernel/arch/arm64/configs/sony
# Tone: use DRM for display
git am < $PATCHES_PATH/defconfig-tone-use-drm.patch
popd

pushd $ANDROOT/packages/apps/Bluetooth
# Disable email module for BluetoothInstrumentionTest
git am < $PATCHES_PATH/bluetooth-disable-email-test.patch
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
# git checkout 'leds'
# Revert led paths
git fetch $LINK 30c55fb8f7032248e4c67269ef77e96df2d962c8 && git cherry-pick FETCH_HEAD

# git checkout 'use-sde'
# Testing: switch to new SDE display HAL
git fetch $LINK f9d8df7f57f26fe3c5a665e51199ee087e406190 && git cherry-pick FETCH_HEAD

LINK=$HTTP && LINK+="://github.com/sjllls/device-sony-tone"
(git remote --verbose | grep -q $LINK) || git remote add sjlls-tone $LINK
git fetch sjlls-tone

# Bump CPU frequency and increase min_cpus for video de/encoding
git fetch $LINK c657e25fff3887e71b316cff1f7000aa268e5d18 && git cherry-pick FETCH_HEAD

popd


pushd $ANDROOT/device/sony/kagura
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-kagura"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'dt2w'
# Re-enable tap to wake
git fetch $LINK 90a80f6e42bfd2feca40fbdc8e2b046ff654032a && git cherry-pick FETCH_HEAD
popd

pushd $ANDROOT/device/sony/common
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-common"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'add-vendor-ix5'
# Include vendor-ix5
git fetch $LINK b115cc3f7f98c1d26a6bd8b84422706128e3d0b7 && git cherry-pick FETCH_HEAD
# Include vendor-ix5 CommonConfig.mk
git fetch $LINK c65fe0d8322a189af8fc8f937d5cd4ef6403eca3 && git cherry-pick FETCH_HEAD

# git checkout 'disable-privapp-perms-enforce'
# Disable: enforce privapp permissions
git fetch $LINK 1418cfe786dbd046c13a0e2783af954056a45094 && git cherry-pick FETCH_HEAD
# git checkout 'odm-ver-1'
# Temporarily set expected odm version to 1
git fetch $LINK 8ea28fddf82a63e9776fe94317233459fe8f3f42 && git cherry-pick FETCH_HEAD

popd

# because "set -e" is used above, when we get to this point, we know
# all patches were applied successfully.
echo "+++                                               +++"
echo "+++ all *** ix5 *** patches applied successfully! +++"
echo "+++                                               +++"

set +e
