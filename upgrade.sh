#!/bin/sh

API_URL="https://api.github.com/repos/yeqifeng2288/OpenWRT-CI/releases/latest"

echo "Fetching latest release from $API_URL..."
latest_release_json=$(curl -s "$API_URL")

# Extract the sysupgrade bin download URL from JSON
download_url=$(echo "$latest_release_json" | grep -o '"browser_download_url": *"[^"]*-jdcloud_re-ss-01-squashfs-sysupgrade-VIKINGYFY-main-wifi-yes-[^"]*\.bin"' | awk -F'"' '{print $4}' | head -n 1)

if [ -z "$download_url" ]; then
    echo "Error: Cannot find sysupgrade firmware URL in the latest release."
    exit 1
fi

firmwares_name=$(basename "$download_url")
echo "Found latest firmware: $firmwares_name"

echo "Downloading $firmwares_name to /var/tmp/ ..."
wget "$download_url" -O "/var/tmp/${firmwares_name}"

if [ ! -f "/var/tmp/${firmwares_name}" ]; then
    echo "Error: Firmware download failed."
    exit 1
fi

# Calculate local SHA256
local_sha=$(sha256sum "/var/tmp/${firmwares_name}" | awk '{print $1}')
echo "Local SHA256: $local_sha"

# Determine expected SHA256
expected_sha=""

# Try downloading sha256sums file
release_tag=$(echo "$download_url" | awk -F'/' '{print $(NF-1)}')
sha256sums_url="https://github.com/yeqifeng2288/OpenWRT-CI/releases/download/${release_tag}/sha256sums"

curl -sL "$sha256sums_url" -o /var/tmp/sha256sums
if [ -f /var/tmp/sha256sums ] && grep -q "$firmwares_name" /var/tmp/sha256sums; then
    expected_sha=$(grep "$firmwares_name" /var/tmp/sha256sums | awk '{print $1}')
    echo "Found SHA256 in sha256sums file: $expected_sha"
else
    # Fallback to extract digest from GitHub API JSON response
    # 1. Strip all newlines to make the JSON a single line string.
    # 2. Use awk to split the string using '"name":' as the field separator. 
    #    This ensures each file's properties are isolated into separate fields.
    # 3. Find the field containing our target filename and extract the digest from it.
    expected_sha=$(echo "$latest_release_json" | tr -d '\n\r' | awk -F '"name":' -v fname="$firmwares_name" '{
        for(i=1; i<=NF; i++) {
            if (index($i, fname) > 0) {
                if (match($i, /"digest": *"sha256:[a-f0-9]+/)) {
                    val = substr($i, RSTART, RLENGTH);
                    idx = index(val, "sha256:");
                    print substr(val, idx+7, 64);
                }
            }
        }
    }' | head -n 1)
    
    if [ -n "$expected_sha" ]; then
        echo "Found SHA256 in GitHub API digest: $expected_sha"
    fi
fi

if [ -n "$expected_sha" ]; then
    if [ "$local_sha" != "$expected_sha" ]; then
        echo "Error: SHA256 checksum mismatch!"
        echo "Expected: $expected_sha"
        echo "Actual:   $local_sha"
        rm -f "/var/tmp/${firmwares_name}"
        exit 1
    else
        echo "SHA256 verification passed successfully!"
    fi
else
    echo "Warning: Could not find an expected SHA256 sum for validation."
    echo "Using 'sysupgrade -T' to verify the firmware image header instead..."
    if ! sysupgrade -T "/var/tmp/${firmwares_name}"; then
        echo "Error: Firmware image validation failed!"
        rm -f "/var/tmp/${firmwares_name}"
        exit 1
    fi
    echo "Firmware image header validation passed."
fi

# Backup firmware
echo "Backing up firmware to /mnt/mmcblk0p27/backup ..."
mkdir -p /mnt/mmcblk0p27/backup
cp "/var/tmp/${firmwares_name}" "/mnt/mmcblk0p27/backup/${firmwares_name}"

echo "Starting system upgrade..."
sysupgrade -F "/var/tmp/${firmwares_name}"
