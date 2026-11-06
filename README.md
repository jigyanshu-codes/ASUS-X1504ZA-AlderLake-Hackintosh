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

## Screenshots & System Verification

| System Overview & Specs | Iris Xe Metal 2 Graphics Acceleration |
| :---: | :---: |
| ![System Overview](Screenshots/01_System_Overview.png) | ![Metal 2 QE/CI](Screenshots/02_GPU_Metal_Acceleration.png) |

| Peripherals & Storage | Full PCIe Device Tree |
| :---: | :---: |
| ![Peripherals Overview](Screenshots/03_Peripherals_Overview.png) | ![PCIe Tree](Screenshots/04_PCIe_Devices.png) |

---

## Hardware Specifications

| Component | Hardware Details | Status | Notes |
| :--- | :--- | :---: | :--- |
| **Model** | ASUS Vivobook 15 `X1504ZA` / `Vivobook_ASUSLaptop X1504ZA_X1504ZA` | `Supported` | Motherboard ID: `X1504ZA` |
| **Processor** | Intel Core i5-1235U (10 Cores: 2P + 8E, 12 Threads, up to 4.40 GHz) | `Working` | Managed via `CpuTopologyRebuild` + `CpuTscSync` |
| **Integrated GPU** | Intel Iris Xe Graphics GT2 (`0x46A8` / Alder Lake-UP3 GT2) | `Working` | 1536 MB VRAM, Metal 2, Full QE/CI acceleration |
| **RAM** | 20 GB DDR4 3200 MHz (4 GB Onboard + 16 GB SO-DIMM) | `Working` | Dual-Channel enabled |
| **Storage** | 512 GB Samsung PM9B1 NVMe SSD (`MZVL4512HBLU-00B00`) | `Working` | Managed via `NVMeFix.kext` |
| **Display** | 15.6" Full HD (1920x1080) 60Hz 16:9 Slim-Bezel Display | `Working` | Native brightness slider in Control Center |
| **Trackpad** | ASUS Precision Touchpad `ASUP1200` (`ACPI\VEN_ASUP&DEV_1200` on I2C1 `00:15.1`) | `Partial` | Smooth cursor & clicks in polling mode (`-vi2c-force-polling`) |
| **Keyboard** | ASUS I8042 PS/2 Keyboard with Brightness/Fn Keys | `Working` | Managed via `VoodooPS2Controller` + `BrightnessKeys` |
| **Audio** | Realtek ALC256 via Intel Smart Sound Technology (`8086:51C8`) | `Limitation` | Intel cDSP hardware limitation; USB/DAC audio works out of the box |
| **Wi-Fi** | MediaTek Wi-Fi 6 MT7902 M.2 PCIe Card | `Unsupported` | Hardware limitation: No macOS driver exists in the ecosystem |
| **Bluetooth** | MediaTek Bluetooth Adapter (USB `0x13d3:0x3568`) | `Detected` | Detected; external dongle recommended for full AirDrop support |
| **Webcam** | USB2.0 HD UVC WebCam (`0x04f2:0xb797`) | `Working` | Works natively out of the box |
| **Ports** | 1x USB-C 3.2 Gen 1, 2x USB-A 3.2 Gen 1, 1x USB-A 2.0, 1x HDMI 1.4 | `Working` | Custom mapped via `UTBDefault.kext` |
| **Battery / Power** | 3-Cell 42Wh Lithium-ion Battery with 65W AC Adapter | `Working` | Accurate percentage and charging state via `AsusSMC` |

---

## Feature Status & Hardware Support Matrix

### Verified Operational Features
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
  * Smooth cursor tracking, left-click, right-click, and mechanical physical click working cleanly using customized `VoodooI2C` and `VoodooI2CHID` in polling mode.
* **Keyboard & Special Keys:**
  * Built-in keyboard operates with zero key drops or delays.
  * Brightness keys, volume keys, and media controls respond natively.
* **Power Management & Thermal Regulation:**
  * Hybrid 2 Performance + 8 Efficiency cores managed efficiently via `CpuTopologyRebuild.kext`.
  * Dynamic clock scaling and native C-states configured via `SSDT-PLUG-ALT.aml`.
  * Fan curves and battery readouts accurately tracked via `VirtualSMC.kext` and `AsusSMC.kext`.
