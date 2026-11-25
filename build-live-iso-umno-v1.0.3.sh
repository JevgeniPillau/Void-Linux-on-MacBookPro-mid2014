#!/bin/bash
set -e

# Colors
GREEN='\033[38;2;74;222;128m'
YELLOW='\033[38;2;250;204;21m'
NC='\033[0m' # No Color

INCLUDED_DIR="./included_files"
OUTPUT_DIR="/home/jp/snapshots"
ISO_NAME="void-live-umno-v1.0.3.iso"

echo -e "${YELLOW}====================================================================================================${NC}"
echo "==> 1. Clearing structure..."
echo -e "${YELLOW}====================================================================================================${NC}"
sudo rm -rf "$INCLUDED_DIR"
mkdir -p "$INCLUDED_DIR/usr/bin"
mkdir -p "$INCLUDED_DIR/usr/lib"
mkdir -p "$INCLUDED_DIR/etc/skel/.config"
mkdir -p "$INCLUDED_DIR/usr/share/fonts/truetype/custom"
cp -a /home/jp/void-mklive/my-overlay/. "$INCLUDED_DIR/"

echo -e "${YELLOW}====================================================================================================${NC}"
echo "==> 1.5 Adding XBPS noextract rules for minimal disk usage..."
echo -e "${YELLOW}====================================================================================================${NC}"
mkdir -p "$INCLUDED_DIR/etc/xbps.d"
cat << 'EOF' > "$INCLUDED_DIR/etc/xbps.d/99-noextract.conf"
# Exclude all translations/locales except English and Russian
noextract=/usr/share/locale/*
noextract=!/usr/share/locale/en*
noextract=!/usr/share/locale/ru*
noextract=!/usr/share/locale/locale.alias

# Exclude all man pages, info pages, and help files
noextract=!/usr/share/man/*
noextract=!/usr/share/info/*
noextract=/usr/share/doc/*
noextract=/usr/share/gtk-doc/*
noextract=!/usr/share/help/*
EOF

echo -e "${YELLOW}====================================================================================================${NC}"
echo "==> 1.6 Copying UniversalRepository signing key..."
echo -e "${YELLOW}====================================================================================================${NC}"
mkdir -p "$INCLUDED_DIR/var/db/xbps/keys"
sudo cp /var/db/xbps/keys/0f:fa:c3:8e:fd:cd:c9:52:88:f0:34:ca:df:6c:c6:fa.plist "$INCLUDED_DIR/var/db/xbps/keys/"



echo -e "${YELLOW}====================================================================================================${NC}"
echo "==> 2. Copy bin files..."
echo -e "${YELLOW}====================================================================================================${NC}"
cp /usr/bin/umbriel "$INCLUDED_DIR/usr/bin/"
cp /usr/bin/noctalia "$INCLUDED_DIR/usr/bin/"

echo "==> 2.5 Autocollect local dependencies (dynamic linking)..."
for bin in /usr/bin/umbriel /usr/bin/noctalia; do
    ldd "$bin" | grep "=> /" | awk '{print $3}' | while read -r lib; do
        if [[ ! "$lib" =~ libc\.so|libm\.so|libpthread\.so|libdl\.so|librt\.so ]]; then
            cp -n "$lib" "$INCLUDED_DIR/usr/lib/" 2>/dev/null || true
        fi
    done
done
echo "   [✓] Local libraries isolated and packed."

echo -e "${YELLOW}====================================================================================================${NC}"
echo "==> 3. Copying fonts and configs..."
echo -e "${YELLOW}====================================================================================================${NC}"
[ -d "/home/jp/.fonts" ] && cp -r /home/jp/.fonts/* "$INCLUDED_DIR/usr/share/fonts/truetype/custom/"
[ -d "/home/jp/.config/umbriel" ] && cp -r /home/jp/.config/umbriel "$INCLUDED_DIR/etc/skel/.config/"
[ -d "/home/jp/.config/noctalia" ] && cp -r /home/jp/.config/noctalia "$INCLUDED_DIR/etc/skel/.config/"

# Smart copy of .desktop shortcuts (only for apps that exist or hide unused entries)
mkdir -p "$INCLUDED_DIR/etc/skel/.local/share/applications"

for dir in "/home/jp/.local/share/applications" "/usr/local/share/applications"; do
    [ -d "$dir" ] || continue
    for file in "$dir"/*.desktop; do
        [ -f "$file" ] || continue
        
        # 1. Always copy override files that hide unwanted menu items (NoDisplay=true)
        if grep -q "^NoDisplay=true" "$file"; then
            cp -f "$file" "$INCLUDED_DIR/etc/skel/.local/share/applications/"
            continue
        fi

        # 2. Extract the binary name from Exec= line (ignoring env vars and arguments)
        EXEC_BIN=$(grep -m1 "^Exec=" "$file" | sed -E 's/^Exec=//; s/^env [^ ]+ //; s/"//g' | awk '{print $1}')
        BIN_NAME=$(basename "$EXEC_BIN")

        # 3. Copy only if the program is installed or part of our ISO binaries/scripts
        if [[ "$BIN_NAME" =~ ^(firefox|kitty|mpv|btop|fresh|superfile|cliamp|umbriel|noctalia|fuzzel|void-installer|post-install)$ ]] || \
           [ -f "$INCLUDED_DIR/usr/bin/$BIN_NAME" ] || \
           [ -f "$INCLUDED_DIR/usr/local/bin/$BIN_NAME" ]; then
            cp -f "$file" "$INCLUDED_DIR/etc/skel/.local/share/applications/"
        fi
    done
done
echo "   [✓] Valid .desktop shortcuts filtered and copied."


# Copying noctalia assets.
if [ -d "/usr/share/noctalia" ]; then
    mkdir -p "$INCLUDED_DIR/usr/share"
    cp -r /usr/share/noctalia "$INCLUDED_DIR/usr/share/"
    echo "   [✓] Directory /usr/share/noctalia (including tabler.ttf and sounds) copied to ISO."
fi

echo -e "${YELLOW}====================================================================================================${NC}"
echo "==> 4. Linking Wayland and network services..."
echo -e "${YELLOW}====================================================================================================${NC}"
mkdir -p "$INCLUDED_DIR/etc/runit/runsvdir/default"
ln -sf /etc/sv/seatd "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/dbus "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/elogind "$INCLUDED_DIR/etc/runit/runsvdir/default/"
#ln -sf /etc/sv/dhcpcd "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/mbpfan "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/NetworkManager "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/bluetoothd "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/alsa "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/polkitd "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/adb "$INCLUDED_DIR/etc/runit/runsvdir/default/"
#ln -sf /etc/sv/wpa_supplicant "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/udevd "$INCLUDED_DIR/etc/runit/runsvdir/default/"
ln -sf /etc/sv/nftables "$INCLUDED_DIR/etc/runit/runsvdir/default/"

echo -e "${YELLOW}====================================================================================================${NC}"
echo "==> 4.1 Building unified script rc.local (Permissions, cache and logic for Mac hardware drivers)..."
echo -e "${YELLOW}====================================================================================================${NC}"
mkdir -p "$INCLUDED_DIR/etc"

cat << 'EOF' | sudo tee "$INCLUDED_DIR/etc/rc.local"
#!/bin/sh

# 1. Permissions for user anon on Wayland session.
usermod -aG _seatd,video,audio,input anon

# 2. Indexing WiFi driver.
depmod -a 2>/dev/null

# 3. Automatic selection and loading of the wl driver based on the Mac model.
echo "==> Detecting Mac hardware for Wi-Fi..." >> /var/log/rc.local.log
MAC_MODEL=$(dmidecode -s system-product-name 2>/dev/null || cat /sys/class/dmi/id/product_name 2>/dev/null)

sleep 2
modprobe -r b43 bcma ssb brcmsmac 2>/dev/null || true

if echo "$MAC_MODEL" | grep -iqE "MacBookPro|MacBookAir|MacMini|iMac"; then
    echo "Mac detected ($MAC_MODEL), activating proprietary wl driver..." >> /var/log/rc.local.log
    modprobe wl 2>> /var/log/rc.local.log || true
else
    echo "Standard hardware ($MAC_MODEL), using default drivers..." >> /var/log/rc.local.log
fi

# 4. Updating font cache inside the ISO.
fc-cache -f

exit 0
EOF

sudo chmod +x "$INCLUDED_DIR/etc/rc.local"

echo -e "${YELLOW}====================================================================================================${NC}"
echo "==> 4.2 Blacklisting conflicting Wi-Fi drivers in modprobe..."
echo -e "${YELLOW}====================================================================================================${NC}"
mkdir -p "$INCLUDED_DIR/etc/modprobe.d"
cat << 'EOF' | sudo tee "$INCLUDED_DIR/etc/modprobe.d/broadcom.conf"
blacklist b43
blacklist b43legacy
blacklist bcma
blacklist ssb
blacklist brcmsmac
EOF

echo -e "${YELLOW}====================================================================================================${NC}"
echo "==> 4.4 Integrating void-installer into the image..."
echo -e "${YELLOW}====================================================================================================${NC}"
if [ -f "./installer.sh" ]; then
    mkdir -p "$INCLUDED_DIR/usr/bin"
    cp ./installer.sh "$INCLUDED_DIR/usr/bin/void-installer"
    chmod +x "$INCLUDED_DIR/usr/bin/void-installer"
    echo "   [✓] void-installer successfully added to the image."
else
    echo "   [❌] Error: installer.sh file not found in the current directory!"
fi

echo -e "${YELLOW}====================================================================================================${NC}"
echo "==> 4.5 Applying Network Hardening (nftables + sysctl) and udev backlight rules..."
echo -e "${YELLOW}====================================================================================================${NC}"
mkdir -p "$INCLUDED_DIR/etc/sysctl.d" "$INCLUDED_DIR/etc/udev/rules.d"

cat << 'EOF' | sudo tee "$INCLUDED_DIR/etc/nftables.conf" > /dev/null
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        iifname "lo" accept
        ct state invalid drop
        ct state established,related accept

        ip6 nexthdr ipv6-icmp icmpv6 type {
            destination-unreachable, packet-too-big, time-exceeded,
            parameter-problem, nd-router-advert, nd-neighbor-solicit,
            nd-neighbor-advert
        } accept

        ip protocol icmp icmp type echo-request limit rate 5/second accept
        ip6 nexthdr ipv6-icmp icmpv6 type echo-request limit rate 5/second accept

        counter drop
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF
sudo chmod 755 "$INCLUDED_DIR/etc/nftables.conf"

cat << 'EOF' | sudo tee "$INCLUDED_DIR/etc/sysctl.d/99-network-hardening.conf" > /dev/null
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
EOF

cat << 'EOF' | sudo tee "$INCLUDED_DIR/etc/udev/rules.d/90-kbd-backlight.rules" > /dev/null
ACTION=="add", SUBSYSTEM=="leds", KERNEL=="*kbd_backlight*", RUN+="/bin/chgrp video /sys$devpath/brightness", RUN+="/bin/chmod g+w /sys$devpath/brightness"
EOF
echo "   [✓] nftables, sysctl hardening, and udev rules injected."

echo -e "${GREEN}==> ✅ Part 1 complete! Overlay directory $INCLUDED_DIR is ready.${NC}"

echo -e "${YELLOW}====================================================================================================${NC}"
echo "==> 5. Building ISO..."
echo -e "${YELLOW}====================================================================================================${NC}"
REPO_MAIN="https://repo-default.voidlinux.org/current"
REPO_NONFREE="https://repo-default.voidlinux.org/current/nonfree"
REPO_UNIVERSAL="https://universalrepo.pages.dev/void"

yes | sudo ./mklive.sh \
  -r "${REPO_MAIN}" \
  -r "${REPO_NONFREE}" \
  -r "${REPO_UNIVERSAL}" \
  -I "$INCLUDED_DIR" \
  -s xz \
  -p "base-system dkms linux-headers broadcom-wl-dkms b43-fwcutter xorg-server-xwayland pipewire wireplumber dbus polkit elogind seatd mesa-dri kitty vulkan-loader git btop fuzzypkg void-repo-nonfree fuzzel wpa_supplicant iw dialog parted gptfdisk mac-fdisk e2fsprogs dosfstools curl grub grub-x86_64-efi grub-btrfs grub-btrfs-runit grub-utils NetworkManager xmirror mbpfan fcron hblock firefox mpv nftables umbriel xdg-desktop-portal-umbriel xdg-desktop-portal-gtk xdg-desktop-portal-termfilechooser" \
  -o "$OUTPUT_DIR/$ISO_NAME"

echo -e "${GREEN}===================================================================================================${NC}"
echo "==> 🎉 Congratulations, the image built successfully!"
echo -e "${GREEN}===================================================================================================${NC}"
echo "To write image to USB drive use command:"
echo "sudo dd bs=4M if=$OUTPUT_DIR/$ISO_NAME of=/dev/sdX conv=fsync status=progress"
echo "(Change sdX to appropriate letter from lsblk output, example /dev/sdb)"
echo -e "${GREEN}===================================================================================================${NC}"
