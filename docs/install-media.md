# Install media (HDD partition preferred)

Booting Setup from an internal partition is usually **faster** than a USB stick (full disk bandwidth vs flash/USB overhead). This machine already has ~1.8 TB unallocated, so use that.

Download ISOs to a drive with free space (`D:` today; `C:` after the new Windows install). Keep `C:` from filling up.

| OS | Preferred | Fallback |
|---|---|---|
| Windows 11 | Temp NTFS volume + `bcdedit` | [USB from Mac](#fallback-usb-from-mac) (16 GB+ stick) |
| Ubuntu 26.04 | ISO on disk + Grub2Win | [USB from Mac](#fallback-usb-from-mac) (8 GB+ stick is enough) |

---

## Windows 11 — temp volume on the internal disk

Do this from the **current** Windows install, before the wipe.

### 1. Create the volume

Disk Management → right-click **unallocated** → **New Simple Volume**:

- Size: **20480 MB** (20 GB)
- File system: **NTFS**
- Letter: **`S:`** (any free letter is fine)

You cannot *extend* `C:` into this space while `D:` sits in between; you *can* still create a new volume in unallocated space.

### 2. Copy the installer

1. Download the [Windows 11 ISO](https://www.microsoft.com/software-download/windows11) to `D:` (or another roomy drive).
2. Double-click the ISO to mount it.
3. Copy **all** files from the mounted ISO into `S:\`.

### 3. Add a boot menu entry

Use **Admin Command Prompt** (`cmd.exe`), not PowerShell. In PowerShell, `{...}` is treated as a script block and breaks `bcdedit`.

**Check the files exist** (adjust `S:` if your letter differs):

```bat
dir S:\sources\boot.wim
dir S:\sources\boot.sdi
```

**Ramdisk options** (safe to re-run if `{ramdiskoptions}` already exists):

```bat
bcdedit /create {ramdiskoptions} /d "Ramdisk options"
bcdedit /set {ramdiskoptions} ramdisksdidevice partition=S:
bcdedit /set {ramdiskoptions} ramdisksdipath \sources\boot.sdi
```

**Create a new loader entry** (do **not** use `/copy {current}` — that copies a full Windows entry and often causes `element data type ... not recognized`):

```bat
bcdedit /create /d "Windows 11 Setup" /application osloader
```

You get a line like: `The entry was successfully created with identifier {a1b2c3d4-e5f6-7890-abcd-ef1234567890}`.

Keep the **braces**. Leave `{ramdiskoptions}` as the literal word `ramdiskoptions` — do not replace that with your GUID.

Example (use **your** identifier):

```bat
bcdedit /set {a1b2c3d4-e5f6-7890-abcd-ef1234567890} device ramdisk=[S:]\sources\boot.wim,{ramdiskoptions}
bcdedit /set {a1b2c3d4-e5f6-7890-abcd-ef1234567890} osdevice ramdisk=[S:]\sources\boot.wim,{ramdiskoptions}
bcdedit /set {a1b2c3d4-e5f6-7890-abcd-ef1234567890} path \windows\system32\boot\winload.efi
bcdedit /set {a1b2c3d4-e5f6-7890-abcd-ef1234567890} systemroot \windows
bcdedit /set {a1b2c3d4-e5f6-7890-abcd-ef1234567890} detecthal yes
bcdedit /set {a1b2c3d4-e5f6-7890-abcd-ef1234567890} winpe yes
bcdedit /displayorder {a1b2c3d4-e5f6-7890-abcd-ef1234567890} /addlast
bcdedit /timeout 10
```

If an earlier `/copy {current}` entry is broken, remove it then create a fresh one:

```bat
bcdedit /delete {paste-old-guid-here} /cleanup
```

Verify:

```bat
bcdedit /enum all
```

You should see **Windows 11 Setup** with `device` / `osdevice` pointing at `ramdisk=[S:]\sources\boot.wim,...`, and a **Ramdisk options** section with `partition=S:`.
### 4. Install

Reboot → choose **Windows 11 Setup**.

In the partition screen: delete the old `C:`, `D:`, `S:`, and any other partitions on the 2 TB disk. Create **one** 500 GB partition for Windows; leave the rest unallocated. Setup is already in RAM, so deleting `S:` here is expected.

Continue with [playbook.md](playbook.md) (OOBE → WinUtil → Ubuntu).

---

## Ubuntu 26.04 — ISO on disk after Windows is installed

After the new Windows install you have a large `C:` and ~1.4 TB free. Put the Ubuntu ISO on disk and boot it with [Grub2Win](https://sourceforge.net/projects/grub2win/).

### 1. Stage the ISO

Either:

- Create volume **`T:`** (~8 GB, NTFS) in the unallocated space and copy `ubuntu-26.04*-desktop-amd64.iso` to `T:\ubuntu.iso`, or
- Copy the ISO to `C:\ISO\ubuntu.iso` (simple; uses Windows space only temporarily).

### 2. Boot the ISO with Grub2Win

1. Install Grub2Win on Windows.
2. Add a new Ubuntu entry whose configuration boots the ISO, for example (adjust disk/partition and path):

```grub
insmod part_gpt
insmod ntfs
insmod loopback
set root=(hd0,gptX)
loopback loop /ISO/ubuntu.iso
linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=/ISO/ubuntu.iso quiet splash ---
initrd (loop)/casper/initrd
```

Use Grub2Win’s partition picker for `root=` / the ISO path so they match where you put the file (`T:\ubuntu.iso` → path `/ubuntu.iso` on that partition).

3. Reboot into Grub2Win → Ubuntu live session → install into the remaining free space with **LUKS**, as in [playbook.md](playbook.md).
4. Delete `T:` (or `C:\ISO`) afterward if you created them only for this.

---

## Fallback: USB from Mac

Use this only if you cannot use an internal volume (no free/unallocated space, or you prefer a stick).

**Windows needs a 16 GB+ stick.** Ubuntu fits on 8 GB+.

### Windows 11 USB

```bash
brew install wimlib

diskutil list
# Example USB: disk5 — wrong disk = data loss.

diskutil eraseDisk MS-DOS WIN11 GPT /dev/disk5

hdiutil attach -mountpoint /Volumes/Win11ISO ~/Downloads/Win11_*.iso

rsync -avh --progress \
  --exclude='sources/install.wim' \
  --exclude='sources/install.esd' \
  /Volumes/Win11ISO/ /Volumes/WIN11/

wimlib-imagex split \
  /Volumes/Win11ISO/sources/install.wim \
  /Volumes/WIN11/sources/install.swm \
  3800

diskutil eject /Volumes/WIN11
hdiutil detach /Volumes/Win11ISO
```

ThinkPad: **F12** → UEFI USB → Windows Setup.

### Ubuntu 26.04 USB

```bash
diskutil list
# Example USB: disk6

diskutil unmountDisk /dev/disk6
sudo dd if=~/Downloads/ubuntu-26.04*-desktop-amd64.iso of=/dev/rdisk6 bs=4m status=progress
diskutil eject /dev/disk6
```

ThinkPad: **F12** → UEFI USB → Ubuntu live session.
