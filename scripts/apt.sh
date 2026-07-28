#!/usr/bin/env bash
set -euxo pipefail

# Ask for the administrator password upfront.
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

BASEDIR="$(cd "$(dirname "$0")/.." && pwd)"
APTFILE="${BASEDIR}/Aptfile"

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

packages=()
while IFS= read -r line || [[ -n "${line}" ]]; do
  # strip comments / whitespace
  pkg="$(echo "${line}" | sed -e 's/#.*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  [[ -z "${pkg}" ]] && continue
  if apt-cache show "${pkg}" >/dev/null 2>&1; then
    packages+=("${pkg}")
  else
    echo "skip (not in apt): ${pkg}" >&2
  fi
done <"${APTFILE}"

if ((${#packages[@]})); then
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
fi

# Ubuntu renames some binaries — convenience symlinks in ~/bin
mkdir -p "${HOME}/bin"
if command -v fdfind >/dev/null 2>&1 && [[ ! -e "${HOME}/bin/fd" ]]; then
  ln -sf "$(command -v fdfind)" "${HOME}/bin/fd"
fi
if command -v batcat >/dev/null 2>&1 && [[ ! -e "${HOME}/bin/bat" ]]; then
  ln -sf "$(command -v batcat)" "${HOME}/bin/bat"
fi

# Ensure ~/bin is on PATH for later shells
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "${HOME}/.zsh_profile" 2>/dev/null; then
  echo 'export PATH="$HOME/bin:$PATH"' >>"${HOME}/.zsh_profile"
fi
