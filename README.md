Script build_live_iso_date_Vx.sh made to create bootable ISO from my home system which runs Niri window manager + Noctalia shell on Void Linux on my Macbook Pro mid 2014 as daily driver.

Image void-linux-for-macbookpro-mid2014-Vx.iso is result of the script ready to be written to USB drive.
Command to write image to usb drive (change X in /dev/sdX to approriate usb drive letter):
sudo dd bs=4M if=/home/jp/snapshots/void-live-perfect.iso of=/dev/sdX conv=fsync status=progress


Note!!! If after live.iso boot WiFi still doesnt work, just run those commands in terminal:  
sudo depmod -a
sudo modprobe wl



Whats working:
            1.  Boots fast and smooth in to TTY1
            2.  Standart login as anon or root to Void linux
            3.  To run Niri+Noctalia just type 'dbus-run-session niri' without quotes
            4.  Services like dbus, seatd, dhcpcd, elogind, NetworkManager, acpid, agetty, bluetoothd, sshd, udevd, wpa_supplicant are up and running
            5.  Custom russian keyboard layout with modified keybindings
            6.  MBP Trackpad
            7.  Installed some additional packages like fuzzle, fuzzypkg, audacious, vlc, firefox, kitty etc...
            8.  Added void-installer with all required dependencies like xmirror, gptfdisk, grub, util-linux
            9.  Embedded worked on host system wl kernel module
            10. Script automatically determines wifi hardware and installs approriate wifi drivers (tested on Macbook pro mid 2014 and iMac 8.1)
            11. Audio 

Not tested:
            1.  Bluetooth
            2.  Mtp file transfer to smartphone

Not working: You tell me...


Build tested on MacBookPro mid 2014 and IMac8.1.
Due to GitHub's 2GB file size limit, the ISO is split.
To join them back on Linux/macOS, download both files and run:

'cat void-linux-for-macbookpro-mid2014-v6.iso.part* > void-linux-for-macbookpro-mid2014-v6.iso'