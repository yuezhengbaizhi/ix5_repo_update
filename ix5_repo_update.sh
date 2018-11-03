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

echo "+++                                               +++"
echo "+++      applying ***ix5*** patches               +++"
echo "+++                                               +++"


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


pushd $ANDROOT/device/sony/kagura
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-kagura"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'taptowake'
# Re-enable tap to wake
#git fetch $LINK ffc06d3e7befb4e7234243481101bd5324b9609f && git cherry-pick FETCH_HEAD
popd

pushd $ANDROOT/device/sony/common
LINK=$HTTP && LINK+="://git.ix5.org/felix/device-sony-common"
(git remote --verbose | grep -q $LINK) || git remote add ix5 $LINK
git fetch ix5

# git checkout 'add-vendor-ix5'
# Include vendor-ix5
git fetch $LINK b115cc3f7f98c1d26a6bd8b84422706128e3d0b7 && git cherry-pick FETCH_HEAD

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
