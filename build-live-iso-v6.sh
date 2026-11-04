#!/bin/bash
set -e

INCLUDED_DIR="./included_files"
OUTPUT_DIR="/home/jp/snapshots"

echo "==> 1. Clearing structure..."
rm -rf "$INCLUDED_DIR"
mkdir -p "$INCLUDED_DIR/usr/bin"
mkdir -p "$INCLUDED_DIR/usr/lib"
mkdir -p "$INCLUDED_DIR/etc/skel/.config"
mkdir -p "$INCLUDED_DIR/usr/share/fonts/truetype/custom"

echo "==> 2. Copy bin files..."
cp /usr/bin/niri "$INCLUDED_DIR/usr/bin/"
cp /usr/bin/noctalia "$INCLUDED_DIR/usr/bin/"

echo "==> 2.5 Autocollect local dependencies (dynamic linking)..."
# Script reads ldd niri and noctalia, filters standart basic things
# and copy specific .so libs, which may be not peresent in clear ISO
for bin in /usr/bin/niri /usr/bin/noctalia; do
    ldd "$bin" | grep "=> /" | awk '{print $3}' | while read -r lib; do
        # Ignoring system libraries like: libc, libm, libpthread etc...
        if [[ ! "$lib" =~ libc\.so|libm\.so|libpthread\.so|libdl\.so|librt\.so ]]; then
            cp -n "$lib" "$INCLUDED_DIR/usr/lib/" 2>/dev/null || true
        fi
    done
done
echo "   [✓] Local libraries isolated and packed."


echo "==> 2.8 Embedding compiled Wi-Fi Broadcom driver"

# Looking for current kernel version.
ISO_KERNEL_VER=$(uname -r)

# Seeking path and wl module extention on host computer
# (it may be wl.ko, wl.ko.xz or wl.ko.zst in /extra directory).
REAL_MODULE_PATH=$(find "/usr/lib/modules/${ISO_KERNEL_VER}" -name "wl.ko*" | head -n 1)

if [ -z "$REAL_MODULE_PATH" ]; then
    echo "   [❌] Error: Module wl.ko not found in /usr/lib/modules/${ISO_KERNEL_VER}!"
    exit 1
fi

# Getting exact file name (for example, wl.ko.xz).
MODULE_FILE_NAME=$(basename "$REAL_MODULE_PATH")

# In Void Linux wl-dkms-modules should be in /extra directory inside ISO image.
MODULE_DEST="usr/lib/modules/${ISO_KERNEL_VER}/extra"
mkdir -p "$INCLUDED_DIR/${MODULE_DEST}"

# Copying wl-dkms-module.
cp "$REAL_MODULE_PATH" "$INCLUDED_DIR/${MODULE_DEST}/"
echo "   [✓] Driver ${MODULE_FILE_NAME} sucessfully copyed to ISO for kernel version ${ISO_KERNEL_VER}"



