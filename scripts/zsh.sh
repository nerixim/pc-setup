#!/usr/bin/env bash
set -euxo pipefail

sudo -v

if ! command -v zsh >/dev/null 2>&1; then
  sudo apt-get install -y zsh
fi

# Make zsh available as a login shell
if ! grep -q "$(command -v zsh)" /etc/shells; then
  echo "$(command -v zsh)" | sudo tee -a /etc/shells
fi

if [[ "${SHELL}" != "$(command -v zsh)" ]]; then
  chsh -s "$(command -v zsh)"
fi

# Oh My Zsh (non-interactive)
if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

if [[ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "${ZSH_CUSTOM}/themes/powerlevel10k"
fi

if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
fi

if [[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
fi

# Seed rc files if missing; do not clobber a customized setup
if [[ ! -f "${HOME}/.aliases" ]]; then
  cat <<'EOF' >"${HOME}/.aliases"
command -v eza >/dev/null && alias ls="eza"
command -v bat >/dev/null && alias cat="bat"
command -v rg >/dev/null && alias grep="rg"
command -v fd >/dev/null && alias find="fd"
command -v htop >/dev/null && alias top="htop"
alias d="docker"
alias dc="docker compose"
EOF
fi

touch "${HOME}/.zsh_profile"

if ! grep -q 'source ~/.zsh_profile' "${HOME}/.zshrc" 2>/dev/null; then
  cat <<'EOF' >>"${HOME}/.zshrc"
source ~/.zsh_profile
source ~/.aliases
EOF
fi

if ! grep -q 'powerlevel10k' "${HOME}/.zshrc" 2>/dev/null; then
  sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "${HOME}/.zshrc" || true
fi

if ! grep -q 'zsh-autosuggestions' "${HOME}/.zshrc" 2>/dev/null; then
  sed -i 's/^plugins=(git)/plugins=(git gitfast docker docker-compose colored-man-pages zsh-autosuggestions zsh-syntax-highlighting)/' "${HOME}/.zshrc" || true
fi

if ! grep -q 'export LANG=' "${HOME}/.zsh_profile" 2>/dev/null; then
  cat <<'EOF' >>"${HOME}/.zsh_profile"
export LANG="en_US.UTF-8"
export GOPATH=$HOME/go
export PATH="$HOME/bin:$PATH:$GOPATH/bin"
export EDITOR="vim"
EOF
fi

if command -v zoxide >/dev/null 2>&1 && ! grep -q 'zoxide init' "${HOME}/.zsh_profile" 2>/dev/null; then
  echo 'eval "$(zoxide init zsh)"' >>"${HOME}/.zsh_profile"
fi

cat <<'EOF'
zsh setup done. Log out/in (or reboot) if the login shell did not switch yet.
First interactive zsh may launch the powerlevel10k wizard — configure to taste.
EOF
