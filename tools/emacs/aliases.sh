#!/usr/bin/env zsh

alias evi='emacs --no-splash'

alias emacs_vanilla='emacs --no-init-file --no-loadup'

# Use with .el script and use like this for init.el script
# emacs_custom init.el
alias emacs_custom='emacs --no-splash --no-init-file --load'
# TODO - setup experimental version, check how to use chdir
alias emacs_exp='emacs --no-init-file '

# New frame in the running Emacs; opens Emacs.app (which starts the server) if none is running
alias ec='emacsclient -n -c -a "open -a Emacs"'

# Org clock from any terminal (functions in tools/emacs/functions.sh)
alias clock_in='go_emacs_clock_in'
alias clock_out='go_emacs_clock_out'
alias clock_status='go_emacs_clock_status'