echo "==> 3. Copying fonts and configs..."
[ -d "/home/jp/.fonts" ] && cp -r /home/jp/.fonts/* "$INCLUDED_DIR/usr/share/fonts/truetype/custom/"
[ -d "/home/jp/.config/niri" ] && cp -r /home/jp/.config/niri "$INCLUDED_DIR/etc/skel/.config/"
[ -d "/home/jp/.config/noctalia" ] && cp -r /home/jp/.config/noctalia "$INCLUDED_DIR/etc/skel/.config/"

# Copying noctalia assets.
if [ -d "/usr/share/noctalia" ]; then
    mkdir -p "$INCLUDED_DIR/usr/share"
    cp -r /usr/share/noctalia "$INCLUDED_DIR/usr/share/"
    echo "   [✓] Directory /usr/share/noctalia (including tabler.ttf and sounds) copyed to ISO."
fi

echo "==> 4. Linking Wayland and network services..."
mkdir -p "$INCLUDED_DIR/etc/runit/runsvdir/default"
ln -sf /etc/sv/seatd "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/dbus "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/elogind "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/dhcpcd "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/mbpfan "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/NetworkManager "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/bluetoothd "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/alsa "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/polkitd "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/adb "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/wpa_supplicant "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/udevd "$INCLUDED_DIR/etc/runit/runsvdir/default/"

echo "==> 4.1 Building unified script rc.local (Permissions, cache and logic for Mac hardware drivers)..."
mkdir -p "$INCLUDED_DIR/etc"

cat << 'EOF' | sudo tee "$INCLUDED_DIR/etc/rc.local"
#!/bin/sh

# 1. Permissions for user anon on Wayland session.
usermod -aG _seatd,video,audio,input anon

# 2. Indexing WiFi driver.
depmod -a 2>/dev/null

# 3. Automatic selection and loading of the wl driver based on the Mac model.
echo "==> Detecting Mac hardware for Wi-Fi..." >> /var/log/rc.local.log
# Get hardware string (e.g., MacBookPro11,1).
MAC_MODEL=$(dmidecode -s system-product-name 2>/dev/null || cat /sys/class/dmi/id/product_name 2>/dev/null)

sleep 2
# Unload conflicting open-source drivers.
modprobe -r b43 bcma ssb brcmsmac 2>/dev/null || true

# Example logic: if the Mac model requires wl.
if echo "$MAC_MODEL" | grep -iqE "MacBookPro|MacBookAir|MacMini|iMac"; then
    echo "Mac detected ($MAC_MODEL), activating proprietary wl driver..." >> /var/log/rc.local.log
    modprobe wl 2>/dev/null || insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/wl.ko 2>/dev/null
else
    echo "Standard hardware ($MAC_MODEL), using default drivers..." >> /var/log/rc.local.log
    # If b43 is needed back for regular PCs:
    # modprobe b43 2>/dev/null
fi

# 4. Updating font cache inside the ISO.
fc-cache -f

exit 0
EOF

# Make the file executable.
sudo chmod +x "$INCLUDED_DIR/etc/rc.local"


echo "==> 4.2 Blacklisting conflicting Wi-Fi drivers in modprobe..."
mkdir -p "$INCLUDED_DIR/etc/modprobe.d"
cat << 'EOF' | sudo tee "$INCLUDED_DIR/etc/modprobe.d/broadcom.conf"
blacklist b43
blacklist b43legacy
blacklist bcma
blacklist ssb
blacklist brcmsmac
EOF

echo "==> 4.3 Copying binary module wl.ko from host to ISO..."

# 1. Extract what the script considers the kernel version for the ISO (yours is 6.18_1)
# We take the variable that output "[i] Detected kernel version for ISO:"
# Assuming this is the $TARGET_KERNEL or $KERNEL_VERSION variable in your base script.
# If the variable name is different, replace "6.18_1" with it.
ISO_VERSION="6.18_1" 

# 2. Get the actual kernel version on the host (6.18.58_1)
HOST_VERSION=$(uname -r)

echo "   [i] Synchronization: Host (${HOST_VERSION}) -> ISO (${ISO_VERSION})"

# 3. Find where the wl.ko.* file actually resides on the host
REAL_WL=$(find "/lib/modules/${HOST_VERSION}" -name "wl.ko*" | head -n 1)

if [ -z "$REAL_WL" ]; then
    echo "   [❌] Error: wl driver is not installed on the host in /lib/modules/${HOST_VERSION}!"
    exit 1
fi

# 4. Create the target directory inside the ISO structure (for version 6.18_1)
# The script expects the path /lib/modules/6.18_1/extra/
TARGET_DIR="$INCLUDED_DIR/usr/lib/modules/${ISO_VERSION}/extra"
mkdir -p "${TARGET_DIR}"

# 5. Copy and force-rename to what the script expects (wl.ko.xz)
# Regardless of whether it is compressed on the host as .zst, .xz, or exists as raw .ko
if [[ "$REAL_WL" == *.xz ]]; then
    cp "$REAL_WL" "${TARGET_DIR}/wl.ko.xz"
elif [[ "$REAL_WL" == *.zst ]]; then
    # Decompress zst and compress into xz (if the ISO enforces strict extension parsing)
    zstd -d -c "$REAL_WL" | xz -c > "${TARGET_DIR}/wl.ko.xz"
else
    # If the file was just a raw .ko, compress it into xz
    xz -c "$REAL_WL" > "${TARGET_DIR}/wl.ko.xz"
fi

echo "   [✓] Driver successfully adapted and copied as ${TARGET_DIR}/wl.ko.xz"



echo "==> 4.4 Integrating void-installer into the image..."
# Check if the installer script exists in the directory where mklive is running
if [ -f "./installer.sh" ]; then
    mkdir -p "$INCLUDED_DIR/usr/bin"
    cp ./installer.sh "$INCLUDED_DIR/usr/bin/void-installer"
    chmod +x "$INCLUDED_DIR/usr/bin/void-installer"
    echo "   [✓] void-installer successfully added to the image."
else
    echo "   [❌] Error: installer.sh file not found in the current directory!"
fi

echo "==> 5. Building ISO..."
# Package base has been expanded: base system, niri, sway, void-installer
REPO_MAIN="https://repo-default.voidlinux.org/current/"
REPO_NONFREE="https://repo-default.voidlinux.org/current/nonfree"

sudo ./mklive.sh \
  -r "${REPO_MAIN}" \
  -r "${REPO_NONFREE}" \
  -I "$INCLUDED_DIR" \
  -p "base-system xorg-server-xwayland libinput libxkbcommon wayland pipewire wireplumber dbus polkit elogind seatd mesa-dri kitty pango cairo fontconfig libglvnd libX11 vulkan-loader pam git dhcpcd btop firefox fuzzypkg niri void-repo-nonfree vlc deadbeef fuzzel audacious gdk-pixbuf librsvg glib wireless_tools wpa_supplicant iw btop bookworm swayfx swaylock swayidle swaybg swayimg swaykbdd swayr swayrbar SwayNotificationCenter sway-audio-idle-inhibit dialog parted gptfdisk mac-fdisk e2fsprogs dosfstools curl util-linux grub grub-x86_64-efi grub-btrfs grub-btrfs-runit grub-utils NetworkManager xmirror wget b43-fwcutter dkms linux-headers mbpfan broadcom-wl-dkms" \
  -o "$OUTPUT_DIR/void-live-perfect-v6.iso"

echo "==> 🎉 Image built successfully!"
