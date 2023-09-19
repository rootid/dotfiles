#!/usr/bin/env zsh

# Install nix 
function go_nix_install_macos() {
  sh <(curl -L https://nixos.org/nix/install)
}

## How to learn Nix 
#https://nixos.org/learn
#https://nix.dev/tutorials/learning-journey/shell-dot-nix
#https://nix.dev/recipes/best-practices - What are antipatterns?
#https://github.com/nix-dot-dev/getting-started-devenv-template
#Nix-env v/s OS v/s Shell
#https://github.com/jvns/nixpkgs/blob/main/libpaper.nix
# Nix tutorial
# https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/first-experiment.html
# With Python
# https://nixos.org/manual/nixpkgs/stable/#python
#
# https://paperless.blog/reproducible-jupyter-notebook-with-nix
# https://github.com/tweag/jupyenv`
  # Nix Flakes - https://dev.to/deciduously/workspace-management-with-nix-flakes-jupyter-notebook-example-2kke
  # https://discourse.nixos.org/t/error-experimental-nix-feature-nix-command-is-disabled/18089/6:x
  #

# To start nix shell
# nix-shell -p nix-info --run "nix-info -m"
#
#nix-env -qa '*'
# To find any package
#nix-env -qa '*' | awk '{print $1}' | rg -i "pip"

#nix-env --uninstall oil
#nix-collect-garbage
#nix-collect-garbage -d --delete-old
#nix-channel --update
#nix-env --upgrade
# Channel -> upstream/repo
# Env -> downstream/deployment host
# To list the channels
# nix-channel --list-generations
# To list environments
# nix-env --list-generations

# To build package 
# nix-build paperjam.nix
# To install with dry run
# nix-env -i -f paperjam.nix --dry-run -v
#
# brew install imagemagick
#
# dotfiles git:(main) ✗ paperjam 'select {1: rotate(90)}' ~/Desktop/in.pdf out1.pdf
# dotfiles git:(main) ✗ open out1.pdf
# dotfiles git:(main) ✗ paperjam 'select {1: flip(h) flip(v)}' ~/Desktop/in.pdf out1.pdf
