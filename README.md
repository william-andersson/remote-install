# remote-install
### Install linux remotely using vnc

1. Put the files in a directory on the server together with an iso.
2. Create a partition of at least 1GB to house an iso during reboot.
3. Give the partition the label "isoboot".
4. When it's time to reinstall, just execute the reinstall.sh script.
5. The script will ask you to choose a distro if not supplied as an argument.
6. When the script is finished, it will reboot the machine into the installer and you can connect to it using vnc.

**You can at any time before the reboot, press ctrl-c to abort the process** 

## Warning!
The script tries to boot the chosen iso just one, ***BUT! if grub is installed onto mdraid or lvm***,<br />
the machine will continue to boot the iso if the booted installation is aborted!<br />
This does not apply if you abort before the reboot.

## How it works
./reinstall.sh<br />
./reinstall.sh suse<br /><br />
When executed, the script will look for a partition labeled "isoboot", mount it and
start copying the requested iso.<br />Afterwards, it will copy the corresponding 40_custom
and make some necessary changes to it.<br />
Finally it updates grub to boot the iso using a loopback device.<br />
Before rebooting it will print ip-address and vnc password.

## Disclaimer!
**The script only works with Fedora-server, RockyLinux and OpenSuse!** (and probably RHEL/Centos/AlmaLinux...)

Tested iso's
  - Fedora-Server-netinst-x86_64-38-1.6.iso
  - Rocky-9.1-x86_64-boot.iso
  - openSUSE-Leap-15.4-NET-x86_64-Build243.2-Media.iso

## Ubuntu?
Although Ubuntu server is capable of running the installer via ssh,
I was not able to supply a static password to the installer... **Yet!**
