#!/usr/bin/env bash
set -euxo pipefail

sudo -v

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  echo "Docker already installed"
else
  # Official convenience script — installs Engine + compose plugin on Ubuntu
  curl -fsSL https://get.docker.com | sudo sh
fi

sudo usermod -aG docker "${USER}"

cat <<'EOF'
Docker installed. Log out and back in (or reboot) for the docker group to apply.
Test with: docker run --rm hello-world
EOF
