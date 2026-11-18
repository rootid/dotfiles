#!/usr/bin/env zsh

# Org clock via the running Emacs server (see "Emacs server" in basic.org).
# -w 2: give up after 2s if Emacs is busy, so tmux never hangs on it.

# Running task, e.g. "0:12/0:25 Pattern: Two pointers"; prints nothing when idle
function go_emacs_clock_status() {
  emacsclient -w 2 --eval '(vs_org/clock-status)' 2>/dev/null | sed 's/^"//; s/"$//'
}

# Clock back into the most recent task
function go_emacs_clock_in() {
  emacsclient -w 2 --eval '(progn (require (quote org-clock)) (org-clock-in-last) (vs_org/clock-status))'
}

function go_emacs_clock_out() {
  emacsclient -w 2 --eval '(progn (require (quote org-clock)) (when (org-clocking-p) (org-clock-out)) "clocked out")'
}