* **High-Speed Storage:**
  * Samsung PM9B1 NVMe SSD runs with full TRIM support and APFS compatibility via `NVMeFix.kext`.
* **Native Apple Services (iCloud, App Store, iMessage):**
  * Built-in dummy Ethernet interface (`SSDT-RMNE.aml` + `NullEthernet.kext`) provides `en0` with `Built-In` flag enabled, allowing full Apple ID login, App Store downloads, and iCloud synchronization.

---

### Work In Progress & Known Hardware Limitations

#### 1. Audio: Realtek ALC256 via Intel Smart Sound Technology (`8086:51C8`)
* **The Root Cause:**
  Unlike older Intel generations where audio codecs are wired to a standard legacy Intel HD Audio controller (`HDEF`), 12th Gen Alder Lake routes the Realtek ALC256 codec strictly through the proprietary **Intel Smart Sound Technology (SST) cDSP** (`PCI\VEN_8086&DEV_51C8`).
* **Why AppleALC Fails Silently:**
  `AppleALC.kext` expects standard HD Audio bus commands (`HDAController`). Because the SST firmware blocks direct HDA register writes without proprietary Intel IPC blobs, AppleALC probe loops time out (`AppleHDAController::probe failed`).
* **Why HDAUniversal Breaks Graphics:**
  Third-party drivers like `HDAUniversal.kext` hook the shared `8086:51C8` PCI controller, conflicting with the Iris Xe display audio/power pipeline. This trips the WhateverXe handoff check and throws macOS into unaccelerated 7 MB VESA mode.
* **The Instant, Recommended Workaround:**
  * **USB-C / USB-A to 3.5mm DAC Adapter:** Plugging in any standard USB audio dongle or Apple's USB-C Headphone Adapter works **instantly out of the box** with macOS native `AppleUSBAudio`! Both crystal-clear stereo audio and microphone input work flawlessly.
  * **Bluetooth Audio:** Connecting Bluetooth speakers or headphones provides high-quality wireless sound.

#### 2. Wi-Fi: MediaTek MT7902 M.2 Card
* **The Limitation:**
  The factory Wi-Fi card in this laptop is a **MediaTek MT7902**.
* **Driver Ecosystem:**
  The open-source Hackintosh community currently has drivers for Intel Wi-Fi (`AirportItlwm`) and select Broadcom cards (`OpenCore-Legacy-Patcher`), but **no macOS kernel driver exists for the MediaTek MT7902 chipset**.
* **Clean Solutions:**
  * **Instant Solution (Zero Cost):** Plug in your iPhone or Android phone via USB cable and enable **Personal Hotspot (USB Tethering)**. macOS recognizes it natively as a 1000 Mbps high-speed network interface (`en1`/`en2`) with zero configuration required!
  * **Hardware Upgrade (\$15-20):** Replace the M.2 2230 Wi-Fi card with an **Intel AX200 / AX201 / AX210** (which works with `AirportItlwm` for native macOS Wi-Fi) or a Broadcom **BCM94360NG** for native AirDrop and Continuity.

---

## Technical Architecture & Driver Patches

### 1. The Alder Lake-U Iris Xe Breakthrough
Alder Lake-U integrated graphics (`8086:46A8`) previously failed to initialize on macOS due to a strict internal port handoff requirement in WhateverXe:
1. **eDP Boot Handoff Bypass (Offset `0x56b63`):**
   * WhateverXe originally required the internal laptop screen (DDI 0) to report software mode `1`.
   * On 12th Gen Alder Lake-U laptops, firmware initialization leaves the panel in mode `0`.
   * **The Fix:** Binary instruction patched from `jb 0x56b77` (`72 12`) to `jb 0x56b7b` (`72 16`), cleanly accepting both mode 0 and mode 1 and eliminating the line 8506 handoff fault.
2. **Panel Timing Calibration (Offset `0xa2e1c`):**
   * Patched `jne 0xa2d85` (`0f 85`) to `ja 0xa2d85` (`0f 87`), allowing native panel timing calculation for internal laptop panels.
