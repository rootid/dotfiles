#!/bin/bash

VLC='~/Applications/VLC.app/Contents/MacOS/VLC'

# Install cli by building code
# https://handbrake.fr/docs/en/latest/developer/build-mac.html
# Issue SSL: CERTIFICATE_VERIFY_FAILED Fix - https://stackoverflow.com/questions/27835619/urllib-and-ssl-certificate-verify-failed-error
# file updated - make/df-fetch.py
HBCLI=HandBrakeCLI

function open_all_mp4() {
  find $PWD -name "*mp4" -type f -exec $VLC --rate 2.0 --playlist-autostart --playlist-tree '{}' +
}

function vlc_2x() {
  $VLC --rate 2.0 --playlist-autostart $1
}

function hb_compress_video() {
  $HBCLI -i $1 -o $1_convert.mp4 -e x265 -q 22 -r 15 -B 64 -X 960 -O
}

# convert "a b c" to "a_b_c"
# eg. remove_space a\ b\ c.t
function remove_space() {
  mv "$1" `echo $1 | tr ' ' '_'`
}
