#!/bin/sh
RELEASES_URL="https://github.com/yeqifeng2288/OpenWRT-CI/tags"
latest_release_page=$(curl -s $RELEASES_URL)

version=$(echo "$latest_release_page" | awk 'BEGIN{FS="IPQ60XX-WIFI-YES_immortalwrt\.git-main_"; OFS=""}{split($2, a, " "); print a[1]}')
version=$(echo $version |  awk -F'["]' '{print $1}')
echo $version
firmwares_name="immortalwrt.git-main_jdcloud_ax1800-pro-squashfs-sysupgrade_${version}.bin"
echo $firmwares_name
wget "https://github.com/yeqifeng2288/OpenWRT-CI/releases/download/IPQ60XX-WIFI-YES_immortalwrt.git-main_$version/immortalwrt.git-main_jdcloud_ax1800-pro-squashfs-sysupgrade_${version}.bin" -O "/tmp/${firmwares_name}"
sysupgrade /tmp/$firmwares_name
