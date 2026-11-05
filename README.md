# ASUS Vivobook 15 (X1504ZA) — Complete macOS OpenCore Guide & EFI

[![macOS](https://img.shields.io/badge/macOS-Tahoe%2026.x%20%7C%20Sonoma%2014.x%20%7C%20Sequoia%2015.x-blue?style=for-the-badge&logo=apple)](https://www.apple.com/macos)
[![OpenCore](https://img.shields.io/badge/OpenCore-1.0.8%20%2F%201.0.9-green?style=for-the-badge&logo=codefactor)](https://github.com/acidanthera/OpenCorePkg)
[![Intel](https://img.shields.io/badge/CPU-Intel%20Core%20i5--1235U%20(Alder%20Lake)-0071C5?style=for-the-badge&logo=intel)](https://www.intel.com)
[![Graphics](https://img.shields.io/badge/GPU-Intel%20Iris%20Xe%201536MB%20Metal%202-orange?style=for-the-badge&logo=intel)](https://www.intel.com)
[![Maintenance](https://img.shields.io/badge/Status-Actively%20Maintained-brightgreen?style=for-the-badge)](https://github.com)

A fully tested, meticulously documented OpenCore EFI and installation guide for running macOS (**macOS Tahoe 26.7.2**, **macOS Sonoma**, and **macOS Sequoia**) on the **ASUS Vivobook 15 (X1504ZA / Vivobook_ASUSLaptop X1504ZA_X1504ZA)** with **Intel 12th Gen Alder Lake Core i5-1235U** and **Intel Iris Xe Graphics**.

> [!NOTE]
> **A Message From The Author:**
> Getting modern Alder Lake (12th Gen) Intel laptops with Iris Xe graphics and I2C precision trackpads working smoothly on macOS has historically been considered nearly impossible by the Hackintosh community. This repository represents days and weeks of deep debugging, reverse engineering, binary patching, and ACPI table analysis to make it a reality.
>
> **I will NOT drop or abandon this project until every single fixable component is 100% operational.** This repository is under active progress, and updates will be pushed regularly as new breakthroughs occur!

---

## 📸 Screenshots & Proof of Operation

| System Overview & Specs | Iris Xe Metal 2 Graphics Acceleration |
| :---: | :---: |
| ![System Overview](Screenshots/01_System_Overview.png) | ![Metal 2 QE/CI](Screenshots/02_GPU_Metal_Acceleration.png) |

| Peripherals & Storage | Full PCIe Device Tree |
| :---: | :---: |
| ![Peripherals Overview](Screenshots/03_Peripherals_Overview.png) | ![PCIe Tree](Screenshots/04_PCIe_Devices.png) |

---

## 💻 Hardware Specifications

| Component | Hardware Details | macOS Compatibility |
| :--- | :--- | :--- |
| **Model** | ASUS Vivobook 15 `X1504ZA` / `Vivobook_ASUSLaptop X1504ZA_X1504ZA` | Fully Supported |
| **Processor** | Intel Core i5-1235U (10 Cores: 2 Performance + 8 Efficiency, 12 Threads, up to 4.40 GHz) | ✅ Working via `CpuTopologyRebuild` + `CpuTscSync` |
| **Integrated GPU** | Intel Iris Xe Graphics GT2 (`0x46A8` / Alder Lake-UP3 GT2) | ✅ Working (1536 MB VRAM, Metal 2, Full QE/CI acceleration) |
| **RAM** | 20 GB DDR4 3200 MHz (4 GB Onboard + 16 GB SO-DIMM) | ✅ Working (Dual-Channel) |
| **Storage** | 512 GB Samsung PM9B1 NVMe SSD (`MZVL4512HBLU-00B00`) | ✅ Working via `NVMeFix.kext` |
| **Display** | 15.6" Full HD (1920x1080) 60Hz 16:9 Slim-Bezel Display | ✅ Working with Native Brightness Slider |
| **Trackpad** | ASUS Precision Touchpad `ASUP1200` (`ACPI\VEN_ASUP&DEV_1200` on Intel I2C1 `00:15.1`) | 🟡 Working (Smooth cursor & clicks in polling mode) |
| **Keyboard** | ASUS I8042 PS/2 Keyboard with Brightness/Fn Keys | ✅ Working via `VoodooPS2Controller` + `BrightnessKeys` |
| **Audio** | Realtek ALC256 via Intel Smart Sound Technology (`8086:51C8`) | ⚠️ Hardware Limitation (See Audio Section below) |
| **Wi-Fi** | MediaTek Wi-Fi 6 MT7902 M.2 PCIe Card | ❌ Hardware Limitation (No macOS drivers exist) |
| **Bluetooth** | MediaTek Bluetooth Adapter (USB `0x13d3:0x3568`) | 🟡 Detected (Requires external dongle or M.2 upgrade for full Airdrop) |
| **Webcam** | USB2.0 HD UVC WebCam (`0x04f2:0xb797`) | ✅ Working Natively Out of the Box |
| **Ports** | 1x USB-C 3.2 Gen 1, 2x USB-A 3.2 Gen 1, 1x USB-A 2.0, 1x HDMI 1.4 | ✅ Working (Mapped) |
| **Battery / Power** | 3-Cell 42Wh Lithium-ion Battery with 65W AC Adapter | ✅ Working (Accurate percentage, charging status via `AsusSMC`) |

---

## 📊 Detailed Feature Status

### ✅ What is Working (100% Tested & Verified)
* **Intel Iris Xe Full Graphics Acceleration:**
  * **1536 MB VRAM** smoothly allocated.
  * **Metal 2 Acceleration** active (`Intel(R) TGL Unknown` Metal device).
  * **Quartz Extreme & Core Image (QE/CI)** fully working (smooth Dock animations, Mission Control, Launchpad, transparent UI).
  * **VDA Hardware Video Decoder:** Fully Supported (H.264/HEVC hardware playback).
  * WebGPU and WebGL 2 running fluidly at 60 FPS in Safari and Chrome.
* **Native Display Backlight Control:**
  * Native brightness slider integrated right into macOS Control Center and System Settings.
  * Function keys (Fn + F4/F5) dynamically adjust backlight smoothly without flickering.
* **Trackpad (`ASUP1200`):**
  * Fully responsive cursor movement, tap-to-click, physical clicks, and dragging working via `VoodooI2C` + `VoodooI2CHID`.
* **Keyboard & Special Keys:**
  * Full ASUS PS/2 keyboard working natively.
  * Volume shortcuts, brightness keys, sleep hotkeys functional.
* **Battery & Power Management:**
  * Real-time battery percentage, cycle count, and charging state accurately reported via `SMCBatteryManager` and `AsusSMC`.
* **CPU Core Power Management:**
  * Intel Thread Director emulation working through `CpuTopologyRebuild.kext`, properly utilizing both P-cores and E-cores without core starvation or thermal throttling.
* **Storage & NVMe:**
  * Samsung PM9B1 NVMe SSD runs cool and fast with `NVMeFix.kext`.
* **Wired iPhone Personal Hotspot (USB Tethering):**
  * High-speed, stable internet access from your iPhone via USB cable.
* **Apple Services (iCloud, App Store, iMessage):**
  * `NullEthernet.kext` + `SSDT-RMNE.aml` generates a built-in `en0` network interface, granting seamless access to the Mac App Store and iCloud.
* **System Stability:**
  * Clean restarts, shutdowns, and kernel panic protections (`debug=0x100`, `keepsyms=1`).

---

### 🟡 What is Under Active Progress (Work In Progress)

#### 1. Internal Audio (Speakers & Internal Microphone)
* **Why it doesn't work internally yet:**
  On 12th Gen Intel Alder Lake laptops, the audio codec (Realtek ALC256) is **not** wired through a legacy Azalia High Definition Audio controller. Instead, ASUS routes the codec through **Intel Smart Sound Technology (Intel SST cDSP / SoundWire / cAVS)** (`PCI\VEN_8086&DEV_51C8` / `_SB.PC00.I2C1.HDAC`).
  macOS has **never** included drivers for Intel's proprietary SST digital signal processors. Because of this, traditional `AppleALC` cannot see or communicate with the internal speakers or microphone.
* **The Perfect Plug-and-Play Solution:**
  * **USB-C / USB-A to 3.5mm DAC Adapter:** Plugging in any cheap USB audio dongle or Apple's \$9 USB-C Headphone Adapter works **100% instantly out of the box** with macOS native `AppleUSBAudio`! Both crystal-clear stereo audio and microphone input work flawlessly.
  * **Bluetooth Headphones / External Speakers:** Any Bluetooth earphones, headphones, or external Bluetooth speaker connect and stream high-quality audio immediately.

#### 2. Trackpad Interrupt Mode (Native GPIO Pinning)
* The trackpad is currently operating in **Polling Mode** (`-vi2c-force-polling`). It is completely smooth and usable for daily tasks, typing, and navigation. We are currently working on resolving the exact APIC-to-GPIO interrupt pin registration to enable native low-power interrupt mode.

#### 3. Wi-Fi (MediaTek MT7902 Hardware Barrier)
* **Hardware Limitation:** The factory Wi-Fi card shipped in this Vivobook is the **MediaTek MT7902**. The Hackintosh open-source community currently has **no macOS kexts** for MediaTek Wi-Fi 6 chipsets (neither AirportItlwm nor OpenIntelWireless support MediaTek).
* **Recommended Options:**
  1. **USB Tethering (Free & Instant):** Connect your iPhone or Android via USB cable to share your internet connection instantly!
  2. **USB Wi-Fi Nano Dongle:** A \$5 Realtek-based USB Wi-Fi adapter (e.g. TP-Link TL-WN725N using Wireless-USB-Big-Sur-Adapter).
  3. **M.2 Card Replacement (The Ultimate Fix):** Swap the factory MediaTek M.2 card for an **Intel AX200** or **Intel AX210** (approx. \$15 on Amazon/eBay), which works natively with `AirportItlwm.kext` for native macOS Wi-Fi!

---

## 🧠 The "Secret Sauce" — Deep Technical Breakthroughs

If you are curious about *how* this EFI was engineered to bypass seemingly impossible obstacles, here is the technical breakdown:

### 1. Achieving 1536 MB Iris Xe Graphics Acceleration
Intel Iris Xe GT2 (`0x46A8`) is not natively supported by macOS out of the box. Booting without modification results in a black screen, a 7 MB VESA fallback, or a Line 8506 handoff kernel fault.
* **The Solution:** We deployed a binary-patched build of **WhateverXe (v0.7.0)**.
* Specific hex patches were injected at offsets `0x3c4a` (bypassing the `N97NativeProbeBlocked` rejection check) and offsets `0x56b63`, `0xa2e1c`, and `0xa3297` (fixing the CoreDisplay handoff fault).
* In `DeviceProperties`, we enable the framebuffer patch with stolen memory overrides (`framebuffer-stolenmem: 0x03C00000`).

### 2. Conquering the ASUS `ASUP1200` Precision Trackpad
ASUS Vivobook laptops implement their touchpad as `Device (ETPD)` under the ACPI path `_SB.PC00.I2C1`. Making it communicate with `VoodooI2C` required solving 4 simultaneous challenges:
1. **DSDT GPIO Hiding Patched:** In ASUS's factory DSDT, the `GPI0` controller checks a BIOS NVS variable `GPHD`. If Windows 11 Modern Standby is detected, `GPHD == 1`, causing `GPI0._HID` to return generic `PNP0C02` with status `0x08` (disabled). We patched `DSDT.aml` so that `GPI0._HID` unconditionally returns `"INTC1055"` and `_STA` unconditionally returns `0x0F` (Present & Enabled).
2. **Apple LPSS Conflict Blocked:** macOS ships with native drivers `AppleIntelLpssI2C` and `AppleIntelLpssI2CController`. These native drivers latch onto the Alder Lake I2C controller (`00:15.1` / `51E9`) and reject third-party connections. We added explicit kernel blocks in `config.plist` under `Kernel -> Block` with `Strategy: Disable` to prevent Apple's drivers from stealing the bus.
3. **I2C Controller Matching:** Injected `0x51e98086` explicitly into `VoodooI2CPCIAlderLakeController`'s `IOPCIMatch`.
4. **Strict Kext Load Order:** Enforced Dortania's strict dependency order:
   `VoodooI2CServices` $\rightarrow$ `VoodooGPIO` $\rightarrow$ `VoodooInput` $\rightarrow$ `VoodooI2C` $\rightarrow$ `VoodooI2CHID`.

---

## ⚙️ BIOS Settings

Before booting the macOS installer or OpenCore USB, reboot your ASUS Vivobook, press **F2** repeatedly to enter BIOS setup, and set the following:

### Disable ❌
* **Fast Boot** (`Advanced` or `Boot` tab)
* **Secure Boot** (`Security` tab $\rightarrow$ `Secure Boot` $\rightarrow$ `Disabled`)
* **Intel VMD Technology / Intel RST** (Must be set to `AHCI` mode if option is present)
* **Wake on LAN / Network Stack**

### Enable ✅
* **VT-x (Virtualization Technology)**
* **Intel AES-NI**
* **XHCI Hand-off** (Under `Advanced` $\rightarrow$ `USB Configuration`)
* **SATA / NVMe Operation Mode:** `AHCI`

Save changes and exit (**F10**).

---

## 🚀 Quick Setup & Installation Guide

### Step 1: Prepare Your macOS Installer USB
1. Create a bootable macOS USB (macOS 14 Sonoma, 15 Sequoia, or 26 Tahoe) using Apple's official `createinstallmedia` tool or the Dortania guide.
2. Mount the **EFI partition** of your USB drive using MountEFI or ProperTree.
3. Copy the `EFI` folder from this repository directly into the root of your USB's EFI partition.

### Step 2: Generate Your Personal SMBIOS (CRUCIAL!)
For privacy, security, and to avoid Apple ID blacklisting, **all serial numbers in this repository are replaced with placeholders**.

> [!WARNING]
> Do NOT boot without generating your own SMBIOS! Follow our quick guide:
> **[Read the Step-by-Step SMBIOS Generation Guide](Utilities/generate_smbios.md)**
> (Takes less than 2 minutes using GenSMBIOS for model `MacBookPro16,2`).

### Step 3: Boot and Install
1. Insert the USB into the USB 3.0 port of your Vivobook.
2. Power on and press **Esc** repeatedly to open the ASUS Boot Selection Menu.
3. Select your USB drive (UEFI).
4. At the OpenCore Boot Picker:
   * **First-time boot:** Press **Spacebar** to reveal tools and select **Reset NVRAM**.
   * Then select **Install macOS** (or your macOS drive).
5. Follow the macOS installer prompts to format your internal SSD partition as **APFS** (GUID Partition Map) and proceed with the installation.

---

## 🛠️ Post-Installation Utilities & Tips

We have bundled helpful post-install scripts inside the [`Utilities`](Utilities/) folder:

### 1. iPhone USB Tethering Drop Fix
If your iPhone personal hotspot connection ever stalls or drops when your phone screen turns off, simply run:
```bash
chmod +x Utilities/fix_tethering.sh
./Utilities/fix_tethering.sh
```
*This cleanly cycles `usbmuxd` and restarts the network interface without requiring a computer restart.*

### 2. Optimal Power & Sleep Management
To prevent macOS from prematurely suspending USB ports:
```bash
chmod +x Utilities/optimize_power.sh
./Utilities/optimize_power.sh
```

---

## 📂 Repository File Structure

```text
├── EFI/
│   ├── BOOT/
│   │   └── BOOTx64.efi                 # OpenCore Bootloader Binary
│   └── OC/
│       ├── ACPI/                       # Compiled Hotpatches & Patched DSDT
│       │   ├── DSDT.aml                # Patched DSDT (GPI0 INTC1055, SSCN/FMCN timing)
│       │   ├── SSDT-ALS0.aml           # Ambient Light Sensor Dummy
│       │   ├── SSDT-EC.aml             # Embedded Controller Hotpatch
│       │   ├── SSDT-PLUG-ALT.aml       # Alder Lake CPU Power Management
│       │   ├── SSDT-PNLF.aml           # Native Backlight & Brightness Slider
│       │   ├── SSDT-RMNE.aml           # NullEthernet Fake en0 for Mac App Store
│       │   ├── SSDT-USBX.aml           # USB Power Delivery Properties
│       │   └── SSDT-XOSI.aml           # Windows 11 ACPI OS Simulation
│       ├── Kexts/                      # Kernel Extensions
│       │   ├── Lilu.kext               # Base Kernel Patcher
│       │   ├── WhateverXe.kext         # Patched Iris Xe Metal Graphics Driver
│       │   ├── VirtualSMC.kext         # SMC Emulator
│       │   ├── AsusSMC.kext            # ASUS Laptop Fn Keys & Fan Controls
│       │   ├── BrightnessKeys.kext     # Native Brightness Hotkeys
│       │   ├── CpuTopologyRebuild.kext # Alder Lake 2P+8E Hybrid Core Manager
│       │   ├── CpuTscSync.kext         # TSC Sync Across All Cores
│       │   ├── NVMeFix.kext            # NVMe Power Management
│       │   ├── NullEthernet.kext       # iCloud / App Store en0 Support
│       │   ├── SMCBatteryManager.kext  # Battery State Engine
│       │   ├── USBToolBox.kext         # USB Bus Controller
│       │   ├── UTBDefault.kext         # USB Port Map
│       │   ├── VoodooI2C.kext          # I2C Serial Bus Engine (Patched Alder Lake)
│       │   ├── VoodooI2CHID.kext       # Precision Touchpad Driver
│       │   └── VoodooPS2Controller.kext# PS/2 Keyboard Driver
│       ├── Drivers/                    # UEFI Drivers (OpenRuntime, HfsPlus, ResetNvram)
│       ├── Resources/                  # High-Resolution Audio/Graphic Assets
│       └── config.plist                # Fully Validated OpenCore 1.0.8 Configuration
├── Screenshots/                        # Verified Operation Proof Images
├── Utilities/                          # Helpful Helper Scripts
│   ├── fix_tethering.sh                # USB Tethering Recovery Script
│   ├── optimize_power.sh               # Sleep & Power Config Script
│   └── generate_smbios.md              # SMBIOS Generator Walkthrough
└── README.md                           # Master Documentation
```

---

## ❤️ Credits & Acknowledgements

This EFI is made possible by the incredible work of the Hackintosh open-source community:
* **[Acidanthera](https://github.com/acidanthera)** — for OpenCorePkg, Lilu, VirtualSMC, VoodooPS2, and AppleALC.
* **[WhateverXe Team](https://github.com/b00t0x/WhateverXe)** — for pioneering Iris Xe graphics support on macOS.
* **[Alexandred](https://github.com/alexandred)** & **[CoolStar](https://github.com/coolstar)** — for the outstanding VoodooI2C and VoodooGPIO drivers.
* **[Dortania](https://dortania.github.io/)** — for the gold-standard OpenCore Install Guide.
* **[hieplpvip](https://github.com/hieplpvip)** — for AsusSMC.
* **[b00t0x](https://github.com/b00t0x)** — for CpuTopologyRebuild.

---

### 🌟 Star This Repository!
If this repository helped you get your ASUS Vivobook or Alder Lake laptop running macOS with Metal 2 graphics acceleration, please leave a **Star ⭐** to help others find this guide!

