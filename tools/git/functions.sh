#!/usr/bin/env zsh

# Get the submodule status
function go_git_submodule_status() {
  git submodule status
}

function go_git_sync_gitignore() {
  local root
  root=$(git rev-parse --show-toplevel) || return 1
  git -C "$root" rm -r --cached .
  git -C "$root" add .
}

function go_git_save_work() {
 local old_branch new_branch
 old_branch=$(git rev-parse --abbrev-ref HEAD)
 new_branch=save_$(date '+%Y_%m_%d_%H_%M_%S')
 echo "Switching to branch ${new_branch} from ${old_branch}"
 git checkout -b "${new_branch}"
 git add .
 git commit -m "WIP"
 git push -u origin "${new_branch}"
 echo "Switching to branch ${old_branch} from ${new_branch}"
 git checkout "${old_branch}"
}

function go_git_new_feature() {
  local branch_name=${1:?Error: branch name required}
  echo "Fetching latest changes..."
  git fetch origin || return 1
  echo "Switching to main..."
  git switch main || return 1
  echo "Pulling latest from origin/main..."
  git pull origin main || return 1
  echo "Creating new branch: ${branch_name}"
  git switch -c "${branch_name}" || return 1
  echo "✓ Ready to work on ${branch_name}"
}
