#### Changelog – void-live-umno-v1.0.3 (Umbriel + Noctalia Edition)

#### Summary

This release builds upon the **Umbriel + Noctalia** Wayland desktop migration and delivers a fully automated live-boot and build experience. Key highlights include dynamic Broadcom Wi-Fi DKMS compilation, an interactive TUI Wi-Fi connection wizard prior to desktop startup, smart .desktop launcher filtering, deduplicated /etc/skel assets, and a unified build script producing a single bootable ISO image under the **2.0 GiB** GitHub release threshold (1.9 GiB). 

#### 🚀 Core Architectural & Desktop Changes

* **Compositor Migration (niri → umbriel):** Replaced niri with the **Umbriel** Wayland compositor paired with **Noctalia Shell** for a unified, native Wayland experience.
* **Native Noctalia Lock Screen & Suspend Handling:** 

  * Migrated screen locking completely to Noctalia's built-in lock screen (noctalia msg session lock bound to Mod+L) and enabled native elogind **Lock Before Suspend** integration.
  * Completely removed swaylock and swayidle to eliminate resume wake-up race conditions and black screen issues.
* **Deterministic PipeWire Audio Startup:** Sequenced pipewire, wireplumber, and pipewire-pulse startup inside Umbriel's autostart ahead of Noctalia to prevent metadata polling loops and keep idle CPU/temperatures low on MacBook Pro hardware.

#### 🌐 Interactive TUI Wi-Fi Wizard & Session Flow (v1.0.3)

* **Pre-Desktop Wi-Fi Connection Menu (wifi-connect.sh):** 

  * Added an interactive dialog + nmcli TUI wizard triggered automatically on TTY1 via ~/.bash_profile immediately after anon auto-login.
  * Scans available wireless networks with signal strength and security indicators, prompts for WPA/WPA2 passwords, and connects before post-install.sh or the Wayland session launches (eliminating offline curl failures during post-install setup).
  * Includes an **Offline / Skip** option and automatic bypass when wired Ethernet connectivity is already active.
* **Streamlined Post-Install & Session Launch (post-install.sh):** 

  * Fixed case statement syntax (esac) and switched shebang to #!/bin/bash.
  * Added direct prompt to launch exec dbus-run-session start-umbriel whether post-install utility installation (superfile, fresh, cliamp, fcron) is executed or skipped.
* **Smart .desktop Shortcut Filtering:** 

  * Updated build-live-iso-umno-v1.0.3.sh to inspect Exec= binaries in /home/jp/.local/share/applications and /usr/local/share/applications, copying only launchers for applications present in the ISO alongside NoDisplay=true overrides (preventing dead menu entries from host-only apps/games).

#### 🛠️ Wi-Fi Driver & Build Pipeline Fixes (v1.0.3)

* **Dynamic Broadcom wl DKMS Compilation:** 

  * Removed brittle manual host copying of wl.ko (which broke whenever the Void repository kernel updated ahead of the host kernel, e.g., 6.18.65_1).
  * Restored dkms, linux-headers, broadcom-wl-dkms, and b43-fwcutter to the ISO package list so the wl kernel module compiles cleanly against the exact target kernel during image generation.
  * Added stderr logging to /etc/rc.local (modprobe wl 2>> /var/log/rc.local.log) for hardware diagnostics.
* **Unified Build Script (build-live-iso-umno-v1.0.3.sh):** 

  * Consolidated overlay preparation, dynamic library collection, nftables/sysctl hardening, and mklive.sh ISO generation into a single self-contained script with ISO_NAME versioning and TrueColor terminal output.
* **XBPS Repository & Key Automation:** 

  * Removed obsolete community_repos.conf from my-overlay/etc/xbps.d/ (eliminating 404 Not Found and stalled sync errors on musl/aarch64 mirrors) and replaced it with 10-universal.conf for UniversalRepository.
  * Automated RSA public key acceptance (yes |) during mklive.sh repository synchronization and stripped unused musl/aarch64 default repository entries from mklive.sh.

#### 💾 ISO Size & SquashFS Optimization (Under 2.0 GiB)

* **No-Split Single ISO Image:** Reduced the final ISO image size from 2.1 GiB down to **1.9 GiB**—fitting comfortably under GitHub's 2 GB file limit even with dkms and linux-headers included.
* **Automated XBPS noextract Rules (/etc/xbps.d/99-noextract.conf):** 

  * Injected directly via build-live-iso-umno-v1.0.3.sh to strip unused locales (keeping English and Russian) and documentation during build and future package installs while preserving kernel headers for DKMS.
* **Tighter SquashFS Compression (-Xbcj x86 -b 1M):** Fixed the -s xz compressor flag and patched mklive.sh to apply xz compression with x86 BCJ executable filtering and a 1M block size.
* **Overlay & /etc/skel Deduplication:** 

  * Removed the redundant 190 MB icon/cursor copy from my-overlay/etc/skel/.local/share/icons (retaining the system-wide copy in /usr/local/share/icons), saving ~190 MB in both the ISO and live session RAM (tmpfs).
  * Purged redundant my-overlay/home files and leftover legacy WM configs (niri, wofi, waybar, hypr, sway).

#### 📦 Package & Service Changes

#### Added / Retained

* **umbriel & noctalia** – Native Wayland compositor and integrated shell.
* **xdg-desktop-portal-umbriel, xdg-desktop-portal-gtk, xdg-desktop-portal-termfilechooser** – Lightweight Wayland portal stack.
* **dkms, linux-headers, b43-fwcutter, & broadcom-wl-dkms** – Full out-of-the-box Wi-Fi support across MacBook Pro (Mid 2014), iMac 8.1, and standard PC hardware.
* **dialog & NetworkManager** – Powers the pre-session TUI Wi-Fi connection wizard.

#### Removed / Disabled

* **niri** – Replaced by umbriel.
* **swaylock & swayidle** – Purged completely; superseded by Noctalia's native lock screen and elogind suspend integration.
* **xdg-desktop-portal-gnome** – Dropped to avoid pulling in heavy GNOME/GTK4 dependencies.
* **dhcpcd, wireless_tools, & standalone wpa_supplicant service** – Disabled/removed from /etc/runit/runsvdir/default so NetworkManager manages wpa_supplicant cleanly via D-Bus without interface locking.

#### 💾 Flashing Instructions

Since the ISO is under 2.0 GiB, no cat file joining is required. Write directly to your USB drive (replace /dev/sdX with your target device from lsblk): 

bash

lsblk # identify target USB drive letter, e.g., /dev/sdb
sudo dd bs=4M if=/home/jp/snapshots/void-live-umno-v1.0.3.iso of=/dev/sdX conv=fsync status=progress
