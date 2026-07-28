#!/usr/bin/env bash
set -euxo pipefail

sudo -v
export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"

# GitHub CLI — official apt repo if not already present
if ! command -v gh >/dev/null 2>&1; then
  if apt-cache show gh >/dev/null 2>&1; then
    sudo apt-get install -y gh
  else
    (type -p wget >/dev/null || sudo apt-get install -y wget)
    sudo mkdir -p -m 755 /etc/apt/keyrings
    out="$(mktemp)"
    wget -nv -O"${out}" https://cli.github.com/packages/githubcli-archive-keyring.gpg
    cat "${out}" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    sudo apt-get update
    sudo apt-get install -y gh
  fi
fi

# eza — apt on newer Ubuntu; otherwise skip (alias can fall back later)
if ! command -v eza >/dev/null 2>&1; then
  if apt-cache show eza >/dev/null 2>&1; then
    sudo apt-get install -y eza
  else
    echo "eza not in apt; install later or change ls alias"
  fi
fi

# gitui / dust-class tools are optional; prefer mise/cargo when you need them
if command -v cargo >/dev/null 2>&1; then
  command -v gitui >/dev/null 2>&1 || cargo install gitui || true
fi

# ghq for repo organization (matches mac-setup)
if ! command -v ghq >/dev/null 2>&1; then
  if command -v go >/dev/null 2>&1; then
    go install github.com/x-motemen/ghq@latest
  else
    echo "ghq skipped (needs go via mise); after mise install golang: go install github.com/x-motemen/ghq@latest"
  fi
fi

echo "cli extras done"
