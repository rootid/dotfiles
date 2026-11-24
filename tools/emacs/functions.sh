#!/usr/bin/env zsh

# Emacs client/server. The server runs inside the GUI Emacs.app
# (server-start in basic.org); emacsclient opens frames onto it.

function go_emacs_server_status() {
  if emacsclient -e t >/dev/null 2>&1; then
    echo "Emacs server: running"
  else
    echo "Emacs server: not running"
    return 1
  fi
}

# Start Emacs.app (which runs server-start) and wait until the socket answers
function go_emacs_server_start() {
  emacsclient -e t >/dev/null 2>&1 && return 0
  open -a Emacs
  local i
  for i in {1..60}; do
    emacsclient -e t >/dev/null 2>&1 && return 0
    sleep 1
  done
  echo "Emacs server did not start within 60s" >&2
  return 1
}

# New GUI frame on the server, optionally visiting files: go_emacs_client [file...]
function go_emacs_client() {
  go_emacs_server_start || return 1
  emacsclient -n -c "$@"
}
