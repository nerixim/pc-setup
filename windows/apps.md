# Windows apps

Managed primarily by WinUtil / Winget via `winutil-config.json`.

| App | Why |
|---|---|
| Steam | Games (Fallout, etc.) |
| Firefox | Browser without Chrome account gravity |
| 7-Zip | Archives |
| PowerToys | Small QoL (FancyZones, etc.) without a full toolkit |

## Manual / vendor (not in WinUtil config)

| Item | Notes |
|---|---|
| Lenovo System Update / Vantage | Chipset, BIOS, trackpad, audio |
| NVIDIA driver | If Lenovo package is behind; Game Ready is fine for older titles |

## Do not install (on purpose)

- Office / OneDrive / Teams (unless you later need them)
- Epic / GOG / Xbox app — add later only if a game requires them
- Dev tools (use Ubuntu)

## Updating apps later

```powershell
winget upgrade --all
```

Or reopen WinUtil → Install → Upgrade.
