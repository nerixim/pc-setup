# Windows (games)

Thin Windows 11 install. Debloat and apps via [Chris Titus WinUtil](https://github.com/ChrisTitusTech/winutil); details land here during implementation.

## Quick path

1. Install Windows 11 onto the **500 GB** partition only.
2. Disable Fast Startup.
3. Admin PowerShell: `irm https://christitus.com/win | iex`
4. Import `winutil-config.json` when present; otherwise apply Standard tweaks + Steam / browser / 7-Zip and export the config back into this folder.

See `../docs/plans/2026-07-29-pc-setup-design.md` for the full design.
