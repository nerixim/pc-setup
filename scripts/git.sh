#!/usr/bin/env bash
set -euxo pipefail

BASEDIR="$(cd "$(dirname "$0")/.." && pwd)"

# Prefer apt git (already on PATH after make apt)
if ! command -v git >/dev/null 2>&1; then
  sudo apt-get install -y git
fi

# Merge project gitconfig without wiping machine-local extras
if [[ -f "${HOME}/.gitconfig" ]] && grep -q 'name = Nikita Kamaev' "${HOME}/.gitconfig" 2>/dev/null; then
  echo "gitconfig already looks configured; skipping append"
else
  cat "${BASEDIR}/config/gitconfig" >>"${HOME}/.gitconfig"
fi

if [[ -f "${BASEDIR}/config/gitignore" ]]; then
  mkdir -p "${HOME}"
  # Keep a global excludes file; replace with repo copy for consistency
  cp "${BASEDIR}/config/gitignore" "${HOME}/.gitignore"
fi

if [[ ! -f "${HOME}/.aliases" ]] || ! grep -q 'git-prune-merged' "${HOME}/.aliases" 2>/dev/null; then
  cat <<'EOF' >>"${HOME}/.aliases"
alias git-prune-merged="git branch --merged | egrep -v '(^\*|master|main|dev|develop)' | xargs git branch -d"
EOF
fi

# Optional prettier diffs
if ! command -v delta >/dev/null 2>&1; then
  if command -v cargo >/dev/null 2>&1; then
    cargo install git-delta
  else
    echo "git-delta not installed (install via mise/rust later, or apt if packaged)"
  fi
fi

echo "Run: gh auth login   # when ready"
