#!/usr/bin/env zsh

TOP_DIR=${HOME}/utils
PYTHON=python3.11

function go_get_week_number() {
  ${PYTHON} ${TOP_DIR}/go_get_week_number.py
}

function go_setup_java_project() {

# Prereq - setup mvn envriorment

# Set follwing values in .envrc
#GROUP_ID=com.coffee
#PROJECT_NAME=hello-world

mvn archetype:generate -DgroupId=$GROUP_ID \
-DartifactId=$PROJECT_NAME \
-DarchetypeArtifactId=maven-archetype-quickstart \
 -DinteractiveMode=false
}

# Copied from Freedom 
# TODO: Firefox persist the cached DNS records, so update the DNS records using firefox "open about:networking#dns"
# Set up the cron job
# sudo crontab -e
# */5 22-23,0-4 * * * $HOME/dotfiles/utils/focus.sh $HOME/.block-dns
# 0 7 * * * $HOME/dotfiles/utils/pause_focus.sh

function go_block_dns() {
  dns_file=$1
  while read line
  do
   echo $line | sudo tee -a /etc/hosts
  done < $dns_file
}

function go_block_twitter() {
   go_block_dns $HOME/.dns-block-media
   default_block
}

function go_free_my_time() {
   go_block_dns $HOME/.dns-block-media
   go_block_dns $HOME/.dns-block-leisure
   default_block
}

function default_block() {
   go_block_dns $HOME/.dns-block-adult
}

function go_freedom_youtube() {
   go_block_dns $HOME/.dns-block-youtube
}
