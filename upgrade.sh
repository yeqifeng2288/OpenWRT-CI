#!/bin/sh
RELEASES_URL="https://github.com/yeqifeng2288/OpenWRT-CI/tags"
latest_release_page=$(curl -s $RELEASES_URL)

version=$(echo "$latest_release_page" | awk 'BEGIN{FS="IPQ60XX-WIFI-YES-VIKINGYFY-main-"; OFS=""}{split($2, a, " "); print a[1]}')
version=$(echo $version | awk -F'["]' '{print $1}')
echo $version
firmwares_name="immortalwrt.git-main_qualcommax-ipq60xx-jdcloud_re-ss-01-squashfs-sysupgrade-${version}.bin"
echo $firmwares_name
wget "https://github.com/yeqifeng2288/OpenWRT-CI/releases/download/IPQ60XX-WIFI-YES-VIKINGYFY-main-${version}/VIKINGYFY-main-qualcommax-ipq60xx-jdcloud_re-ss-01-squashfs-sysupgrade-${version}.bin" -O "/var/tmp/${firmwares_name}"
mkdir /mnt/mmcblk0p27/backup -p
cp /var/tmp/${firmwares_name} /mnt/mmcblk0p27/backup/${firmwares_name}
sysupgrade -F /var/tmp/${firmwares_name}
