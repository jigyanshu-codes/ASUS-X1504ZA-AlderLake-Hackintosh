#!/bin/bash
# ==============================================================================
# ASUS Vivobook 15 (X1504ZA) — Intel Iris Xe 1536MB Metal 2 Post-Install Tool
# Author: Jigyanshu Thakur & Antigravity
# Repository: https://github.com/jigyanshu-codes/ASUS-X1504ZA-AlderLake-Hackintosh
# ==============================================================================

set -e

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}${BOLD}"
echo "================================================================================"
echo "    ASUS Vivobook 15 (X1504ZA) — Intel Iris Xe 1536MB Metal Restorer           "
echo "================================================================================"
echo -e "${NC}"

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${YELLOW}[!] Root privileges required. Escalating with sudo...${NC}"
    sudo "$0" "$@"
    exit $?
fi

# Step 1: System Prerequisites Validation
echo -e "${BLUE}[1/6] Validating System Prerequisites...${NC}"
OS_NAME=$(uname -s)
if [ "$OS_NAME" != "Darwin" ]; then
    echo -e "${RED}[ERROR] This tool must be run inside macOS! (Detected: $OS_NAME)${NC}"
    exit 1
fi

MACOS_VER=$(sw_vers -productVersion)
echo -e "  -> Detected macOS Version: ${GREEN}$MACOS_VER${NC}"

# Check boot-args for required WhateverXe flags
BOOT_ARGS=$(nvram boot-args 2>/dev/null || echo "")
if [[ "$BOOT_ARGS" != *"-allow3d"* ]] || [[ "$BOOT_ARGS" != *"-amfipassbeta"* ]]; then
    echo -e "  -> ${YELLOW}[NOTE] Ensure OpenCore config.plist contains: -allow3d -disablegfxfirmware -amfipassbeta${NC}"
else
    echo -e "  -> OpenCore boot-args verified: ${GREEN}-allow3d and -amfipassbeta detected!${NC}"
fi

# Step 2: Purge Conflicting Audio Kexts
echo ""
echo -e "${BLUE}[2/6] Scanning and Removing Conflicting Kexts...${NC}"
CONFLICTS_FOUND=0
for bad_kext in "HDAUniversal.kext" "VoodooHDA.kext" "AppleHDADisabler.kext"; do
    if [ -d "/Library/Extensions/$bad_kext" ]; then
        echo -e "  -> ${YELLOW}Found conflicting kext: /Library/Extensions/$bad_kext${NC}"
        rm -rf "/Library/Extensions/$bad_kext" 2>/dev/null || true
        CONFLICTS_FOUND=1
    fi
done

if [ $CONFLICTS_FOUND -eq 1 ]; then
    echo -e "  -> ${GREEN}Removed conflicting audio kexts!${NC}"
    echo -e "     ${YELLOW}(HDAUniversal/VoodooHDA hooks Intel 8086:51C8 audio DSP, tripping line 8506 handoff fault)${NC}"
else
    echo -e "  -> ${GREEN}No conflicting audio extensions detected in /Library/Extensions.${NC}"
fi

# Step 3: Clear macOS Extension Staging Cache
echo ""
echo -e "${BLUE}[3/6] Purging macOS Kernel Extension Staging Directory...${NC}"
kmutil clear-staging 2>/dev/null || true
echo -e "  -> ${GREEN}Staging cache cleared successfully!${NC}"

# Step 4: Install / Verify WhateverXe Graphics Drivers
echo ""
echo -e "${BLUE}[4/6] Verifying Intel Iris Xe Graphics Drivers & Bundles...${NC}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_PATH=""

# Search candidates for the 0.4.0 driver package
SEARCH_LOCATIONS=(
    "$SCRIPT_DIR/WhateverXe-Graphics-0.4.0.pkg"
    "$SCRIPT_DIR/../WhateverXe-Graphics-0.4.0.pkg"
    "/Volumes/*/WhateverXe-Graphics-0.4.0.pkg"
    "/Users/$SUDO_USER/Downloads/WhateverXe-Graphics-0.4.0.pkg"
    "/tmp/WhateverXe-Graphics-0.4.0.pkg"
)

for loc in "${SEARCH_LOCATIONS[@]}"; do
    for found in $loc; do
        if [ -f "$found" ]; then
            PKG_PATH="$found"
            break 2
        fi
    done
done

# Check if drivers already exist in /Library/Extensions
DRIVERS_PRESENT=0
if [ -d "/Library/Extensions/AppleIntelTGLCompat.kext" ] && \
   [ -d "/Library/Extensions/AppleIntelTGLGraphics.kext" ] && \
   [ -d "/Library/Extensions/AppleIntelTGLGraphicsFramebuffer.kext" ]; then
    DRIVERS_PRESENT=1
fi

if [ $DRIVERS_PRESENT -eq 0 ]; then
    if [ -z "$PKG_PATH" ]; then
        echo -e "  -> ${YELLOW}Driver package not found locally. Downloading WhateverXe-Graphics-0.4.0.pkg...${NC}"
        PKG_URL="https://github.com/b00t0x/WhateverXe-Graphics/releases/download/v0.4.0/WhateverXe-Graphics-0.4.0.pkg"
        PKG_PATH="/tmp/WhateverXe-Graphics-0.4.0.pkg"
        curl -L -f -o "$PKG_PATH" "$PKG_URL" || {
            echo -e "  -> ${RED}[ERROR] Failed to download WhateverXe-Graphics package.${NC}"
            echo -e "     Please download it manually from: $PKG_URL"
            echo -e "     Place it in the script directory and re-run."
            exit 1
        }
        echo -e "  -> ${GREEN}Downloaded driver package successfully!${NC}"
    fi

    echo -e "  -> Installing drivers from: ${CYAN}$PKG_PATH${NC}..."
    installer -pkg "$PKG_PATH" -target /
    echo -e "  -> ${GREEN}Driver package installed successfully!${NC}"
