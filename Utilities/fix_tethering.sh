#!/bin/bash
# ==============================================================================
# iPhone USB Tethering Reconnect Utility for macOS Hackintosh
# ==============================================================================
# If your iPhone USB Personal Hotspot randomly drops or stalls, run this script
# to kickstart the Apple Mobile Device daemon and cycle the interface without rebooting.
# ==============================================================================

echo "=== Restarting Apple Mobile Device Daemon (usbmuxd) ==="
sudo launchctl kickstart -k system/com.apple.usbmuxd 2>/dev/null || sudo killall -HUP usbmuxd

# Detect which interface is the USB tether (usually en1 or en2)
IFACE=$(networksetup -listallhardwareports | awk '/iPhone USB|iPad USB/{getline; print $2}')

if [ -z "$IFACE" ]; then
    # Fallback to en1 if not explicitly labeled
    IFACE="en1"
fi

echo "=== Cycling interface: $IFACE ==="
sudo ifconfig "$IFACE" down 2>/dev/null
sleep 1
sudo ifconfig "$IFACE" up 2>/dev/null

echo "=== Done! Ensure Personal Hotspot is unlocked on your iPhone ==="

