# Void Linux Live ISO for MacBook Pro (Mid 2014) — Umbriel + Noctalia Edition (`void-live-umno-v1`)

A custom, lightweight, bootable Void Linux Live ISO (`1.91 GiB`) tailored for the **MacBook Pro Mid 2014** (and similar Apple hardware like the **iMac 8,1**) as a daily driver. This build comes pre-configured with the **Umbriel** Wayland compositor and the **Noctalia** desktop shell for a fast, cohesive, and resource-efficient Wayland experience.

---

## 🛠️ How it Works & How to Build

### The Build Script
The `build-live-iso-umno-v1.sh` script automates the creation of this custom bootable ISO directly from your running host system. It automatically injects XBPS `noextract` size optimizations (`/etc/xbps.d/99-noextract.conf`), embeds the host-tested Broadcom `wl` kernel module, and compresses the rootfs with `xz` (`x86` BCJ filter) to keep the final image under **2.0 GiB**.

### Build Instructions
1. Clone or copy `build-live-iso-umno-v1.sh` into your local `void-mklive/` directory.
2. Run the script inside that directory:
   ```bash
   sudo ./build-live-iso-umno-v1.sh
   ```
   *(Note: `void-mklive` is the official Void Linux toolchain for building ISO images. Refer to the [Void Linux Handbook](https://docs.voidlinux.org) for additional details).*
3. The output will be a single, flash-ready image named **`void-live-umno-v1.iso`** (`1.91 GiB` / `1,955 MiB`).

---

## 💾 How to Flash the ISO

Because the optimized ISO is **under 2.0 GiB**, no file splitting or `cat` reassembly is needed. Write the image directly to your USB drive (replace `/dev/sdX` with your actual USB device from `lsblk`):

```bash
sudo dd bs=4M if=/home/jp/snapshots/void-live-umno-v1.iso of=/dev/sdX conv=fsync status=progress
```

---

## 🚀 Booting & Getting Started

1. **Fast TTY1 Boot:** The ISO boots quickly and smoothly straight into `TTY1` with an interactive greeting menu.
2. **Login:** Log in using standard Void Linux live credentials (`anon` or `root`).
3. **Launch Graphical Session (Umbriel + Noctalia):**
   If you choose not to auto-launch from the post-boot prompt, start the desktop manually with:
   ```bash
   exec dbus-run-session start-umbriel
   ```
4. **Key Shortcuts:**
   * **`Mod+L`**: Lock screen via Noctalia (`noctalia msg session lock`).
   * **`Mod+Alt+U`**: Open interactive hotkey cheatsheet.

> **[!IMPORTANT] Wi-Fi Troubleshooting**
> While the build script embeds the working `wl` kernel module from the host system and includes `b43-fwcutter`, if Wi-Fi does not initialize immediately after booting the live environment, open a terminal and run:
> ```bash
> sudo depmod -a
> sudo modprobe wl
> ```

> **[!TIP] Enabling Full Bluetooth & Smartphone MTP Support**
> Both Bluetooth and MTP transfers are tested and working. To install the required user-space tools and GUI/CLI utilities after installation, run:
> ```bash
> sudo xbps-install -S bluez blueman gvfs-mtp libmtp simple-mtpfs
> ```

---

## 🟢 What's Working

* **Fast Boot & Interactive TTY Menu:** Boots straight into `TTY1` with an automated post-install helper (`/usr/local/bin/post-install`).
* **Streamlined Core Services:** Pre-configured and active daemons without conflicting network managers:
  * `dbus`, `seatd`, `elogind`, `udevd`, `acpid`
  * `NetworkManager`, `wpa_supplicant` (`dhcpcd` removed to avoid conflicts)
  * `bluetoothd`, `sshd`, `agetty`
* **Native Power & Lock Management:** Integrated `elogind` suspend handling and screen locking directly inside **Noctalia** (no `swayidle` or `swaylock` needed).
* **Apple Hardware Support:** Out-of-the-box support for the MacBook Pro Trackpad, PipeWire audio stack, and `mbpfan` thermal control.
* **Bluetooth & Smartphone MTP Transfers:** Fully functional (tested and working after installing the required user-space packages listed above).
* **Automated Wi-Fi Drivers:** Automatically detects Wi-Fi hardware and embeds the Broadcom `wl` module + `b43-fwcutter` (tested on MacBook Pro Mid 2014 and iMac 8,1).
* **Custom Russian Layout:** Tailored Russian keyboard layout with custom hotkey bindings.
* **Pre-installed Software:** Includes `kitty`, `firefox`, `mpv`, `hblock`, `btop`, `curl`, and custom `cue-splitter`.
* **Post-install Software:** Includes `fresh`, `superfile`, `cliamp`.
* **Void Installer:** Equipped with native `void-installer` and all required dependencies (`xmirror`, `gptfdisk`, `grub`, `util-linux`) for full disk installation.

---

## 🔴 Not Working

* You tell me! Please open an issue if you encounter any bugs.

---

## 💻 Hardware Compatibility

This build has been compiled and tested on:
* **MacBook Pro (Mid 2014)**
* **iMac 8,1**

---

## 💾 How to Flash the ISO

Because the optimized ISO is **under 2.0 GiB**, no file splitting or `cat` reassembly is needed. Write the image directly to your USB drive (replace `/dev/sdX` with your actual USB device from `lsblk`):

```bash
sudo dd bs=4M if=/home/jp/snapshots/void-live-umno-v1.iso of=/dev/sdX conv=fsync status=progress
```

---

## 🚀 Booting & Getting Started

1. **Fast TTY1 Boot:** The ISO boots quickly and smoothly straight into `TTY1` with an interactive greeting menu.
2. **Login:** Log in using standard Void Linux live credentials (`anon` or `root`).
3. **Launch Graphical Session (Umbriel + Noctalia):**
   If you choose not to auto-launch from the post-boot prompt, start the desktop manually with:
   ```bash
   exec dbus-run-session start-umbriel
   ```
4. **Key Shortcuts:**
   * **`Mod+L`**: Lock screen via Noctalia (`noctalia msg session lock`).
   * **`Mod+Alt+U`**: Open interactive hotkey cheatsheet.

> **[!IMPORTANT] Wi-Fi Troubleshooting**
> While the build script embeds the working `wl` kernel module from the host system and includes `b43-fwcutter`, if Wi-Fi does not initialize immediately after booting the live environment, open a terminal and run:
> ```bash
> sudo depmod -a
> sudo modprobe wl
> ```

> **[!TIP] Enabling Full Bluetooth & Smartphone MTP Support**
> Both Bluetooth and MTP transfers are tested and working. To install the required user-space tools and GUI/CLI utilities after installation, run:
> ```bash
> sudo xbps-install -S bluez blueman gvfs-mtp libmtp simple-mtpfs
> ```

---

## 🟢 What's Working

* **Fast Boot & Interactive TTY Menu:** Boots straight into `TTY1` with an automated post-install helper (`/usr/local/bin/post-install`).
* **Streamlined Core Services:** Pre-configured and active daemons without conflicting network managers:
  * `dbus`, `seatd`, `elogind`, `udevd`, `acpid`
  * `NetworkManager`, `wpa_supplicant` (`dhcpcd` removed to avoid conflicts)
  * `bluetoothd`, `sshd`, `agetty`
* **Native Power & Lock Management:** Integrated `elogind` suspend handling and screen locking directly inside **Noctalia** (no `swayidle` or `swaylock` needed).
* **Apple Hardware Support:** Out-of-the-box support for the MacBook Pro Trackpad, PipeWire audio stack, and `mbpfan` thermal control.
* **Bluetooth & Smartphone MTP Transfers:** Fully functional (tested and working after installing the required user-space packages listed above).
* **Automated Wi-Fi Drivers:** Automatically detects Wi-Fi hardware and embeds the Broadcom `wl` module + `b43-fwcutter` (tested on MacBook Pro Mid 2014 and iMac 8,1).
* **Custom Russian Layout:** Tailored Russian keyboard layout with custom hotkey bindings.
* **Pre-installed Software:** Includes `kitty`, `firefox`, `mpv`, `hblock`, `btop`, `curl`, and custom `cue-splitter`.
* **Post-install Software:** Includes `fresh`, `superfile`, `cliamp`.
* **Void Installer:** Equipped with native `void-installer` and all required dependencies (`xmirror`, `gptfdisk`, `grub`, `util-linux`) for full disk installation.

---

## 🔴 Not Working

* Please open an issue if you encounter any bugs.

---

## 💻 Hardware Compatibility

This build has been compiled and tested on:
* **MacBook Pro (Mid 2014)**
* **iMac 8,1**