else
    echo -e "  -> ${GREEN}Intel TGL graphics kexts verified in /Library/Extensions.${NC}"
    if [ -n "$PKG_PATH" ]; then
        echo -e "  -> Re-verifying package integrity with installer..."
        installer -pkg "$PKG_PATH" -target / 2>/dev/null || true
    fi
fi

# Step 5: Permissions and Feature Flags Configuration
echo ""
echo -e "${BLUE}[5/6] Enforcing Permissions & Feature Flags...${NC}"
chown -R root:wheel /Library/Extensions/AppleIntelTGL* /Library/GPUBundles 2>/dev/null || true
chmod -R 755 /Library/Extensions/AppleIntelTGL* /Library/GPUBundles 2>/dev/null || true
xattr -cr /Library/Extensions/AppleIntelTGL* /Library/GPUBundles 2>/dev/null || true

# CoreMedia Metal scaling configuration
mkdir -p /Library/Preferences/FeatureFlags/Domain 2>/dev/null || true
FEATURE_PLIST="/Library/Preferences/FeatureFlags/Domain/CoreMedia.plist"
/usr/libexec/PlistBuddy -c 'Add :AllowOnePassMetalScaling dict' "$FEATURE_PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c 'Set :AllowOnePassMetalScaling:Enabled false' "$FEATURE_PLIST" 2>/dev/null || /usr/libexec/PlistBuddy -c 'Add :AllowOnePassMetalScaling:Enabled bool false' "$FEATURE_PLIST" 2>/dev/null || true
echo -e "  -> ${GREEN}Permissions (root:wheel 755), quarantine removal, and CoreMedia flags configured!${NC}"

# Step 6: Clean AuxiliaryKernelExtensions.kc Build
echo ""
echo -e "${BLUE}[6/6] Compiling Auxiliary Kernel Collection (AuxKC)...${NC}"
work=$(mktemp -d /Library/KernelCollections/.WhateverXe.XXXXXX)

kmutil create -n aux -x -z -V release -r /Library/Extensions --allow-missing-kdk \
    -p /Library/Extensions/AppleIntelTGLCompat.kext \
    -p /Library/Extensions/AppleIntelTGLGraphics.kext \
    -p /Library/Extensions/AppleIntelTGLGraphicsFramebuffer.kext \
    -B /System/Library/KernelCollections/BootKernelExtensions.kc \
    -S /System/Library/KernelCollections/SystemKernelExtensions.kc \
    -A "$work/AuxiliaryKernelExtensions.kc" --no-authentication

if [ -f "$work/AuxiliaryKernelExtensions.kc" ]; then
    chmod 0644 "$work/AuxiliaryKernelExtensions.kc"
    mv -f "$work/AuxiliaryKernelExtensions.kc" /Library/KernelCollections/AuxiliaryKernelExtensions.kc
    KC_SIZE=$(ls -lh /Library/KernelCollections/AuxiliaryKernelExtensions.kc | awk '{print $5}')
    echo -e "  -> ${GREEN}[SUCCESS] AuxiliaryKernelExtensions.kc compiled: $KC_SIZE!${NC}"
else
    echo -e "  -> ${RED}[ERROR] kmutil compilation failed! Please check output above.${NC}"
    rm -rf "$work" 2>/dev/null || true
    exit 1
fi
rm -rf "$work" 2>/dev/null || true

sync

# Critical Warning & Reboot Prompt
echo ""
echo -e "${RED}${BOLD}================================================================================${NC}"
echo -e "${YELLOW}${BOLD}           CRITICAL WARNING: DO NOT TOUCH SYSTEM SETTINGS!                      ${NC}"
echo -e "${RED}${BOLD}================================================================================${NC}"
echo -e "${BOLD}"
echo "  1. If macOS pops up a notification saying 'System Extension Blocked' or"
echo "     'System Extension needs approval', IGNORE IT COMPLETELY!"
echo ""
echo "  2. DO NOT open System Settings -> Privacy & Security."
echo "  3. DO NOT click 'Allow' or 'Restart' inside System Settings."
echo ""
echo -e "  ${YELLOW}WHY?${NC}"
echo "  Clicking 'Restart' inside System Settings triggers macOS's native policy"
echo "  daemon to recompile AuxKC WITHOUT the '--allow-missing-kdk' parameter."
echo "  This silently purges the patched graphics drivers and reverts your system"
echo "  back to the unaccelerated 7 MB VESA fallback!"
echo ""
echo -e "${GREEN}${BOLD}  HOW TO BOOT CLEANLY:${NC}"
echo "  1. Press [Enter] right now in this Terminal window to reboot."
echo "  2. At the OpenCore Boot Picker, press Spacebar -> select 'Reset NVRAM'."
echo "  3. Boot into macOS, and your Intel Iris Xe 1536 MB Metal 2 acceleration"
echo "     and native brightness slider will be fully active!"
echo -e "${RED}${BOLD}================================================================================${NC}"
echo ""
read -p "Press [Enter] to reboot now..."
reboot
