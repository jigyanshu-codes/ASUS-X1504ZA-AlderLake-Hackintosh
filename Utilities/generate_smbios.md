# How to Generate Your Own SMBIOS (Required Before Booting)

For security, privacy, and Apple ID stability, the provided `config.plist` has its Serial Number, Board Serial Number (MLB), and UUID cleared to placeholder values (`C02000000000`, `00000000-...`).

Follow these simple steps before booting for the first time:

### Step 1: Download GenSMBIOS
* Download **GenSMBIOS** from the official GitHub repository: [CorpNewt/GenSMBIOS](https://github.com/corpnewt/GenSMBIOS).

### Step 2: Generate Values for `MacBookPro16,2`
1. Run `GenSMBIOS.bat` (on Windows) or `GenSMBIOS.command` (on macOS/Linux).
2. Choose Option **1** (`Install/Update MacSerial`).
3. Choose Option **3** (`Generate SMBIOS`).
4. Type `MacBookPro16,2` and press Enter.

### Step 3: Insert into `EFI/OC/config.plist`
Open `EFI/OC/config.plist` with **ProperTree** (or any text/plist editor) and navigate to `PlatformInfo -> Generic`:
* **SystemProductName**: `MacBookPro16,2` (already set)
* **SystemSerialNumber**: Paste the generated `Serial`
* **MLB**: Paste the generated `Board Serial`
* **SystemUUID**: Paste the generated `SmUUID`
* **ROM**: Your machine's Ethernet/Wi-Fi MAC address without colons (6 hex bytes, e.g. `112233445566`), or generate a random 6-byte hex in ProperTree.

Save the file, and your EFI is ready to boot!

