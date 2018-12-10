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
#tone: Enable ToF sensor for kagura and keyaki
git am < $PATCHES_PATH/kernel-enable-tof-sensor.patch
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
git fetch ix5
# git checkout 'selinux-enforcing'
# Switch selinux to enforcing
git fetch $LINK 1fc8e752c33ae07fe8c8f6d48abb2d1324b64536 && git cherry-pick FETCH_HEAD
# TEMP: Set PRODUCT_FULL_TREBLE_OVERRIDE false
git fetch $LINK 0db7d41ae0d76f4d2a8627622921936d4e0626a8 && git cherry-pick FETCH_HEAD

# git checkout 'add-vendor-ix5'
# Include vendor-ix5
git fetch $LINK b115cc3f7f98c1d26a6bd8b84422706128e3d0b7 && git cherry-pick FETCH_HEAD
# git checkout 'disable-privapp-perms-enforce'
# Disable: enforce privapp permissions
#git fetch $LINK 1418cfe786dbd046c13a0e2783af954056a45094 && git cherry-pick FETCH_HEAD
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
popd


pushd $ANDROOT/device/sony/sepolicy

LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-sepolicy"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'vendor-updates'
# squashed WRONG master commits
git fetch $LINK f629f9b038e0fcb3bcfb305cbc246e819fb1ed51 && git cherry-pick FETCH_HEAD
# TEMPORARY: Allow per_mgr and friends to use system binder, more odd permission leaks
git fetch $LINK 390d2d97612aabdf7b4531040106d0c532f4169f && git cherry-pick FETCH_HEAD
# TEMP: add more perms
git fetch $LINK 8bdabc62535637c25d93a138d5231aa72c875949 && git cherry-pick FETCH_HEAD
# Update cameraserver policy
git fetch $LINK ec25830f189cab04ba49daf37ed68c8f16933027 && git cherry-pick FETCH_HEAD
# Add contexts for wakeup_gesture
git fetch $LINK b773f959a24d15cb77f36f0fe830a329651ed5e1 && git cherry-pick FETCH_HEAD
# Allow hostapd to search wifi dirs
git fetch $LINK 83d28b7b8fc74105f26eaf78206b8964d73a055b && git cherry-pick FETCH_HEAD
# TEMP: Integrate new patches, cleanup
git fetch $LINK f728d6d94c609c315236b690972f1bf4ec44a940 && git cherry-pick FETCH_HEAD


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
