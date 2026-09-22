#!/usr/bin/env zsh

# Model presets - bump these when new models ship.
# The everyday default lives in ~/.claude/settings.json (packages/claude).
CLAUDE_QUICK_MODEL=claude-haiku-4-5-20251001
CLAUDE_DEEP_MODEL=claude-opus-5
CLAUDE_DEEP_EFFORT=max

# Cheap, fast session for trivial questions
function go_claude_quick() {
  claude --model "$CLAUDE_QUICK_MODEL" "$@"
}

# Strongest model at max effort for hard debugging / design work
function go_claude_deep() {
  claude --model "$CLAUDE_DEEP_MODEL" --effort "$CLAUDE_DEEP_EFFORT" "$@"
}

# Read-only planning session - proposes changes, edits nothing
function go_claude_plan() {
  claude --permission-mode plan "$@"
}

function go_claude_usage() {
  claude -p "/usage"
}
