#!/usr/bin/env zsh

# Effort presets. `agy models` lists models if you want to pin one via --model.
AGY_QUICK_EFFORT=low
AGY_DEEP_EFFORT=high

# Low-effort session for trivial questions
function go_agy_quick() {
  agy --effort "$AGY_QUICK_EFFORT" "$@"
}

# High-effort session for hard problems
function go_agy_deep() {
  agy --effort "$AGY_DEEP_EFFORT" "$@"
}

# Planning session - proposes changes, edits nothing
function go_agy_plan() {
  agy --mode plan "$@"
}
