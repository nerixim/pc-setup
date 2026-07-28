#!/usr/bin/env bash
set -euxo pipefail

BASEDIR="$(cd "$(dirname "$0")/.." && pwd)"

if ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.run | sh
fi

# mise installs to ~/.local/bin by default
MISE_BIN="${HOME}/.local/bin/mise"
if [[ ! -x "${MISE_BIN}" ]] && command -v mise >/dev/null 2>&1; then
  MISE_BIN="$(command -v mise)"
fi

if ! grep -q 'mise activate' "${HOME}/.zsh_profile" 2>/dev/null; then
  echo 'eval "$(${HOME}/.local/bin/mise activate zsh)"' >>"${HOME}/.zsh_profile"
fi

cp "${BASEDIR}/scripts/.mise.toml" "${HOME}/.mise.toml"
cp "${BASEDIR}/scripts/.default-gems" "${HOME}/.default-gems"
cp "${BASEDIR}/scripts/.default-npm-packages" "${HOME}/.default-npm-packages"
cp "${BASEDIR}/scripts/.default-python-packages" "${HOME}/.default-python-packages"

# Activate for this script if possible
export PATH="${HOME}/.local/bin:${PATH}"
if [[ -x "${MISE_BIN}" ]]; then
  eval "$("${MISE_BIN}" activate bash)"
  "${MISE_BIN}" use -g usage || true
  "${MISE_BIN}" install || true
fi

cat <<'EOF'
mise is installed. Open a new shell (or: source ~/.zsh_profile) then:
  mise install
  mise ls

Rust (optional, not via mise by default):
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
EOF
