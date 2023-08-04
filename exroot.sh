#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color



echo "Running as root..."
sleep 2
clear


### Update Packages ###

opkg update


## Install Some Package for USB Driver ###

opkg install kmod-usb-storage

opkg install kmod-usb-storage-uas

opkg install usbutils

opkg install block-mount kmod-fs-ext4 e2fsprogs parted

parted -s /dev/sda -- mklabel gpt mkpart extroot 2048s -2048s

### Configuring rootfs_data ###

DEVICE="$(sed -n -e "/\s\/overlay\s.*$/s///p" /etc/mtab)"

uci -q delete fstab.rwm
uci set fstab.rwm="mount"
uci set fstab.rwm.device="${DEVICE}"
uci set fstab.rwm.target="/rwm"
uci commit fstab

### Configuring extroot ###

DEVICE="/dev/sda1"

mkfs.ext4 -L extroot ${DEVICE}
y

eval $(block info ${DEVICE} | grep -o -e "UUID=\S*")

uci -q delete fstab.overlay
uci set fstab.overlay="mount"
uci set fstab.overlay.uuid="${UUID}"
uci set fstab.overlay.target="/overlay"
uci commit fstab


### Transferring data ###

mount ${DEVICE} /mnt

tar -C /overlay -cvf - . | tar -C /mnt -xf -

echo "Done Your Router Will be Reboot after 5 Second ...."

sleep 5

reboot



