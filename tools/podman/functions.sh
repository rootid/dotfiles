#!/usr/bin/env zsh

# Echo the container name to act on: $2 when given, otherwise one picked
# with fzf from the containers matching the filter (running|stopped|all).
function _go_podman_pick() {
  local filter=${1:?Error: filter required (running|stopped|all)}
  local name=$2
  if [[ -n "$name" ]]; then
    echo "$name"
    return 0
  fi
  # TODO(human)
}

# Ask a y/N question; succeeds only on "y".
function _go_podman_confirm() {
  local reply rc
  read -q "reply?$1 [y/N] "
  rc=$?
  echo
  return $rc
}

# Follow logs: go_podman_logs [name] [podman logs args...]
function go_podman_logs() {
  local name
  name=$(_go_podman_pick all "$1") || return 1
  (( $# )) && shift
  podman logs -f --tail 200 "$@" "$name"
}

# Shell into a container (bash, falling back to sh), or run a command:
# go_podman_exec [name] [cmd...]
function go_podman_exec() {
  local name
  name=$(_go_podman_pick running "$1") || return 1
  (( $# )) && shift
  if (( $# )); then
    podman exec -it "$name" "$@"
  else
    podman exec -it "$name" sh -c 'command -v bash >/dev/null && exec bash || exec sh'
  fi
}

function go_podman_inspect() {
  local name
  name=$(_go_podman_pick all "$1") || return 1
  podman inspect "$name"
}

function go_podman_start() {
  local name
  name=$(_go_podman_pick stopped "$1") || return 1
  podman start "$name"
}

function go_podman_stop() {
  local name
  name=$(_go_podman_pick running "$1") || return 1
  podman stop "$name"
}

function go_podman_restart() {
  local name
  name=$(_go_podman_pick running "$1") || return 1
  podman restart "$name"
}

function go_podman_rm() {
  local name
  name=$(_go_podman_pick stopped "$1") || return 1
  podman rm "$name"
}

function go_podman_stop_all() {
  local -a ids
  ids=(${(f)"$(podman ps -q)"})
  if (( ! ${#ids} )); then
    echo "No running containers"
    return 0
  fi
  podman ps --format '  {{.Names}}'
  _go_podman_confirm "Stop all ${#ids} running containers?" || return 1
  podman stop "${ids[@]}"
}

# Stopped containers, dangling images, unused networks, build cache.
# Never -a (would drop the vsc-* devcontainer images) or --volumes.
function go_podman_prune() {
  podman system df
  _go_podman_confirm "Prune stopped containers, dangling images, unused networks and build cache?" || return 1
  podman system prune -f
}

# Pick images with fzf (TAB to multi-select), then remove them.
function go_podman_rmi() {
  local -a ids
  ids=(${(f)"$(podman images --format '{{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}' \
    | fzf -m --delimiter '\t' --with-nth 2.. --header 'TAB to select images to remove' \
    | cut -f1)"})
  (( ${#ids} )) || return 1
  _go_podman_confirm "Remove ${#ids} image(s)?" || return 1
  podman rmi "${ids[@]}"
}

# Resize the default machine: go_podman_machine_resize <memory-MiB> [cpus]
function go_podman_machine_resize() {
  local memory=${1:?Error: memory in MiB required, e.g. 4096}
  local cpus=$2
  local -a opts=(--memory "$memory")
  [[ -n "$cpus" ]] && opts+=(--cpus "$cpus")
  _go_podman_confirm "Stop the podman machine and set ${opts[*]}?" || return 1
  podman machine stop || return 1
  podman machine set "${opts[@]}"
  podman machine start
}

function go_podman_help() {
  alias | grep '^pd' | sort
}
