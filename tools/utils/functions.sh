#!/usr/bin/env zsh

TOP_DIR=${HOME}/utils
PYTHON=python3

CURSOR_HOME=/Applications/Cursor.app/Contents/MacOS
export PATH="$CURSOR_HOME:$PATH"

IDEA_HOME_DUP=/Applications/IntelliJ_IDEA_CE.app/Contents/MacOS
export PATH="$IDEA_HOME_DUP:$PATH"

PASSWORD_MGR="${HOME}/Applications/Chrome Apps.localized/Google Password Manager.app"

function go_open_password_mgr() {
  open ${PASSWORD_MGR}
}

# find . -type f -iname "*.pdf" -not -name "shrink_*" | sed 's|^./||' | while read -r file; do
#     go_pdf_shrink "$file"
# done
function go_pdf_shrink() {
  which ps2pdf > /dev/null 2>&1

  if [ $? -ne 0 ] 
  then
      echo "Error: ps2pdf is not installed"
      echo "Please install ghostscript package to continue"
      exit 1
  fi

  input_file=$1
  output_file="shrink_${input_file}"

  if [ ! -f "$input_file" ] 
  then
      echo "Input file '$input_file' not found"
      exit 1
  fi

  ps2pdf -dPDFSETTINGS=/ebook "$input_file" "$output_file"

}

function go_aai() {
  open ~/aai.jpg 
}

function go_get_week_number() {
  ${PYTHON} ${TOP_DIR}/go_get_week_number.py
}

function go_get_my_eta() {
  ${PYTHON} ${TOP_DIR}/go_get_eta.py
}

function go_timer_start() {
  ${PYTHON} ${TOP_DIR}/go_timer_start.py
}

function go_open_ide_intellij() {
  idea
}

function go_open_ide_cursor() {
  Cursor
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

CHROME_APP="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
PROFILES="$HOME/Library/Application Support/Google/Chrome/Local State"

function go_chrome_open_vanilla() {
  "$chrome_app"
}

function go_chrome_open() {
  "$CHROME_APP"  --profile-directory="Profile 3"
}

function go_chrome_open_profile1() {
  "$CHROME_APP" --profile-directory="Profile 1"
}

function go_chrome_list_profiles() {
  cat "$PROFILES" | jq -r '.profile.info_cache|to_entries|map(.key + ": " + .value.name)|.[]' 
}

