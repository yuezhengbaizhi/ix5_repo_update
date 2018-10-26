#!/bin/bash

# exit script immediately if a command fails
set -e

ANDROOT=$PWD
HTTP=https

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

echo "+++ applying ***ix5*** patches +++"

pushd $ANDROOT/device/sony/tone
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-tone"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

#git checkout 'disable-verity-no-forceencrypt'
# Change forceencrypt to encryptable for userdata
git fetch $LINK af592265685fddf24100cbc1fdcdcb5bfd2260c1 && git cherry-pick FETCH_HEAD
# Disable dm-verity
git fetch $LINK b611c8d91a374f246be393d89f20bbf3fc2ab9f7 && git cherry-pick FETCH_HEAD
popd

pushd $ANDROOT/device/sony/common
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-common"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

#git checkout 'pixel-colors'
# Add pixel colors
git fetch $LINK dee417b874ffb6683677f1db10038ce615124ad8 && git cherry-pick FETCH_HEAD
# Add default wallpaper from unsplash
git fetch $LINK 4ab8162805d3ac98a831477d053243adfa0f9582 && git cherry-pick FETCH_HEAD

#git checkout 'systemui-tweaks'
# Enable swipe-up gesture for homescreen by default
git fetch $LINK 15c2820159a2440a87010b92b6befe0db0818d13 && git cherry-pick FETCH_HEAD
# Enable keyguard shortcuts
git fetch $LINK 611a5f3013fda21b2605581a243f363ac2d4b256 && git cherry-pick FETCH_HEAD
# Fix quicksettings layout
git fetch $LINK da4a15ce6496ce32fd6cef9b389698dd6e3da8c0 && git cherry-pick FETCH_HEAD
# Don't style buttons in ALL CAPS
git fetch $LINK b2a820fd0d4613e785d00f352853deeb108f9f33 && git cherry-pick FETCH_HEAD

#git checkout 'night-light'
# Try fixing nightlight
git fetch $LINK 83438e5448dafe25bc22490c9189d426eac02a83 && git cherry-pick FETCH_HEAD
popd

# because "set -e" is used above, when we get to this point, we know
# all patches were applied successfully.
echo "+++ all ***ix5**** patches applied successfully! +++"

set +e
