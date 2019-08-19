#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
now=$(date +"%T")
echo "Script Executed at : $now"

#This makes sure we use key sopd hals and modules 
#As we dont use sonyt interfaces this is needed 
export ALLOW_MISSING_DEPENDENCIES=true

#Remove dir that sony will use in the future not currently or u will get conflicts

rm -rf vendor/oss/external/exfat
rm -rf vendor/oss/interfaces/usb

rm -rf hardware/qcom/data/ipacfg-mgr/sdm845
git clone https://github.com/SonyAosp/platform_hardware_qcom_sdm845_data_ipacfg-mgr hardware/qcom/data/ipacfg-mgr/sdm845

rm -rf hardware/qcom/gps
git clone https://github.com/SonyAosp/platform_hardware_qcom_sdm845_gps hardware/qcom/gps

#Nuke Json (Already declared)
rm -rf device/sony/common/hardware/json-c

rm -rf vendor/qcom/opensource/bluetooth 
git clone https://github.com/sonyxperiadev/vendor-qcom-opensource-bluetooth vendor/qcom/opensource/bluetooth

rm -rf hardware/qcom/media
git clone https://github.com/SonyAosp/platform_hardware_qcom_media hardware/qcom/media

rm -rf hardware/qcom/media/sdm845
git clone https://github.com/SonyAosp/platform_hardware_qcom_sdm845_media hardware/qcom/media/sdm845

rm -rf hardware/qcom/display/sde
git clone https://github.com/SonyAosp/platform_hardware_qcom_display-caf hardware/qcom/display/sde

rm -rf hardware/nxp/nfc
git clone https://github.com/SonyAosp/platform_hardware_nxp_nfc hardware/nxp/nfc

rm -rf hardware/qcom/audio
git clone https://github.com/SonyAosp/platform_hardware_qcom_audio hardware/qcom/audio

rm -rf hardware/qcom/bootctrl
git clone https://github.com/SonyAosp/platform_hardware_qcom_bootctrl hardware/qcom/bootctrl

now=$(date +"%T")
echo "Script Finished at : $now"
