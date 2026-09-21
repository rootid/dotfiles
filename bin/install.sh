#!/bin/zsh

function install_homebrew() {
# Check for Homebrew
  if ! command -v brew >/dev/null 2>&1
  then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

function install_omz() {
# curl, not wget: macOS ships curl but not wget.
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

