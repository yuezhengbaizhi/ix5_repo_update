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
echo "  ████████╗██████╗ ███████╗██████╗ ██╗     ███████╗"
echo "  ╚══██╔══╝██╔══██╗██╔════╝██╔══██╗██║     ██╔════╝"
echo "     ██║   ██████╔╝█████╗  ██████╔╝██║     █████╗"
echo "     ██║   ██╔══██╗██╔══╝  ██╔══██╗██║     ██╔══╝"
echo "     ██║   ██║  ██║███████╗██████╔╝███████╗███████╗"
echo "     ╚═╝   ╚═╝  ╚═╝╚══════╝╚═════╝ ╚══════╝╚══════╝"
echo ""
echo "              applying treble patches..."
echo ""

pushd $ANDROOT/kernel/sony/msm-4.9/kernel
git am < $PATCHES_PATH/dtsi-tone-conjure-oem-into-vendor.patch
git am < $PATCHES_PATH/dtsi-loire-conjure-oem-into-vendor.patch
popd

pushd $ANDROOT/device/sony/common
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-common"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
# Revert: Switch selinux to enforcing
# (needed because there might be problems with misbehaving GSI sepolicies)
git revert --no-edit selinux-enforcing-temp-tag

# git checkout 'treble-odm'
# Use oem as /vendor
git fetch $LINK b2ea2ed04d6066a56147d9333cbe19093642ef45 && git cherry-pick FETCH_HEAD

# git checkout 'extra-odm-symlinks'
# Add extra odm symlinks
#git fetch $LINK 0204402094868621e7c859d1521d7f5d4fda3259 && git cherry-pick FETCH_HEAD
popd


pushd $ANDROOT/device/sony/tone
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-tone"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
# git checkout 'treble-odm'
# Use oem as /vendor
git fetch $LINK 025f56891b9d6ec3a86f0c84fab534119a3b2006 && git cherry-pick FETCH_HEAD
popd

pushd $ANDROOT/device/sony/loire
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-loire"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
# git checkout 'treble-odm'
# Use oem as /vendor
git fetch $LINK 1170e85e4567e44314eff0b55566957632c8b2bc && git cherry-pick FETCH_HEAD
popd

pushd $ANDROOT/system/core
LINK=$HTTP && LINK+="://android.googlesource.com/platform/system/core"
# ld.config: Allow /vendor/odm paths in addition to /odm
#git am < $PATCHES_PATH/system-core-ld.config-allow-vendor.patch
#git fetch $LINK refs/changes/76/859276/1 && git cherry-pick FETCH_HEAD
# init: Load build.prop from /vendor/odm as well
git fetch $LINK refs/changes/77/859277/1 && git cherry-pick FETCH_HEAD
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


# because "set -e" is used above, when we get to this point, we know
# all patches were applied successfully.
echo ""
echo "  ████████╗██████╗ ███████╗██████╗ ██╗     ███████╗"
echo "  ╚══██╔══╝██╔══██╗██╔════╝██╔══██╗██║     ██╔════╝"
echo "     ██║   ██████╔╝█████╗  ██████╔╝██║     █████╗"
echo "     ██║   ██╔══██╗██╔══╝  ██╔══██╗██║     ██╔══╝"
echo "     ██║   ██║  ██║███████╗██████╔╝███████╗███████╗"
echo "     ╚═╝   ╚═╝  ╚═╝╚══════╝╚═════╝ ╚══════╝╚══════╝"
echo ""
echo "        all treble patches applied successfully!"
echo ""


echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo ""
echo "        DO NOT FORGET TO UPDATE SEPOLICY!!!!!"
echo ""
echo "         ELSE YOUR DEVICE WILL NOT BOOT!!!!"
echo ""
echo ""
echo "          ALSO COPY THE ODM FILES!!!!"
echo ""

set +e
