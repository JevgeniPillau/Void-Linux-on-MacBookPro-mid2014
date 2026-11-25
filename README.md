#### Void Live Umno (Umbriel + Noctalia Edition)

Custom, lightweight, security-hardened **Void Linux** live & installable ISO image tailored for **Apple MacBook Pro (Mid 2014)**, **iMac**, and standard **x86_64** hardware. Built around the native **Umbriel** Wayland compositor and **Noctalia Shell**, the final compressed image stays under **2.0 GiB (1.9 GiB)** for single-file distribution. 

#### ✨ Key Features

* **Native Wayland Desktop:** Powered by **Umbriel** + **Noctalia Shell** with deterministic PipeWire audio startup, native screen locking (Mod+L), and elogind suspend integration.
* **Out-of-the-Box Apple MacBook Hardware Support:** 

  * Automatic DMI hardware detection in /etc/rc.local loads the proprietary Broadcom wl driver (compiled dynamically via DKMS against the exact ISO kernel) while blacklisting conflicting open-source modules (b43, bcma, ssb, brcmsmac).
  * Includes mbpfan thermal daemon and udev keyboard backlight permissions out of the box.
* **Pre-Session TUI Wi-Fi Wizard:** 

  * Automatically scans wireless networks and prompts for connection via dialog + nmcli on TTY1 right after auto-login (anon), ensuring internet access is ready before post-install.sh or the desktop starts.
* **Network Hardening by Default:** 

  * Configured with strict nftables stateful firewall rules (default drop policy) and hardened sysctl kernel network parameters.
* **Custom CLI & TUI Tooling:** 

  * Includes kitty, fuzzel, btop, fuzzypkg, xmirror, hblock, fcron, and an interactive post-install setup tool for superfile, fresh, and cliamp, plus a custom void-installer.

#### 📂 Repository Structure

ASCII

void-mklive/
├── build-live-iso-umno-v1.0.3.sh   # Unified build script (overlay prep + ISO generation)
├── mklive.sh                       # Patched Void mklive script (-comp xz -Xbcj x86 -b 1M)
├── installer.sh                    # Custom system installer (injected as /usr/bin/void-installer)
├── my-overlay/                     # Persistent rootfs overlay template
│   ├── etc/
│   │   ├── skel/
│   │   │   ├── .bash_profile       # TTY1 boot chain (wifi-connect -> post-install -> Umbriel)
│   │   │   ├── .bashrc             # Gruvbox prompt, cursor theme, and editor defaults
│   │   │   └── .config/scripts/
│   │   │       ├── wifi-connect.sh # Interactive TUI Wi-Fi scanner & connector
│   │   │       └── post-install.sh # Optional TUI utility installer & Umbriel launcher
│   │   └── xbps.d/
│   │       └── 10-universal.conf   # UniversalRepository configuration
│   └── usr/local/share/icons/      # System-wide Gruvbox icon & cursor themes
└── included_files/                 # Auto-generated temporary staging directory (ignored/rebuilt)


#### 🚀 Boot & First-Login Workflow

1. **Auto-Login (anon):** Boots directly into TTY1 with automatic hardware detection (rc.local) and NetworkManager initialization.
2. **Wi-Fi Connection Wizard (wifi-connect.sh):** Scans nearby Wi-Fi networks, displays signal strength/security, and connects to your chosen network (or lets you skip to offline mode).
3. **Post-Install Setup (post-install.sh):** Optionally installs superfile, fresh, and cliamp and initializes fcron automation tasks.
4. **Desktop Launch:** Starts the **Umbriel + Noctalia** Wayland session (exec dbus-run-session start-umbriel).

#### 🛠️ Building the ISO

#### Prerequisites

Run on an **x86_64 Void Linux** host with void-mklive dependencies installed (bash, xz, squashfs-tools, xorriso, grub-x86_64-efi, syslinux, curl). 

#### Build Command

```bash

chmod +x build-live-iso-umno-v1.0.3.sh
./build-live-iso-umno-v1.0.3.sh
```
The script automatically: 

1. Rebuilds ./included_files from my-overlay/ and injects XBPS noextract size-reduction rules.
2. Copies umbriel, noctalia, their shared libraries, fonts, and filtered .desktop shortcuts.
3. Enables runit services (seatd, dbus, elogind, NetworkManager, mbpfan, bluetoothd, alsa, polkitd, nftables).
4. Injects /etc/rc.local, Broadcom module blacklists, nftables firewall rules, sysctl hardening, and void-installer.
5. Builds the compressed ISO image at /home/jp/snapshots/void-live-umno-v1.0.3.iso.

#### 💾 Writing to a USB Drive

1. Identify your USB device letter (e.g., /dev/sdb): 

```bash

lsblk
```

2. Flash the ISO directly using dd: 

```bash

sudo dd bs=4M if=/home/jp/snapshots/void-live-umno-v1.0.3.iso of=/dev/sdX conv=fsync status=progress
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
