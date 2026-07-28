# pc-setup

Automated dual-boot setup for a Lenovo ThinkPad P52s: **Windows 11** (games) + **Ubuntu 26.04 LTS** (dev / experiments).

Sibling to [mac-setup](https://github.com/nerixim/mac-setup).

## Status

Design is validated. Implementation (playbooks, WinUtil config, Linux `make` targets) comes next.

See [docs/plans/2026-07-29-pc-setup-design.md](docs/plans/2026-07-29-pc-setup-design.md).

## Intended flow (summary)

1. Wipe disk → Windows 11 on a 500 GB partition
2. WinUtil with the saved config (debloat + Steam essentials)
3. Ubuntu 26.04 on the remaining ~1.4 TB with LUKS
4. `make apt zsh git mise docker cli` on Ubuntu
