#!/bin/zsh

function install_homebrew() {
# Check for Homebrew
  if test ! $(which brew)
  then
    echo "Installing Homebrew"
    # Install the correct homebrew for each OS type
    if test "$(uname)" = "Darwin"
    then
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
    then
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
    fi
  fi
  exit 0
}

function install_omz() {
  sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

