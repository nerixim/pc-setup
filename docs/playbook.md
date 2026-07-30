# End-to-end playbook — ThinkPad P52s

Follow this once on the machine. Details live in [dual-boot.md](dual-boot.md) and [thinkpad-p52s.md](thinkpad-p52s.md).

## Before you wipe

- [ ] Copy anything you still need off `C:` / `D:` (and from Linux if you can mount it).
- [ ] Note the LUKS passphrase you will choose (password manager / written offline).
- [ ] On another machine (this Mac is fine), download:
  - [Windows 11 ISO](https://www.microsoft.com/software-download/windows11)
  - [Ubuntu 26.04 LTS Desktop ISO](https://ubuntu.com/download/desktop)
- [ ] Create installer USBs — see **[usb-from-mac.md](usb-from-mac.md)**.
  - **Do not `dd` a Windows ISO** on macOS (it will not boot). Use wimlib + FAT32, or Rufus on the existing Windows install.
  - Ubuntu ISOs **can** be written with `dd`.
- [ ] Optional: clone this repo onto a USB stick so WinUtil config and docs are offline.

## 1. Firmware

- [ ] Update Lenovo BIOS if very old ([Lenovo Support — P52s](https://pcsupport.lenovo.com/)).
- [ ] Enter Setup (`F1` at Lenovo logo).
- [ ] Storage controller: **AHCI** (not Intel RST / RAID).
- [ ] Disable firmware **Fast Boot**.
- [ ] Leave **Secure Boot** enabled for now; turn off only if an installer or driver fails.
- [ ] Boot order: USB first for installs.

## 2. Windows 11 (500 GB only)

- [ ] Boot the Windows USB.
- [ ] At partitioning: **Delete all existing partitions** on the 2 TB disk.
- [ ] Create a new partition of **500 GB** (≈ 512000 MB). Install Windows there.
- [ ] Leave the remaining space **unallocated** — do not create a second Windows volume.
- [ ] Finish OOBE with a **local account** if possible (WinUtil / Shift+F10 tricks also work).
- [ ] Connect network; install Lenovo System Update or grab chipset + NVIDIA drivers from Lenovo / NVIDIA.
- [ ] **Disable Fast Startup**: Control Panel → Power Options → Choose what the power buttons do → uncheck Fast startup. Or run WinUtil after.

## 3. WinUtil (debloat + apps)

Admin PowerShell:

```powershell
# Apply this repo's config (copy winutil-config.json onto the machine first)
& ([ScriptBlock]::Create((irm "https://christitus.com/win"))) -Config "C:\path\to\pc-setup\windows\winutil-config.json" -Run
```

If the config path is awkward on a fresh install, run the GUI once:

```powershell
irm "https://christitus.com/win" | iex
```

Then import `windows/winutil-config.json` (gear → Import), run Install + Tweaks, and re-export if you change anything.

Checklist:

- [ ] Standard-style tweaks applied (telemetry / consumer noise reduced).
- [ ] Steam, Firefox, 7-Zip, PowerToys installed.
- [ ] Fast Startup off.
- [ ] Steam signs in; download a small game later to verify GPU drivers.
- [ ] Shut down fully (not hibernate) before the Ubuntu install.

## 4. Ubuntu 26.04 LTS (~1.4 TB, LUKS)

- [ ] Boot the Ubuntu USB; install.
- [ ] Choose **Install alongside Windows** *or* manual partitioning into the unallocated space.
- [ ] Enable **disk encryption (LUKS)** for the Ubuntu system.
- [ ] Let the installer install **GRUB** to the disk EFI (default).
- [ ] After reboot: GRUB should list Ubuntu and Windows Boot Manager.

If only Windows boots: BIOS boot order → Ubuntu / GRUB first. See [dual-boot.md](dual-boot.md).

## 5. Ubuntu bootstrap

```bash
sudo apt update && sudo apt install -y git make
git clone git@github.com:nerixim/pc-setup.git ~/pc-setup   # or HTTPS
cd ~/pc-setup
make apt zsh git mise docker cli
```

Then:

- [ ] Log out/in (or reboot) so the `docker` group applies.
- [ ] `mise install` if runtimes were not installed by the mise target.
- [ ] Optional: Additional Drivers → proprietary NVIDIA if you want GPU compute on Linux.

## 6. Verify

- [ ] Reboot → Ubuntu is default; Windows entry works.
- [ ] Windows: Steam launches; a game runs.
- [ ] Ubuntu: `git`, `mise`, `docker` work; shell feels usable.

## If something breaks

| Problem | Fix |
|---|---|
| No GRUB | BIOS: Ubuntu first; or boot-repair from live USB |
| Windows missing from GRUB | `sudo update-grub` from Ubuntu |
| Ubuntu won't unlock | LUKS passphrase; live USB + cryptsetup if recovering |
| Reinstall one OS | Leave the other partition alone; restore from this repo |
