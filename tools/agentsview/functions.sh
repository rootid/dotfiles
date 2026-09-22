#!/usr/bin/env zsh

# Prereq: uv (https://docs.astral.sh/uv/) - uvx ships with it.
# Local-first token/usage & session analytics across coding agents
# (Claude Code, Codex, etc). Web UI defaults to http://127.0.0.1:8080.

# Launch the AgentsView web UI in the foreground (Ctrl-C to stop).
function go_agentsview_serve() {
  uvx agentsview serve "$@"
}

# Start AgentsView as a background daemon (persists after shell exit).
function go_agentsview_start() {
  uvx agentsview daemon start "$@"
}

function go_agentsview_stop() {
  uvx agentsview daemon stop
}

function go_agentsview_status() {
  uvx agentsview daemon status
}
