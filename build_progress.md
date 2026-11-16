# Void Linux Custom Live ISO Optimization Log (`void-live-umno-v1.iso`)

## 1. Objective
Minimize disk usage and bring a custom `void-mklive` ISO image below **2.0 GiB** while keeping `base-system`, Broadcom Wi-Fi support (`wl` + `b43-fwcutter` for MacBook & iMac8,1), and Wayland desktop tools (`umbriel` / `noctalia`).

---

## 2. Key Optimizations Applied

### A. XBPS `noextract` Rules (`/etc/xbps.d/99-noextract.conf`)
Configured XBPS to skip extracting unused translations, man pages, and documentation during ISO creation and future package installations:
```ini
# Exclude all translations/locales except English
noextract=/usr/share/locale/*
noextract=!/usr/share/locale/en*
noextract=!/usr/share/locale/locale.alias

# Exclude all man pages, info pages, and documentation
noextract=/usr/share/man/*
noextract=/usr/share/info/*
noextract=/usr/share/doc/*
noextract=/usr/share/gtk-doc/*
noextract=/usr/share/help/*
```
*(Kept `/usr/include/*` and `*.a` intact so `dkms`, `linux-headers`, and `broadcom-wl-dkms` compile cleanly.)*

### B. Automated Overlay Integration (`build-live-iso-umno-v1.sh`)
Because `build-live-iso-umno-v1.sh` recreates `$INCLUDED_DIR` (`./included_files`) on every run, `99-noextract.conf` is generated directly inside the build script at `$INCLUDED_DIR/etc/xbps.d/99-noextract.conf`.

### C. Package & Service Cleanup
* **Removed `dhcpcd` & `wireless_tools`**: `NetworkManager` + `wpa_supplicant` + `iw` already handle DHCP and Wi-Fi without service conflicts (`sudo rm /var/service/dhcpcd` on host and removed symlink from ISO).
* **Removed `xdg-desktop-portal-gnome`**: Avoided pulling in heavy GNOME/GTK4 libraries while keeping `xdg-desktop-portal-umbriel`, `xdg-desktop-portal-gtk`, and `xdg-desktop-portal-termfilechooser`.
* **Removed duplicates/redundancies**: Removed duplicate `btop` entry and `wget` (replaced by `curl`).
* **Kept `base-system` & `b43-fwcutter`**: Maintained full hardware compatibility across MacBook, iMac8,1, and standard PCs.

### D. Overlay & SquashFS Compression Tuning
* **Removed unused icon & cursor themes**: Prevented `tmp-rootfs` space/inode exhaustion and cut hundreds of megabytes of uncompressed SVG files.
* **Tightened SquashFS compression**: Added `-s "-comp xz -Xbcj x86"` to `./mklive.sh`.

---

## 3. Build Size Progression
* **Initial Build**: `2.1G` (`1,089,536` sectors)
* **Final Optimized Build**: `1.91 GiB` / `1955 MiB` (`1,000,728` sectors; `6.68 GB` rootfs compressed to `1.67 GB` SquashFS at `25.61%` ratio)

---

## 4. USB Flashing Command
```bash
sudo dd bs=4M if=/home/jp/snapshots/void-live-umno-v1.iso of=/dev/sdX conv=fsync status=progress
```
*(Replace `/dev/sdX` with the target USB device from `lsblk`.)*
