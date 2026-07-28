# PC setup design — ThinkPad P52s dual boot

Date: 2026-07-29  
Machine: Lenovo ThinkPad P52s (2 TB SSD)  
Sibling to: [mac-setup](https://github.com/nerixim/mac-setup)

## Goals

- **Windows 11**: thin gaming OS for titles that do not run on Mac (e.g. Fallout).
- **Ubuntu 26.04 LTS**: daily driver for development and experiments.
- Full wipe of the existing broken dual-boot layout; automated, repeatable setup.
- Minimal PowerShell; Windows cleanup via Chris Titus WinUtil + an exported config.
- Linux bootstrap mirrors `mac-setup` (Makefile + small scripts).

## Role split

| OS | Responsibility |
|---|---|
| Windows | Games only (Steam + essentials). No full dev stack. |
| Ubuntu | Shell, editors, mise, Docker, experiments. |

Switching costs a reboot (~1–2 minutes) via GRUB. Ubuntu is the default boot entry.

## Disk layout (GPT, UEFI)

Full wipe. Target layout:

| Partition | Size | Notes |
|---|---|---|
| EFI | ~1 GB | Shared; GRUB manages both OSes |
| Windows (NTFS) | 500 GB | OS + Steam library |
| Ubuntu (ext4, LUKS) | ~1.4 TB | Remainder of the disk |

No shared data partition in v1. Add later by shrinking Ubuntu if needed.

**Encryption:** LUKS on Ubuntu only. Windows stays unencrypted to keep gaming and recovery simple.

## Install order

1. Update Lenovo BIOS if outdated.
2. Firmware: storage **AHCI** (not Intel RST/RAID); disable firmware Fast Boot. Try Secure Boot on; disable only if install or drivers fail.
3. Wipe the disk. Install **Windows 11** into a **500 GB** partition only; leave the rest unallocated.
4. Disable Windows Fast Startup. Run **WinUtil**, import `windows/winutil-config.json`, apply tweaks and apps.
5. Install **Ubuntu 26.04 LTS** into free space with LUKS. Let the installer install GRUB for both OSes.
6. On Ubuntu: clone this repo → run Makefile bootstrap targets.

## Windows approach

- Stock Microsoft ISO (not a random custom image), then WinUtil.
- WinUtil covers debloat, privacy/performance tweaks, Winget installs, update policy, and config export/import.
- Preset tone: **Standard** tweaks — aggressive enough to remove consumer bloat, not so aggressive that Steam/anti-cheat breaks.
- Target Winget apps: Steam, a browser, 7-Zip, optional PowerToys.
- Out of scope on Windows: VS Code, Docker, WSL, full Git toolchain.

Repo artifacts:

- `windows/README.md` — step-by-step install
- `windows/winutil-config.json` — exported preset (filled in after first successful run)
- `windows/apps.md` — notes beyond what WinUtil stores

## Linux approach

Makefile-shaped bootstrap, same idea as `mac-setup`:

```text
make apt zsh git mise docker cli
```

| Target | Role |
|---|---|
| `apt` | Base packages and CLI favourites |
| `zsh` | Shell setup |
| `git` | gitconfig / aliases from `config/` |
| `mise` | Language runtimes (align versions with Mac where sensible) |
| `docker` | Docker Engine + user group |
| `cli` | Optional extras |

Prefer latest stable packages at bootstrap time. Re-run targets after a reinstall.

## Repo layout

```text
pc-setup/
├── README.md
├── Makefile
├── config/
├── scripts/
├── windows/
│   ├── README.md
│   ├── winutil-config.json
│   └── apps.md
└── docs/
    ├── plans/2026-07-29-pc-setup-design.md
    ├── dual-boot.md
    ├── thinkpad-p52s.md
    └── playbook.md
```

## ThinkPad P52s notes

- Confirm AHCI **before** installing Windows (clean install avoids RST→AHCI repair dances).
- Hybrid Intel + NVIDIA Optimus is typical. Windows needs Lenovo/NVIDIA drivers for games. On Ubuntu, use Additional Drivers for the proprietary NVIDIA package if needed; hybrid is fine if Linux is not for gaming.
- If GRUB does not appear: set Ubuntu first in the BIOS boot order, or use boot-repair from a live USB.

## Recovery

- Reinstall Windows without touching the LUKS Ubuntu partition (and the reverse) when one side breaks.
- Keep the LUKS passphrase somewhere durable.
- Rebuild either OS from this repo + the WinUtil config.

## Success criteria

- GRUB lists both OSes; Ubuntu boots by default.
- Steam launches at least one known game on Windows.
- Linux `make` targets leave a usable developer environment.

## Implementation order (next)

1. End-to-end playbook (`docs/playbook.md`) and P52s / dual-boot docs.
2. Windows README + apps list; placeholder for WinUtil config.
3. Linux Makefile and scripts (`apt`, `zsh`, `git`, `mise`, `docker`, `cli`).
4. Root README with the short path from wiped disk to done.
