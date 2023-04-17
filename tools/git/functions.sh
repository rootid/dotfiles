#!/usr/bin/env zsh

# Get the submodule status
function go_git_submodule_status() {
  git submodule status
}

function go_git_sync_gitignore() {
  git rm -rf --cached .
  git add .
}
