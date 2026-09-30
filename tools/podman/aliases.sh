#!/usr/bin/env zsh

alias pd='podman'

# Inspect
alias pdps='podman ps'
alias pdpsa='podman ps -a'
alias pdi='podman images'
alias pdl='go_podman_logs'
alias pdx='go_podman_exec'
alias pdin='go_podman_inspect'
alias pdst='podman stats'

# Lifecycle
alias pdr='podman run --rm -it'
alias pdstart='go_podman_start'
alias pds='go_podman_stop'
alias pdrs='go_podman_restart'
alias pdrm='go_podman_rm'
alias pdsa='go_podman_stop_all'

# Compose
alias pdc='podman compose'
alias pdcu='podman compose up -d'
alias pdcd='podman compose down'
alias pdcb='podman compose up -d --build'
alias pdcl='podman compose logs -f'
alias pdcp='podman compose ps'

# Machine
alias pdm='podman machine list'
alias pdms='podman machine start'
alias pdmx='podman machine stop'
alias pdmssh='podman machine ssh'
alias pdmresize='go_podman_machine_resize'

# Cleanup
alias pdprune='go_podman_prune'
alias pdrmi='go_podman_rmi'

alias pdh='go_podman_help'
