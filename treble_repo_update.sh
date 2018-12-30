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
git am < $PATCHES_PATH/kernel-dtsi-vendor-odm.patch
popd

pushd $ANDROOT/device/sony/common
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-common"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
# Revert: TEMP: Set PRODUCT_FULL_TREBLE_OVERRIDE false
git fetch $LINK 0db7d41ae0d76f4d2a8627622921936d4e0626a8 && git cherry-pick FETCH_HEAD
# Revert: Switch selinux to enforcing
# (needed because there might be problems with misbehaving GSI sepolicies)
git fetch revert 1fc8e752c33ae07fe8c8f6d48abb2d1324b64536 --no-edit

# git checkout 'treble-odm'
# Use oem as /vendor
git fetch $LINK c2c9551fbe2bd2c796380fa9405ae2f0edecc72d && git cherry-pick FETCH_HEAD

# git checkout 'extra-odm-symlinks'
# Add extra odm symlinks
git fetch $LINK 53e7e88230149df582af045489b778d5d7425660 && git cherry-pick FETCH_HEAD
popd


pushd $ANDROOT/device/sony/tone
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-tone"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
# git checkout 'treble-odm'
# Use oem as /vendor
git fetch $LINK ea176ca5bfa074a21e28b53f4be67b3a86858cda && git cherry-pick FETCH_HEAD
popd

pushd $ANDROOT/system/core
LINK=$HTTP && LINK+="://android.googlesource.com/platform/system/core"
# ld.config: Allow /vendor/odm paths in addition to /odm
git fetch $LINK refs/changes/76/859276/1 && git checkout FETCH_HEAD
# init: Load build.prop from /vendor/odm as well
git fetch $LINK refs/changes/77/859277/1 && git checkout FETCH_HEAD
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

set +e