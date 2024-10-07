#!/bin/bash

# from wax/payloads/sh1mmer_bw/root/noarch/usr/sbin/sh1mmer_gui.sh
# legacy doesn't have this, so we can't source it directly
function setup() {
	stty -echo # turn off showing of input
	printf "\033[?25l" # turn off cursor so that it doesn't make holes in the image
	printf "\033[2J\033[H" # clear screen
	sleep 0.1
}

function cleanup() {
	printf "\033[2J\033[H" # clear screen
	printf "\033[?25h" # turn on cursor
	stty echo
}

cleanup

get_largest_nvme_namespace() {
    # this function doesn't exist if the version is old enough, so we redefine it
    local largest size tmp_size dev
    size=0
    dev=$(basename "$1")

    for nvme in /sys/block/"${dev%n*}"*; do
        tmp_size=$(cat "${nvme}"/size)
        if [ "${tmp_size}" -gt "${size}" ]; then
            largest="${nvme##*/}"
            size="${tmp_size}"
        fi
    done
    echo "${largest}"
}

get_booted_kernnum() {
    if (($(cgpt show -n "$dst" -i 2 -P) > $(cgpt show -n "$dst" -i 4 -P))); then
        echo -n 2
    else
        echo -n 4
    fi
}

opposite_num() {
    if [ "$1" == "2" ]; then
        echo -n 4
    elif [ "$1" == "4" ]; then
        echo -n 2
    elif [ "$1" == "3" ]; then
        echo -n 5
    elif [ "$1" == "5" ]; then
        echo -n 3
    else
        return 1
    fi
}

clear

recover_from_image() {
    echo "Choose a recovery image:"
    basename -a /recovery_images/*.bin
    read -p " > " image
    if [ -f "/recovery_images/$image" ]; then
        echo "Finding target partitions..."
        local dst=/dev/$(get_largest_nvme_namespace)
        if [[ $dst == /dev/sd* ]]; then
            echo "WARNING: get_largest_nvme_namespace returned $dst - this doesn't seem correct!"
            echo "Press enter to view output from fdisk - find the correct drive and enter it below"
            read -r
            fdisk -l | more
            echo "Enter the target drive to use:"
            read dst
        fi
        local tgt_kern=$(opposite_num $(get_booted_kernnum))
        local tgt_root=$(( $tgt_kern + 1 ))
        local tgt_kern2=$(get_booted_kernnum)
        local tgt_root2=$(( $tgt_kern2 + 1 ))
        local kerndev=${dst}p${tgt_kern}
        local rootdev=${dst}p${tgt_root}
        local kerndev2=${dst}p${tgt_kern2}
        local rootdev2=${dst}p${tgt_root2}
        echo "Targeting $kerndev, $rootdev, $kerndev2 and $rootdev2"
        local loop=$(losetup -f | tr -d '\r')
        losetup -P "$loop" "/recovery_images/$image"
        echo "Press enter if nothing broke, otherwise press Ctrl+C"
        read -r
        printf "Nuking partitions in 3 (this is your last chance to cancel)..."
        sleep 1
        printf "2..."
        sleep 1
        echo "1..."
        sleep 1
        echo "Bomb has been planted! Overwriting ChromeOS..."
        echo "Installing kernel patch to ${kerndev}..."
        dd if="${loop}p4" of="$kerndev" status=progress
        echo "Installing root patch to ${rootdev}..."
        dd if="${loop}p3" of="$rootdev" status=progress
        echo "Installing kernel patch to ${kerndev2}..."
        dd if="${loop}p4" of="$kerndev2" status=progress
        echo "Installing root patch to ${rootdev2}..."
        dd if="${loop}p3" of="$rootdev2" status=progress
        echo "Setting kernel priority..."
        cgpt add "$dst" -i 4 -P 0
        cgpt add "$dst" -i 2 -P 0
        cgpt add "$dst" -i "$tgt_kern" -P 1
        vpd -i RW_VPD -s check_enrollment=0
        echo "Done!"
        echo ""
        read "Rebooting in 3 seconds"
        sleep 3
        reboot -f
        sleep infinity
    else
        echo "File not found!"
    fi
}

recover_from_image

setup
