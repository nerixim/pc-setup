# Windows (games)

Thin Windows 11 on the **500 GB** partition. Full sequence: [../docs/playbook.md](../docs/playbook.md).

## Install reminders

1. Wipe the disk; create **only** a 500 GB partition for Windows; leave ~1.4 TB unallocated.
2. Prefer a local account for OOBE.
3. Install Lenovo + NVIDIA drivers before heavy Steam use.
4. Disable **Fast Startup** (required for dual-boot hygiene).

## WinUtil

[Chris Titus WinUtil](https://github.com/ChrisTitusTech/winutil) handles debloat, tweaks, and Winget apps.

### Apply this repo's config (preferred)

Copy `winutil-config.json` onto the machine, then in **Admin PowerShell**:

```powershell
& ([ScriptBlock]::Create((irm "https://christitus.com/win"))) -Config "C:\path\to\winutil-config.json" -Run
```

### First-time GUI

```powershell
irm "https://christitus.com/win" | iex
```

Gear → Import → select `winutil-config.json` → run Install and Tweaks. If you change selections, Export and replace the file in this repo.

### What the config aims for

- **Standard** tweak set (telemetry / consumer features / cleanup) — not the most aggressive Advanced preset, so Steam stays happier.
- Remove common Appx bloat (Copilot, Feedback Hub, Candy-style noise).
- Install: **Steam**, **Firefox**, **7-Zip**, **PowerToys**.

Fallback without the JSON: `-Preset Standard`, then tick those four apps manually.

```powershell
& ([ScriptBlock]::Create((irm "https://christitus.com/win"))) -Preset Standard
```

## After WinUtil

- [ ] Sign into Steam; enable the library; install a test game when ready.
- [ ] Confirm Fast Startup is off.
- [ ] Full shut down before installing Ubuntu.

## Out of scope

No VS Code, Docker, WSL, or full Git toolchain on Windows — that lives on Ubuntu.
