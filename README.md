# pc-setup

Dual-boot setup for a Lenovo ThinkPad P52s: **Windows 11** (games) + **Ubuntu 26.04 LTS** (dev / experiments).

Sibling to [mac-setup](https://github.com/nerixim/mac-setup).

## Quick path

1. Follow **[docs/playbook.md](docs/playbook.md)** (wipe → Windows 500 GB → WinUtil → Ubuntu + LUKS).
2. On Ubuntu:

```bash
sudo apt update && sudo apt install -y git make
git clone git@github.com:nerixim/pc-setup.git ~/pc-setup
cd ~/pc-setup
make apt zsh git mise docker cli
```

## Layout

| Path | Role |
|---|---|
| `docs/playbook.md` | End-to-end checklist |
| `docs/dual-boot.md` | Partitioning / GRUB / recovery |
| `docs/thinkpad-p52s.md` | Firmware and drivers |
| `windows/` | WinUtil config + apps notes |
| `Makefile` + `scripts/` | Ubuntu bootstrap (like `mac-setup`) |
| `Aptfile` | apt package list |

## Windows

```powershell
& ([ScriptBlock]::Create((irm "https://christitus.com/win"))) -Config "C:\path\to\pc-setup\windows\winutil-config.json" -Run
```

See [windows/README.md](windows/README.md).

## Design

[docs/plans/2026-07-29-pc-setup-design.md](docs/plans/2026-07-29-pc-setup-design.md)
