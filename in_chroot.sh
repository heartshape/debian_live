#!/bin/bash
echo "in chroot"

LINUX_IMAGE=$1
CHROOT_PWD=$2

echo "debian-live" > /etc/hostname
apt update && apt upgrade -y
apt install --no-install-recommends --yes --force-yes \
	$LINUX_IMAGE live-boot build-essential libtool autoconf \
	network-manager net-tools wireless-tools wpagui \
	tcpdump wget openssh-server \
	blackbox xserver-xorg-core xserver-xorg xinit xterm \
	pciutils usbutils gparted ntfs-3g hfsprogs rsync dosfstools \
	syslinux partclone nano pv \
	sshguard
apt-get clean

echo "$CHROOT_PWD" | passwd &> /dev/null

echo "exit chroot"
