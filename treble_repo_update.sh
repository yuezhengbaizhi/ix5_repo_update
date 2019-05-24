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
# Use oem as /vendor and add treble quirks
apply_commit 2ba4c51c8952619d4df40ed16ec91f4c16924b6b

# git checkout 'extra-odm-symlinks'
# Add extra odm symlinks
#apply_commit 0204402094868621e7c859d1521d7f5d4fda3259
popd


pushd $ANDROOT/device/sony/tone
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-tone"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
# git checkout 'treble-odm'
# Use oem as /vendor
apply_commit 025f56891b9d6ec3a86f0c84fab534119a3b2006
popd

pushd $ANDROOT/device/sony/loire
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-loire"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
# git checkout 'treble-odm'
# Use oem as /vendor
apply_commit 1170e85e4567e44314eff0b55566957632c8b2bc
popd

pushd $ANDROOT/system/core
LINK=$HTTP && LINK+="://android.googlesource.com/platform/system/core"
# ld.config: Allow /vendor/odm paths in addition to /odm
#git am < $PATCHES_PATH/system-core-ld.config-allow-vendor.patch
#apply_commit refs/changes/76/859276/1 4f76802207b21313ddcbb8cd5e074897020f1e21
# init: Load build.prop from /vendor/odm as well
apply_gerrit_cl_commit refs/changes/77/859277/1 0e598b50912a3a0c720812a2bb5fb81a3b0458cd
popd

#pushd $ANDROOT/system/sepolicy
#LINK=$HTTP && LINK+="://android.googlesource.com/system/sepolicy"
# HACK: Allow non-vendor PeripheralManager
# Change-Id: Iab6210b1501c01fa8f9006ce2a358b01a971d5db
#apply_commit  refs/changes/92/861692/1 6a33ce20131780cc8172f1f99dfd081264d62df1
#LINK=$HTTP && LINK+="://git.ix5.org/felix/aosp-system-sepolicy"
#(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
#git fetch ix5
#
#  HACK: Allow non-vendor PeripheralManager
#apply_commit 0dc858312a5606667a7d171a05a954a900a48384
#popd


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
echo "        DO NOT FORGET TO INCLUDE device/sony/customization!!!"
echo ""
echo "         ELSE YOUR DEVICE WILL NOT BOOT!!!!"
echo ""
echo ""
echo "          ALSO COPY THE ODM FILES!!!!"
echo ""

set +e
