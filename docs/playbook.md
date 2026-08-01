# End-to-end playbook — ThinkPad P52s

Follow this once on the machine. Details: [install-media.md](install-media.md), [dual-boot.md](dual-boot.md), [thinkpad-p52s.md](thinkpad-p52s.md).

## Before you wipe

- [ ] Copy anything you still need off `C:` / `D:`.
- [ ] Note the LUKS passphrase you will choose (password manager / written offline).
- [ ] Download the [Windows 11 ISO](https://www.microsoft.com/software-download/windows11) to a roomy drive (`D:`).
- [ ] Prepare Windows Setup on a **temp internal volume** — [install-media.md](install-media.md) (preferred). USB is only a fallback.
- [ ] Optional: copy this repo onto a stick or `D:` so WinUtil config is offline.

## 1. Firmware

- [ ] Update Lenovo BIOS if very old ([Lenovo Support — P52s](https://pcsupport.lenovo.com/)).
- [ ] Enter Setup (`F1` at Lenovo logo).
- [ ] Storage controller: **AHCI** (not Intel RST / RAID).
- [ ] Disable firmware **Fast Boot**.
- [ ] Leave **Secure Boot** enabled for now; turn off only if an installer or driver fails.

## 2. Windows 11 (500 GB only)

- [ ] Boot **Windows 11 Setup** from the temp volume (or USB fallback).
- [ ] On Disk 0: delete old OS/data partitions only — **keep** the Setup media volume until install completes.
- [ ] Create **one** 500 GB partition from unallocated; install Windows there.
- [ ] Leave the remaining space **unallocated** (plus the small Setup volume until after first boot).
- [ ] After OOBE: clean leftover partitions and old boot entries (below).
- [ ] Finish OOBE with a **local account** if possible.
- [ ] Install Lenovo / NVIDIA drivers.
- [ ] **Disable Fast Startup**: Control Panel → Power Options → Choose what the power buttons do → uncheck Fast startup.

### After first boot — partitions & old Linux/Pop!_OS leftovers

Identify disks by **size** (your ~2 TB install disk vs the small recovery disk).

**Disk Management**

1. Delete the **Setup media** volume (old `D:` / ISO copy) on the big disk — only after this Windows has booted successfully.
2. On the **small** disk: delete Recovery / OEM junk if you do not need Lenovo recovery. Or wipe the whole small disk: Admin `cmd` → `diskpart` → `list disk` → `select disk N` → `clean` → `exit`, then create one new NTFS volume if you want extra storage.
3. Leave the large **unallocated** region on the big disk for Ubuntu. Do not create a Windows volume that fills the disk.

**Old Pop!_OS / Linux boot entries (EFI)**

1. Admin `cmd`:

```bat
mountvol S: /S
dir S:\EFI
```

2. If you see folders like `Pop_OS`, `ubuntu`, `debian`, `Boot` leftovers from Linux (not `Microsoft` / `Boot` you still need):

```bat
rmdir /S /Q S:\EFI\Pop_OS
rmdir /S /Q S:\EFI\ubuntu
```

(Use the actual folder names from `dir`. Do **not** delete `S:\EFI\Microsoft`.)

3. `mountvol S: /D` when finished.

4. Firmware boot menu clutter: reboot → **F1** → Boot (or Startup) → remove stale **Pop!_OS** / **ubuntu** entries if listed. Or after Ubuntu is installed later, `efibootmgr -v` and delete old numbers.

5. Windows boot menu clutter (old “Windows 11 Setup” entries):

```bat
bcdedit /enum firmware
bcdedit /enum all
```

Delete only entries you recognize as Setup/ramdisk leftovers, e.g. `bcdedit /delete {guid} /cleanup`.

Then continue with WinUtil (§3) and Ubuntu (§4).

## 3. WinUtil (debloat + apps)

Admin PowerShell (config from this repo):

```powershell
& ([ScriptBlock]::Create((irm "https://christitus.com/win"))) -Config "C:\path\to\pc-setup\windows\winutil-config.json" -Run
```

- [ ] Tweaks applied; Steam, Firefox, 7-Zip, PowerToys installed.
- [ ] Fast Startup off.
- [ ] Full shut down before Ubuntu (not hibernate).

## 4. Ubuntu 26.04 LTS (~1.4 TB, LUKS)

- [ ] Download the [Ubuntu 26.04 LTS ISO](https://ubuntu.com/download/desktop) onto Windows (`C:\ISO\` or a small `T:` volume).
- [ ] Boot the ISO via Grub2Win — [install-media.md](install-media.md) (USB fallback if needed).
- [ ] Install into the unallocated space with **LUKS**.
- [ ] Let the installer install **GRUB** (default).
- [ ] After reboot: GRUB lists Ubuntu and Windows; Ubuntu is fine as default.

If only Windows boots: BIOS → Ubuntu / GRUB first. See [dual-boot.md](dual-boot.md).

## 5. Ubuntu bootstrap

```bash
sudo apt update && sudo apt install -y git make
git clone git@github.com:nerixim/pc-setup.git ~/pc-setup
cd ~/pc-setup
make apt zsh git mise docker cli
```

- [ ] Log out/in (or reboot) so the `docker` group applies.
- [ ] `mise install` if needed.
- [ ] Optional: Additional Drivers → proprietary NVIDIA.

## 6. Verify

- [ ] GRUB: Ubuntu default; Windows entry works.
- [ ] Windows: Steam launches.
- [ ] Ubuntu: `git`, `mise`, `docker` usable.

## If something breaks

| Problem | Fix |
|---|---|
| No GRUB | BIOS: Ubuntu first; or boot-repair from Ubuntu live media |
| Windows missing from GRUB | `sudo update-grub` from Ubuntu |
| Ubuntu won't unlock | LUKS passphrase; live session + cryptsetup if recovering |
| Reinstall one OS | Leave the other partition alone; use [install-media.md](install-media.md) again |
