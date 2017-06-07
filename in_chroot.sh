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
	sshguard ca-certificates
apt-get clean

sed -i.bak '/.*China_Internet.*/d' /etc/ca-certificates.conf 
sed -i.bak '/.*CNNIC.*/d' /etc/ca-certificates.conf 
sed -i.bak '/.*WoSign.*/d' /etc/ca-certificates.conf 

update-ca-certificates

rm -f snoopy-install.sh &&
wget -O snoopy-install.sh https://github.com/a2o/snoopy/raw/install/doc/install/bin/snoopy-install.sh &&
chmod 755 snoopy-install.sh &&
sudo ./snoopy-install.sh stable

echo "$CHROOT_PWD" | passwd &> /dev/null

echo "exit chroot"
