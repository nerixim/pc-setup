# Create installer USBs from a Mac

Need two sticks (or redo one twice): **16 GB+** for Windows, any ~8 GB+ for Ubuntu.

## Windows 11

```bash
brew install wimlib

diskutil list
# Find your USB identifier (example: disk5). Wrong disk = data loss.

diskutil eraseDisk MS-DOS WIN11 GPT /dev/disk5

hdiutil attach -mountpoint /Volumes/Win11ISO ~/Downloads/Win11_25H2_EnglishInternational_x64_v2.iso

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

On the ThinkPad: insert USB → power on → **F12** → choose the **UEFI** USB entry. You should see Windows Setup (blue screens), not the old desktop.

## Ubuntu 26.04

```bash
diskutil list
# Find your USB identifier (example: disk6).

diskutil unmountDisk /dev/disk6
sudo dd if=~/Downloads/ubuntu-26.04.1-desktop-amd64.iso of=/dev/rdisk6 bs=4m status=progress
diskutil eject /dev/disk6
```

Adjust the ISO filename to match what you downloaded. Boot with **F12** → UEFI USB, same as Windows.
