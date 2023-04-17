#!/bin/sh

# git-crypt workflow

# First time use in repo

function go_git_crypt_init() {
  git-crypt init
}

function go_git_crypt_lock() {
  git-crypt lock
}

function go_git_crypt_unlock() {
  git-crypt unlock
}

function go_git_crypt_add_gpg_user() {
  # NOTE - first import key pair into gpg use gpg --import pvt/public_key.asc
  git-crypt add-gpg-user $1
}

# Reuse in the repo

# Check the status of file
# Use .gitattribute file to store the files that needs to encrypted
function go_git_crypt_status() {
  git-crypt status | egrep "^\s+encrypted"
}
