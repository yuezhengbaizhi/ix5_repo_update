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
git revert --no-edit treble-override-temp-tag
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
git fetch $LINK ea176ca5bfa074a21e28b53f4be67b3a86858cda && git cherry-pick FETCH_HEAD
popd

pushd $ANDROOT/system/core
LINK=$HTTP && LINK+="://android.googlesource.com/platform/system/core"
# ld.config: Allow /vendor/odm paths in addition to /odm
git am < $PATCHES_PATH/system-core-ld.config-allow-vendor.patch
#git fetch $LINK refs/changes/76/859276/1 && git cherry-pick FETCH_HEAD
# init: Load build.prop from /vendor/odm as well
git fetch $LINK refs/changes/77/859277/1 && git cherry-pick FETCH_HEAD
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