3. **Internal Backlight PWM Target (Offset `0xa3297`):**
   * Patched `jne 0xa3250` (`75 b7`) to `ja 0xa3250` (`77 b7`), unlocking hardware backlight PWM scaling.
4. **Strict Kext Load Order:**
   * OpenCore strictly loads in Dortania dependency sequence:
     `Lilu.kext` → `AMFIPass.kext` → `WhateverXe.kext` → `VirtualSMC.kext`.

---

## Post-Installation: Intel Iris Xe 1536MB Acceleration Restorer

If your system ever boots into unaccelerated **"Intel Iris Xe Graphics 7 MB"** (VESA mode), you can restore full 1536 MB Metal 2 acceleration in under 60 seconds using our dedicated automated tool.

### Running the Acceleration Restorer
Open **Terminal** in macOS and execute:
```bash
sudo ./Utilities/activate_acceleration.sh
```
*(Or simply double-click [`Utilities/Restore_1536MB_Acceleration.command`](Utilities/Restore_1536MB_Acceleration.command) in Finder).*

### What the Script Automates:
1. **Conflict Purge:** Removes conflicting audio kexts (`HDAUniversal.kext`, `VoodooHDA.kext`) that cause display engine arbitration panics.
2. **Staging Cache Cleanup:** Executes `kmutil clear-staging` to prevent macOS from loading quarantined or orphaned drivers.
3. **Driver Deployment:** Checks for `WhateverXe-Graphics-0.4.0.pkg`, automatically downloading it from GitHub releases if missing, and validates `/Library/Extensions/AppleIntelTGL*` and `/Library/GPUBundles`.
4. **Permission & Quarantine Sanitization:** Enforces `root:wheel 755` permissions and strips quarantine attributes (`xattr -cr`).
5. **Metal Optimization:** Sets `AllowOnePassMetalScaling:Enabled = false` in `CoreMedia.plist` to prevent video scaling glitches.
6. **AuxKC Direct Compilation:** Builds `/Library/KernelCollections/AuxiliaryKernelExtensions.kc` using `kmutil create -n aux` with `--allow-missing-kdk` and `--no-authentication`.

> [!CAUTION]
> ### CRITICAL: Avoid The "System Settings Trap"
> When the script completes, macOS may display a notification saying:
> *"System Extension Blocked"* or prompt you to approve extensions in **System Settings -> Privacy & Security**.
>
> 1. **DO NOT OPEN SYSTEM SETTINGS!**
> 2. **DO NOT CLICK 'ALLOW' OR 'RESTART' INSIDE SYSTEM SETTINGS!**
>
> **Why?**
> Clicking "Restart" inside System Settings triggers macOS's native `syspolicyd` daemon to run Apple's internal `kmutil rebuild` **without** `--allow-missing-kdk`. This silently purges the unsigned Iris Xe graphics drivers from the kernel collection and throws macOS right back into the unaccelerated 7 MB VESA fallback!
>
> **The Safe Reboot Procedure:**
> 1. Press **[Enter]** directly inside the Terminal window to reboot.
> 2. In the OpenCore Boot Picker, press **Spacebar** and select **Reset NVRAM** once.
> 3. Boot into macOS, and enjoy full **Intel Iris Xe 1536 MB Metal 2 acceleration**!

---

## Installation & Setup Guide

### Prerequisites
* A USB flash drive (16 GB or larger).
* macOS installer image (macOS Tahoe 26.x, macOS Sequoia 15.x, or macOS Sonoma 14.x).
* Windows 11 / Linux or an existing Mac to create the bootable drive.

### Step-by-Step Installation

#### 1. BIOS Settings
Restart your laptop and press **F2** to enter BIOS Setup. Set the following options:
* **Disable:**
  * Secure Boot (`Security` → `Secure Boot` → `Disabled`)
  * Fast Boot (`Boot` → `Fast Boot` → `Disabled`)
  * Intel VMD / RAID (`Advanced` → `VMD Configuration` → `Disabled` / AHCI mode)
* **Enable:**
  * VT-x (Intel Virtualization Technology)
  * Above 4G Decoding (if available)

