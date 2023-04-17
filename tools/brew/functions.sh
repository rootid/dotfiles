#!/usr/bin/env zsh

# List all the formulas
function go_brew_list_all_formulas() {
  brew list
}

# Verify the installation
function go_brew_verify_installation() {
  brew doctor
}

# Get a count of kegs, number of files, and the used disk space
function go_brew_info() {
  brew info
}

# Get a count of kegs, number of files, and the used disk space
function go_brew_info_all() {
  brew info --all --json
}

# List cache
function go_brew_cache() {
  brew --cache
}

# Search package
function go_brew_search() {
  brew --search
}
