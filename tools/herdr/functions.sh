#!/usr/bin/env zsh

# herdr - terminal workspace manager for AI agents, used alongside tmux.
# workspace ~ tmux session, tab ~ window, pane ~ pane. Prefix: ctrl+b.
# Config: packages/herdr/.config/herdr/config.toml (make link_terminal).
# Agent helpers start $GO_AI_AGENT (tools/ai/functions.sh, default claude).

# Fail unless this shell runs inside a herdr pane.
function _go_herdr_in_pane() {
  if [[ -z "$HERDR_PANE_ID" ]]; then
    echo "Not inside herdr - run 'hd' first." >&2
    return 1
  fi
}

# Split a pane and print the new pane id. The new pane does not take focus.
#   _go_herdr_split <pane_id> <right|down> [label] [command]
function _go_herdr_split() {
  local pane=${1:?Error: pane id required} dir=${2:?Error: direction required (right|down)}
  local label=$3 cmd=$4 new
  new=$(herdr pane split "$pane" --direction "$dir" --no-focus | jq -r '.result.pane.pane_id // empty')
  if [[ -z "$new" ]]; then
    echo "herdr: could not split $pane" >&2
    return 1
  fi
  [[ -n "$label" ]] && herdr pane rename "$new" "$label" >/dev/null
  [[ -n "$cmd" ]] && herdr pane run "$new" "$cmd" >/dev/null
  echo "$new"
}

# Start a named $GO_AI_AGENT agent in a pane. A freshly split pane is still
# starting its shell (agent_pane_busy), so retry for up to ~10s.
function _go_herdr_start_agent() {
  local name=${1:?Error: agent name required} pane=${2:?Error: pane id required}
  local out code i
  for i in {1..20}; do
    out=$(herdr agent start "$name" --kind "$GO_AI_AGENT" --pane "$pane" --timeout 20000)
    code=$(jq -r '.error.code // empty' <<<"$out")
    [[ "$code" != agent_pane_busy ]] && break
    sleep 0.5
  done
  if [[ -n "$code" ]]; then
    echo "herdr: agent start failed: $(jq -r '.error.message' <<<"$out")" >&2
    return 1
  fi
}

# Open (or focus) a workspace for a git repo, labelled after the repo.
# The per-project counterpart of `ts <name>`.  go_herdr_ws [dir]
function go_herdr_ws() {
  local dir=${1:-$PWD} root label id
  root=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || root=${dir:A}
  label=${root:t}
  if ! herdr workspace list >/dev/null 2>&1; then
    echo "No herdr server running - run 'hd' first." >&2
    return 1
  fi
  id=$(herdr workspace list \
    | jq -r --arg l "$label" '.result.workspaces[] | select(.label == $l) | .workspace_id' \
    | head -n 1)
  if [[ -n "$id" ]]; then
    herdr workspace focus "$id" >/dev/null
  else
    herdr workspace create --cwd "$root" --label "$label" --focus >/dev/null
  fi
}

# Pick a workspace with fzf and focus it.
function go_herdr_pick() {
  local rows id
  rows=$(herdr workspace list \
    | jq -r '.result.workspaces[] | [.workspace_id, .label, .agent_status, "\(.tab_count) tabs"] | @tsv') || return 1
  if [[ -z "$rows" ]]; then
    echo "No herdr workspaces." >&2
    return 1
  fi
  # fzf exits non-zero on ESC/Ctrl-C, so a cancelled pick aborts.
  id=$(echo "$rows" \
    | fzf --delimiter '\t' --with-nth 2.. --header 'Pick a herdr workspace' --select-1 \
    | cut -f1) || return 1
  herdr workspace focus "$id" >/dev/null
}

# Lay out the current tab for agent work, then run $GO_AI_AGENT in this pane
# (herdr detects it from the foreground process).
function go_herdr_dev() {
  _go_herdr_in_pane || return 1
  local root=$HERDR_PANE_ID
  herdr pane rename "$root" "$GO_AI_AGENT" >/dev/null

  # TODO(human): build the layout around $root with _go_herdr_split.

  "$GO_AI_AGENT"
}

# Split off a named agent next to the current pane, optionally prompting it.
#   go_herdr_spawn reviewer "Review the diff against main"
function go_herdr_spawn() {
  local name=${1:?Usage: go_herdr_spawn <name> [prompt]} prompt=$2 pane
  _go_herdr_in_pane || return 1
  pane=$(_go_herdr_split "$HERDR_PANE_ID" right "$name") || return 1
  _go_herdr_start_agent "$name" "$pane" || return 1
  [[ -n "$prompt" ]] && herdr agent prompt "$name" "$prompt" >/dev/null
  echo "Started $GO_AI_AGENT agent '$name' in $pane"
}