#### 2. Prepare USB Installer
1. Create a standard bootable macOS USB installer using standard tools (such as `createinstallmedia` or gibMacOS).
2. Mount the **EFI partition** of your bootable USB.
3. Copy the `EFI` folder from this repository directly into the root of your USB's EFI partition.

#### 3. Generate Unique SMBIOS Data
> [!IMPORTANT]
> The `config.plist` in this repository contains sanitized placeholder serial numbers (`C02000000000`). You **MUST** generate your own unique serials before logging into Apple ID / iCloud!

Use **[GenSMBIOS](https://github.com/corpnewt/GenSMBIOS)** to generate values for **MacBookPro16,2**:
* Open your `config.plist` in **ProperTree** or **OpenCore Configurator**.
* Navigate to `PlatformInfo` → `Generic`.
* Fill in:
  * `SystemSerialNumber`
  * `MLB` (Board Serial)
  * `SystemUUID` (SmUUID)
* Save `config.plist`.

#### 4. Boot & Install
1. Insert the USB drive and power on your laptop while pressing **Esc** to enter the boot menu.
2. Select your USB drive (UEFI Partition).
3. At the OpenCore boot picker:
   * **First-time boot:** Press **Spacebar** to reveal tools and select **Reset NVRAM**.
   * Then select **Install macOS** (or your macOS target partition).
4. Follow the macOS installer prompts to format your internal SSD partition as **APFS** (GUID Partition Map) and complete the installation.

---

## Post-Installation & Troubleshooting Utilities

We have bundled helpful post-install scripts inside the [`Utilities`](Utilities/) folder:

### 1. Graphics Acceleration Restorer
Restores full 1536 MB Metal 2 acceleration if the system ever reverts to 7 MB VESA:
```bash
sudo ./Utilities/activate_acceleration.sh
```

### 2. iPhone USB Tethering Drop Fix
If your iPhone personal hotspot connection ever stalls or drops when your phone screen turns off, simply run:
```bash
chmod +x Utilities/fix_tethering.sh
./Utilities/fix_tethering.sh
```
*This cleanly cycles `usbmuxd` and restarts the network interface without requiring a computer restart.*

### 3. Optimal Power & Sleep Management
To prevent macOS from prematurely suspending USB ports:
```bash
chmod +x Utilities/optimize_power.sh
./Utilities/optimize_power.sh
```

---

## Repository Structure

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
│       │   ├── AMFIPass.kext           # AMFI Signature Enabler
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
│   ├── activate_acceleration.sh        # Dedicated 1536MB Acceleration Restorer
│   ├── Restore_1536MB_Acceleration.command # Clickable macOS Automation Tool
│   ├── fix_tethering.sh                # USB Tethering Recovery Script
│   ├── optimize_power.sh               # Sleep & Power Config Script
│   └── generate_smbios.md              # SMBIOS Generator Walkthrough
└── README.md                           # Master Documentation
```

---

## Credits & Acknowledgements

This EFI is made possible by the incredible work of the Hackintosh open-source community:
* **[Acidanthera](https://github.com/acidanthera)** — for OpenCorePkg, Lilu, VirtualSMC, VoodooPS2, and AppleALC.
* **[WhateverXe Team](https://github.com/b00t0x/WhateverXe)** — for pioneering Iris Xe graphics support on macOS.
* **[Alexandred](https://github.com/alexandred)** & **[CoolStar](https://github.com/coolstar)** — for the outstanding VoodooI2C and VoodooGPIO drivers.
* **[Dortania](https://dortania.github.io/)** — for the gold-standard OpenCore Install Guide.
* **[hieplpvip](https://github.com/hieplpvip)** — for AsusSMC.
* **[b00t0x](https://github.com/b00t0x)** — for CpuTopologyRebuild.
* **[Belugaa_01](https://www.reddit.com/user/Belugaa_01/)** — for initial Alder Lake-U offset discovery.

---

### Community & Support
If this repository helped you get your ASUS Vivobook or Alder Lake laptop running macOS with Metal 2 graphics acceleration, please leave a Star on GitHub to help others find this guide!
