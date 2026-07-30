# Dual-boot notes

## Why Windows first

UEFI dual-boot is least painful when Windows owns the first install and Ubuntu’s installer detects it and wires GRUB to both. Installing Linux first often means repairing the bootloader after Windows overwrites EFI boot order.

## Partition plan (this machine)

| Slice | Size | FS |
|---|---|---|
| EFI System Partition | ~1 GB | FAT32 (created by Windows; reused by Ubuntu) |
| Windows | 500 GB | NTFS |
| Ubuntu | ~1.4 TB | ext4 inside LUKS |

Windows setup UI: after wiping the disk, create **one** 500 GB partition and install. Leave free space alone.

Ubuntu installer:

- Prefer guided “install alongside Windows” if it offers the free space.
- Or manual: create an encrypted volume in the free space (LUKS → ext4 root; optional separate `/boot` as the installer suggests).

Do **not** format the Windows NTFS partition.

## Fast Startup and hibernation

Windows Fast Startup is a hybrid shutdown. It leaves the NTFS volume in a state that Linux should not write to, and it confuses dual-boot. Disable it on Windows before relying on GRUB or shared disks.

Hibernate on either OS across a switch is a bad idea on dual-boot. Shut down or reboot cleanly when changing OS.

## Secure Boot

Ubuntu 26.04 generally works with Secure Boot on. If the installer, third-party NVIDIA modules, or a tool complains, disable Secure Boot in firmware and continue.

## GRUB tips

```bash
# From Ubuntu — refresh OS list after Windows repairs
sudo update-grub

# See current boot entries
efibootmgr -v
```

Set Ubuntu as the first Boot Option in Lenovo BIOS if the machine skips GRUB.

**boot-repair** (from an Ubuntu live USB) can rewrite EFI entries when GRUB disappears after a Windows update.

## Reinstalling one side

- **Windows only:** boot Setup again ([install-media.md](install-media.md)) → install onto the existing 500 GB NTFS partition (format it). Do not touch the LUKS partition. Repair GRUB from an Ubuntu live session afterward if needed.
- **Ubuntu only:** boot the Ubuntu ISO the same way → use the existing Linux space; keep the Windows partition. Reinstall GRUB.

## Shared files later

v1 has no shared partition. To add one later: shrink Ubuntu in a live session, create exFAT or NTFS in the gap, mount from both OSes (with Fast Startup still off).
