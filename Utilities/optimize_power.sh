#!/bin/bash
# ==============================================================================
# Optimal Power & Sleep Management for Alder Lake Hackintosh
# ==============================================================================
# Disables low-power USB suspension and deep hibernation that causes peripheral
# drops (USB tethering, Bluetooth sleep stalls) on modern Intel laptops.
# ==============================================================================

echo "=== Applying Hackintosh Power Settings ==="
sudo pmset -a displaysleep 15
sudo pmset -a disksleep 0
sudo pmset -a sleep 0
sudo pmset -a hibernatemode 0
sudo pmset -a powernap 0
sudo pmset -a proximitywake 0
sudo pmset -a tcpkeepalive 1

# Remove existing sleepimage to free disk space and prevent hibernate wakes
if [ -f /var/vm/sleepimage ]; then
    echo "=== Purging legacy sleepimage ==="
    sudo rm -f /var/vm/sleepimage
    sudo touch /var/vm/sleepimage
    sudo chflags uchg /var/vm/sleepimage
fi

echo "=== Power Management configuration complete! ==="

