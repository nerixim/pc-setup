# Create installer USBs from a Mac

## Why your `dd` Windows stick failed

Linux ISOs (Ubuntu) are **hybrid** images — `dd` to the whole disk produces a bootable USB.

Windows ISOs are **not**. `dd if=Win11.iso of=/dev/diskN` writes an optical-disc layout. The ThinkPad ignores it (falls through to the internal Windows), and Windows itself often shows **“incompatible partition / format?”** when you plug the stick in.

Erase-then-`dd` (as in that Qiita post) does not fix this.

Use one of the methods below. **Use a 16 GB or larger USB.** An 8 GB stick is too small for current Win11 ISOs (`install.wim` alone is ~7 GB, plus boot files).

---

## Windows 11 USB (macOS) — wimlib + FAT32

### 1. Install tool

```bash
brew install wimlib
```

### 2. Identify the USB (double-check — wrong disk = data loss)

```bash
diskutil list
```

Example: external stick is `/dev/disk5`. Use **your** disk number below.

### 3. Format GPT + FAT32

```bash
diskutil eraseDisk MS-DOS WIN11 GPT /dev/disk5
```

(`WIN11` is the volume label.)

### 4. Mount the ISO

```bash
open /Users/nk/Downloads/Win11_25H2_EnglishInternational_x64_v2.iso
```

Finder mounts something like `/Volumes/CCCOMA_X64FRE_...`. Check the exact name:

```bash
ls /Volumes
```

### 5. Copy everything except the huge `install.wim`

FAT32 cannot hold files > 4 GB; Win11’s `install.wim` is larger.

```bash
# Adjust both volume names to match `ls /Volumes`
rsync -avh --progress \
  --exclude='sources/install.wim' \
  --exclude='sources/install.esd' \
  /Volumes/CCCOMA_X64FRE_EN-GB_DV9/ /Volumes/WIN11/
```

If your ISO volume name differs, substitute it. English International is often `...EN-GB...` or similar — use whatever `ls /Volumes` shows.

### 6. Split `install.wim` onto the USB

```bash
wimlib-imagex split \
  /Volumes/CCCOMA_X64FRE_EN-GB_DV9/sources/install.wim \
  /Volumes/WIN11/sources/install.swm \
  3800
```

You should get `install.swm`, `install2.swm`, … under `/Volumes/WIN11/sources/`.

### 7. Eject cleanly

```bash
diskutil eject /Volumes/WIN11
diskutil eject /Volumes/CCCOMA_X64FRE_EN-GB_DV9   # or whatever the ISO mount is named
```

### 8. Boot on the P52s

1. Insert USB (prefer USB-A port directly on the machine).
2. Power on → tap **F12** for the boot menu (not only F1 Setup).
3. Choose the USB entry under **UEFI** (name may be the stick brand or “UEFI: USB …”).
4. If it still skips to internal Windows: F1 → put USB first, disable Fast Boot, try Secure Boot off once, retry F12.

When it works you get the Windows Setup blue screens — not your old desktop.

### Optional easier path

While the old Windows still boots on the P52s: download [Rufus](https://rufus.ie/) there, make the installer USB on that machine, then wipe. Often less fiddly than Mac tooling.

---

## Ubuntu 26.04 USB (macOS) — `dd` is fine

```bash
diskutil list                          # find USB, e.g. disk6
diskutil unmountDisk /dev/disk6
sudo dd if=~/Downloads/ubuntu-26.04*-desktop-amd64.iso of=/dev/rdisk6 bs=4m status=progress
diskutil eject /dev/disk6
```

Use `rdisk` for speed. Ubuntu hybrid ISOs boot after a plain `dd`.

---

## Quick diagnosis

| Symptom | Meaning |
|---|---|
| “Format this disk?” in Windows | Stick is not a proper Win installer layout (classic after ISO `dd`) |
| F12 → USB → still old Windows | Firmware never booted the stick (bad media or not UEFI USB entry) |
| USB missing in F12 | Try other port, GPT+FAT32 redo, disable Fast Boot |
| `dd` of Win ISO “works” then PC ignores USB | Expected — Windows ISOs are not hybrid; use wimlib method |
| Split/copy fails with no space | Stick too small — need **16 GB+** (8 GB cannot hold Win11 + FAT32 overhead) |
