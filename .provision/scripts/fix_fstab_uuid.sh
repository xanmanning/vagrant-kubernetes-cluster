#!/usr/bin/env bash                               
set -euo pipefail               
                                                           
find_block_devices_in_fstab() {
    local BLOCK_DEVICES
    BLOCK_DEVICES=$(grep "/dev/sd" /etc/fstab | awk '{ print $1 }' | uniq || true)
    echo "${BLOCK_DEVICES}"
}

get_block_device_uuid() {
    local UUID
    local BLOCK_DEVICE

    BLOCK_DEVICE="${1:-true}"

    if [[ "${BLOCK_DEVICE}" == "" ]] ; then
        echo "Please supply a valid block device"
        exit 1
    fi

    UUID=$(blkid "${BLOCK_DEVICE}" | sed 's/.*\sUUID\="\([a-z0-9\-]\+\)".*/\1/')
    echo "${UUID}"
}

fix_fstab() {
    local DEVICE_LIST
    local DEVICE_LIST_LEN
    mapfile -t DEVICE_LIST <<< "${1:-true}"
    DEVICE_LIST_LEN="${#DEVICE_LIST[@]}"

    if [[ "${DEVICE_LIST[0]}" == "" ]] ; then
        echo "Please supply a list of block devices!"
        exit 1
    fi

    if [[ ${DEVICE_LIST_LEN} -lt 1 ]] ; then
        echo "Please supply a list of block devices!"
        exit 1
    fi

    if [[ "${DEVICE_LIST[0]}" != "true" ]] ; then
        echo "Fixing /etc/fstab ..."
        cp -av /etc/fstab "/etc/fstab.backup-$(date +%s)"
        for device in ${DEVICE_LIST[*]} ; do
            UUID=$(get_block_device_uuid "${device}")
            sed -i "s#^${device}#UUID=${UUID}#" /etc/fstab
            echo "Replaced ${device} with UUID: ${UUID}"
        done
    else
        echo "/etc/fstab looks to be OK"
    fi
}

main() {
    BLOCK_DEVICES="$(find_block_devices_in_fstab)"
    fix_fstab "${BLOCK_DEVICES}"
}

main
