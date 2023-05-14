#!/bin/bash
#Copyright William Andersson 2023
VERSION=1.0
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
clear
PART_LABEL="isoboot" # A partition with this label must exist.
DISK_PATH=$(readlink -f /dev/disk/by-label/$PART_LABEL)
PARTITION=$(readlink -f /dev/disk/by-label/$PART_LABEL | sed 's:.*/::')
fedora=$(ls | grep *Fedora*.iso)
rocky=$(ls | grep *Rocky*.iso)
suse=$(ls | grep *SUSE*.iso)

function abort() {
	echo -e "\n*** Aborted!"
	if grub2-editenv list | grep "next_entry" > /dev/null 2>&1; then
		echo "*** Re-setting boot entry."
		grub2-editenv /boot/grub2/grubenv unset next_entry
		if ! [ -z $dist ]; then
			echo "*** [$dist] will NOT be booted!"
		fi
	fi
	if mount | grep /mnt  > /dev/null 2>&1; then
		echo "*** Unmounting /mnt"
		umount /mnt
	fi
	echo "*** Done."
	exit 2
}
trap abort SIGINT

if [ ! -L "/dev/disk/by-label/$PART_LABEL" ]; then
	echo "No partition with label $PART_LABEL found!"
	echo "Create a 1GB+ partition with the label $PART_LABEL and ext4 file system."
	exit 1
else
	echo "***************  WARNING!  ***************"
	echo "*   Preparing server for installation!   *"
	echo "*   Make sure backups are in place!      *"
	echo "******************************************"
	echo ""
	if [ $# -eq 0 ]; then
		read -p "Select distribution [fedora|rocky|suse]: " dist
	else
		dist=$1
	fi
	if ! [[ $dist =~ ^(fedora|rocky|suse)$ ]]; then
		echo "Invalid distribution!"
		exit 1
	fi
	echo "The server will reboot and start $dist installation via VNC!"
	read -p "Continue? [y/n]: " q
	if [ $q != "y" ]; then
		abort
	else
		echo "Mounting partition $PART_LABEL ($DISK_PATH) to /mnt/ ..."
		mount -L $PART_LABEL /mnt/

		if [ $dist == "fedora" ]; then
			echo "Copying $fedora to /mnt/linux.iso ..."
			cp $fedora /mnt/linux.iso
			echo "Copying 40_fedora to /etc/grub.d/40_custom ..."
			cp 40_fedora /etc/grub.d/40_custom
		elif [ $dist == "rocky" ]; then
			echo "Copying $rocky to /mnt/linux.iso ..."
			cp $rocky /mnt/linux.iso
			echo "Copying 40_rocky to /etc/grub.d/40_custom ..."
			cp 40_rocky /etc/grub.d/40_custom
		elif [ $dist == "suse" ]; then
			echo "Copying $suse to /mnt/linux.iso ..."
			cp $suse /mnt/linux.iso
			echo "Copying 40_suse to /etc/grub.d/40_custom ..."
			cp 40_suse /etc/grub.d/40_custom
		fi

		echo "Processing 40_custom ..."
		sed -i 's/PARTITION/'$PARTITION'/' /etc/grub.d/40_custom
		sed -i 's/DISKLABEL/'$PART_LABEL'/' /etc/grub.d/40_custom
		sed -i 's/BOOTID/'$PART_LABEL'/' /etc/grub.d/40_custom

		echo "Updating grub ..."
		grub2-mkconfig -o /boot/grub2/grub.cfg

		echo ""
		echo "Setting boot entry to [$dist] ..."
		grub2-reboot "$PART_LABEL-$dist"

		echo "Unmounting /mnt ..."
		umount /mnt

		echo ""
		echo "1. Wait for the server to reboot."
		echo "2. Connect to ip $(hostname -I):1 using VNC"
		echo "3. Enter password: xinstall"
		echo ""

		read -p "Press enter to reboot"
		echo "Reboot initialized!"
		shutdown -r now
	fi
fi
