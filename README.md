# remote-install
Install linux remotely using vnc

1. Put the files in a folder on the server.
2. Create a partition of at least 1GB to house an iso during reboot.
3. Give the partition the label "isoboot".
4. When it's time to reinstall, just execute the reinstall.sh script.
5. The server will soon reboot inte the installer and you can connect to it using vnc.

# Disclaimer!
The script only works with Fedora, Rocky and OpenSuse linux!

Tested iso's
  - Fedora-Server-netinst-x86_64-38-1.6.iso
  - Rocky-9.1-x86_64-boot.iso
  - openSUSE-Leap-15.4-NET-x86_64-Build243.2-Media.iso
