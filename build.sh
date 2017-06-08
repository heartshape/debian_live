#!/bin/bash
LIVE_BOOT=~/live_boot
IMAGE_VERSION=3.16.0-4-amd64
CHROOT_PWD="password"

echo "LIVE_BOOT(default:~/live_boot):"
read $INPUT
if [ ! "$INPUT" == "" ] 
then
	LIVE_BOOT=$INPUT
fi

if [ -e "$LIVE_BOOT" ]
then
	echo "Delete exited $LIVE_BOOT?(y/n)"
	read $INPUT
	if [ "$INPUT" == "" ] || [ "$INPUT" == "y" ] ;
	then sudo rm -rf $LIVE_BOOT
	fi
fi

if [ ! -e "$LIVE_BOOT" ]
then mkdir -p $LIVE_BOOT/image/{live,isolinux}
fi

sudo apt install -y \
	debootstrap syslinux isolinux squashfs-tools \
	genisoimage memtest86+ rsync

sudo debootstrap --arch=amd64 --variant=minbase \
	jessie $LIVE_BOOT/chroot http://ftp.us.debian.org/debian/

sudo cp ./in_chroot.sh $LIVE_BOOT/chroot
sudo chroot $LIVE_BOOT/chroot ./in_chroot.sh linux-image-$IMAGE_VERSION $CHROOT_PWD
sudo rm -f $LIVE_BOOT/chroot/in_chroot.sh

pushd .
(cd $LIVE_BOOT && \
	sudo mksquashfs chroot image/live/filesystem.squashfs -e boot
)

(cd $LIVE_BOOT && \
	cp chroot/boot/vmlinuz-$IMAGE_VERSION image/live/vmlinuz1 && \
	cp chroot/boot/initrd.img-$IMAGE_VERSION image/live/initrd1
)

(cd $LIVE_BOOT/image/ && \
    cp /usr/lib/ISOLINUX/isolinux.bin isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/menu.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/hdt.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/ldlinux.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/libutil.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/libmenu.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/libcom32.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/libgpl.c32 isolinux/ && \
    cp /boot/memtest86+.bin live/memtest
)
popd

sudo cp ./pci.ids $LIVE_BOOT/image/isolinux/
sudo cp ./isolinux.cfg $LIVE_BOOT/image/isolinux/

genisoimage \
    -rational-rock \
    -volid "Debian Live" \
    -cache-inodes \
    -joliet \
    -hfs \
    -full-iso9660-filenames \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -output $LIVE_BOOT/debian-live.iso \
    $LIVE_BOOT/image


