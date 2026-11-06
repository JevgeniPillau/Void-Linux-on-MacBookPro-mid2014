
Void Linux Live ISO for MacBook Pro (Mid 2014)

A custom, bootable Void Linux Live ISO tailored for the MacBook Pro Mid 2014 (and similar Apple hardware like the iMac 8.1) as a daily driver. This build comes pre-configured with the Niri window manager and the Noctalia shell for a modern, smooth, and lightweight Wayland experience.

🛠️ How it Works & How to Build


The Script

The build_live_iso_date_Vx.sh script automates the creation of this custom bootable ISO directly from a running host system.

Build Instructions

1. Clone or copy the script into your local void-mklive/ directory.
2. Run the script inside that directory.
(Note: void-mklive is the official Void Linux toolchain for building ISO images. For detailed configuration instructions, please refer to the official Void Linux Handbook).
The output will be a flash-ready image named void-linux-for-macbookpro-mid2014-Vx.iso.

💾 How to Flash the ISO

Due to GitHub's 2GB file size limit, the release ISO is split into multiple parts. To join the files back into a single flashable image on Linux or macOS, download all parts to the same folder and run:\
`cat void-linux-for-macbookpro-mid2014-v6.iso.part* > void-linux-for-macbookpro-mid2014-v6.iso`

Once you have the complete .iso file, use the following command to write it to your USB drive (replace X in /dev/sdX with your actual USB device letter):\
`sudo dd bs=4M if=void-linux-for-macbookpro-mid2014-v6.iso of=/dev/sdX conv=fsync status=progress`

🚀 Booting & Getting Started

1. The ISO boots quickly and smoothly straight into TTY1.
2. Log in using the standard Void Linux credentials (e.g., anon or root).
3. To launch the graphical interface (Niri + Noctalia), type the following command and hit Enter:\
`dbus-run-session niri`


[!IMPORTANT]
⚠️ Wi-Fi Troubleshooting:
While the script embeds the working wl kernel module from the host system, if Wi-Fi does not work immediately after booting the live environment, open a terminal and run:\
```
sudo depmod -a
sudo modprobe wl

```
\
🟢 What's Working

• Fast Boot: Boot process is highly optimized, dropping you straight into TTY1.\
• Core Services: Critical daemons are pre-configured, up, and running:\
 dbus, seatd, elogind, udevd, acpid, dhcpcd, NetworkManager, wpa_supplicant, bluetoothd, sshd, agetty...\
• Hardware Support: Perfect out-of-the-box support for the MacBook Pro Trackpad and Audio.\
• Automated Wi-Fi Drivers: The script automatically detects the Wi-Fi hardware and installs the correct drivers (successfully tested on both a MacBook Pro Mid 2014 and an iMac 8.1).\
• Kernel Module Integration: Embedded host-tested wl Broadcom kernel module.\
• Custom Russian Layout: Features a tailored Russian keyboard layout with modified hotkeys.\
• Pre-installed Software: Includes popular essential packages like kitty, firefox, vlc, audacious, fuzzle, and fuzzypkg.\
• Void Installer: Equipped with the native void-installer alongside all necessary dependencies (xmirror, gptfdisk, grub, util-linux) for full disk installation.\

🟡 Not Tested / Unknown

• Bluetooth functionality
• MTP file transfer to smartphones

🔴 Not Working

• You tell me! Please open an issue if you encounter any bugs.

💻 Hardware Compatibility

This build has been successfully compiled and tested on:
• MacBookPro (Mid 2014)
• iMac 8.1
