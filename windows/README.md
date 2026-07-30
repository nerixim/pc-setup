# Windows (games)

Thin Windows 11 on the **500 GB** partition. Full sequence: [../docs/playbook.md](../docs/playbook.md).

## Install reminders

1. Wipe the disk; create **only** a 500 GB partition for Windows; leave ~1.4 TB unallocated.
2. Prefer a local account for OOBE.
3. Install Lenovo + NVIDIA drivers before heavy Steam use.
4. Disable **Fast Startup**: Control Panel → Power Options → Choose what the power buttons do → uncheck Fast startup.

## WinUtil

Copy `winutil-config.json` onto the machine, then in **Admin PowerShell**:

```powershell
& ([ScriptBlock]::Create((irm "https://christitus.com/win"))) -Config "C:\path\to\winutil-config.json" -Run
```

That applies debloat/tweaks and installs Steam, Firefox, 7-Zip, and PowerToys.

## After WinUtil

- [ ] Sign into Steam.
- [ ] Confirm Fast Startup is off.
- [ ] Full shut down before installing Ubuntu.
