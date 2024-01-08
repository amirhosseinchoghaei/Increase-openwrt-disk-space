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
sleep 2
## Install Some Package for USB Driver ###

opkg install kmod-usb-storage
sleep 2

opkg install kmod-usb-storage-uas
sleep 2

opkg install usbutils
sleep 2

opkg install block-mount kmod-fs-ext4 e2fsprogs parted
sleep 2

parted -s /dev/sda -- mklabel gpt mkpart extroot 2048s -2048s
sleep 2

### Configuring rootfs_data ###

DEVICE="$(sed -n -e "/\s\/overlay\s.*$/s///p" /etc/mtab)"

uci -q delete fstab.rwm
uci set fstab.rwm="mount"
uci set fstab.rwm.device="${DEVICE}"
uci set fstab.rwm.target="/rwm"
uci commit fstab

sleep 2

### Configuring extroot ###

DEVICE="/dev/sda1"

mkfs.ext4 -L extroot ${DEVICE}


sleep 5

eval $(block info ${DEVICE} | grep -o -e "UUID=\S*")

uci -q delete fstab.overlay
uci set fstab.overlay="mount"
uci set fstab.overlay.uuid="${UUID}"
uci set fstab.overlay.target="/overlay"
uci commit fstab

sleep 2

### Transferring data ###

mount ${DEVICE} /mnt
sleep 2

tar -C /overlay -cvf - . | tar -C /mnt -xf -

echo -e "${GREEN}Done ! Your Router Will Be reboot After 5 Seconds ... ${NC}"

echo "Powered By AmirHossein Choghaei"

sleep 5

reboot

rm exroot.sh 2> /dev/null
