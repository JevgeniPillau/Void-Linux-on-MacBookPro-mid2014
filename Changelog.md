# Changelog – `void-live-umno-v1` (Umbriel + Noctalia Edition)

## Summary
This release marks a major architectural shift from the `niri` compositor to the native **Umbriel + Noctalia** Wayland desktop ecosystem. The primary goals of this build are to shrink the bootable ISO image below the **2.0 GiB** GitHub release threshold (`1.91 GiB`) so splitting is no longer required, eliminate redundant background daemons, and streamline power management, audio, and screen locking natively within Noctalia.

---

## 🚀 Core Architectural & Desktop Changes

*   **Compositor Migration (`niri` → `umbriel`):** Replaced `niri` with the **Umbriel** Wayland compositor paired with **Noctalia Shell** for a unified, native Wayland experience.
*   **Native Noctalia Lock Screen & Suspend Handling:**
    *   Migrated screen locking completely to Noctalia's built-in lock screen (`noctalia msg session lock` bound to `Mod+L`) and enabled native `elogind` **Lock Before Suspend** integration.
    *   Completely removed `swaylock` and `swayidle` to eliminate resume wake-up race conditions and black screen issues.
*   **Deterministic PipeWire Audio Startup:** Sequenced `pipewire`, `wireplumber`, and `pipewire-pulse` startup inside Umbriel's `autostart` ahead of Noctalia to prevent metadata polling loops and keep idle CPU/temperatures low on MacBook Pro hardware.

---

## 💾 ISO Size & SquashFS Optimization (Under 2.0 GiB)

*   **No-Split Single ISO Image:** Reduced the final ISO image size from `2.1 GiB` down to **`1.91 GiB` (`1,955 MiB`)**—fitting comfortably under GitHub's 2 GB file limit (`6.68 GB` rootfs compressed to `1.67 GB` SquashFS at a `25.61%` ratio).
*   **Automated XBPS `noextract` Rules (`/etc/xbps.d/99-noextract.conf`):**
    *   Injected directly via `build-live-iso-umno-v1.sh` to strip unused locales (keeping English, Russian) and documentation during build and future package installs.
    *   Preserved `/usr/include/*` and static headers (`*.a`) so `dkms`, `linux-headers`, and `broadcom-wl-dkms` continue to build cleanly.
*   **Tighter SquashFS Compression:** Enabled `xz` compression with x86 BCJ filtering (`-s "-comp xz -Xbcj x86"`) in `mklive.sh`.
*   **Asset & Theme Deduplication:** Purged unused icon and cursor themes to prevent `tmp-rootfs` inode/space exhaustion and save hundreds of megabytes of uncompressed SVG files.

---

## 📦 Package & Service Changes

### Added / Retained
*   **`umbriel` & `noctalia`** – Native Wayland compositor and integrated shell.
*   **`xdg-desktop-portal-umbriel`, `xdg-desktop-portal-gtk`, `xdg-desktop-portal-termfilechooser`** – Lightweight Wayland portal stack.
*   **`b43-fwcutter` & `broadcom-wl-dkms`** – Full out-of-the-box Wi-Fi support across MacBook Pro (Mid 2014), iMac 8.1, and standard PC hardware.

### Removed
*   **`niri`** – Replaced by `umbriel`.
*   **`swaylock` & `swayidle`** – Purged completely; superseded by Noctalia's native lock screen and `elogind` suspend integration.
*   **`xdg-desktop-portal-gnome`** – Dropped to avoid pulling in heavy GNOME/GTK4 dependencies.
*   **`dhcpcd` & `wireless_tools`** – Removed from both the host and ISO `/var/service` to avoid network conflicts with `NetworkManager` + `wpa_supplicant` + `iw`.
*   **Duplicate Entries** – Cleaned up duplicate package definitions (e.g., `btop`).

---

## 💾 Flashing Instructions

Since the ISO is now under 2.0 GiB, no `cat` file joining is required. Write directly to your USB drive (replace `/dev/sdX` with your target device from `lsblk`):

```bash
lsblk **command to define drive letter, example /dev/sdb 
sudo dd bs=4M if=/your_path_to/void-live-umno-v1.iso of=/dev/sdX conv=fsync status=progress
```
