# ThinkPad P52s notes

Mobile workstation, typically Intel CPU + Intel iGPU + NVIDIA Optimus dGPU, UEFI firmware.

## Firmware checklist

| Setting | Value | Why |
|---|---|---|
| Storage | **AHCI** | Ubuntu installers choke on Intel RST/RAID; set before Windows since we wipe anyway |
| Fast Boot (BIOS) | Off | USB/OS selection more reliable |
| Secure Boot | On unless blocked | Try on first; disable if needed |
| Boot mode | UEFI only | Match both OS installers |
| Graphics | Hybrid (default) | Fine for Windows gaming + Linux desktop |

Enter Setup with `F1` at the Lenovo splash. `F12` for a one-shot boot menu.

## Drivers

**Windows**

1. Lenovo Vantage or [System Update](https://pcsupport.lenovo.com/) for chipset, BIOS, trackpad, audio.
2. NVIDIA Game Ready or Studio driver if Lenovo’s package is stale — needed for older DirectX games.
3. Confirm Device Manager has no yellow bangs before relying on Steam.

**Ubuntu**

- Intel graphics usually work out of the box on 26.04.
- For NVIDIA: Software & Updates → Additional Drivers → proprietary driver (version Ubuntu recommends) → reboot.
- `nvidia-smi` should work after a successful proprietary install.
- You do **not** need a perfect NVIDIA stack on Linux if all gaming stays on Windows.

## Thermals and power

P52s can run warm under load. On Windows, Lenovo power modes + undemanding older games are usually enough. On Ubuntu, `powertop` / TLP are optional later — not part of the base bootstrap.

## Known dual-boot footguns on ThinkPads

1. Leaving RST enabled → Ubuntu installer cannot see the disk correctly.
2. Windows updates rewriting boot order → machine boots straight to Windows; fix with BIOS boot order or `efibootmgr`.
3. Fast Startup left on → weird clocks, “Windows is hibernated” mount errors if you ever mount NTFS from Linux.

## Hardware inventory (fill in when convenient)

| Item | Value |
|---|---|
| Exact model / type | P52s (20Hx / 20Hy — confirm on bottom sticker) |
| CPU | |
| RAM | |
| NVIDIA SKU | |
| Display | |
| BIOS version | |

Update this table after the wipe so future you has a baseline.
