#!/usr/bin/env zsh

# Agent used by every shared helper below: claude | agy | gemini.
# Override per shell (export GO_AI_AGENT=agy) or per call (GO_AI_AGENT=agy ai "...").
: ${GO_AI_AGENT:=claude}

# Send a one-shot prompt to $GO_AI_AGENT and print the answer.
# Piped stdin is appended to the prompt as context.
function _go_ai_run() {
  local prompt="$1" input
  if [[ ! -t 0 ]]; then
    input=$(cat)
    [[ -n "$input" ]] && prompt="${prompt}"$'\n\n'"${input}"
  fi
  case "$GO_AI_AGENT" in
    claude) claude -p "$prompt" ;;
    agy)    agy -p "$prompt" ;;
    gemini) gemini -p "$prompt" ;;
    *)
      echo "GO_AI_AGENT must be claude, agy or gemini (got '$GO_AI_AGENT')" >&2
      return 1
      ;;
  esac
}

# Ask a quick question: go_ai_ask "how do I list open ports on macOS"
function go_ai_ask() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: ai <question>   (or pipe context in: cmd | ai <question>)" >&2
    return 1
  fi
  _go_ai_run "$*"
}

# Explain piped input or an argument:
#   cat script.sh | aiexplain      pbpaste | aiexplain      aiexplain 'tar -xzvf x.tgz'
function go_ai_explain() {
  local ask="Explain concisely what this does. Point out anything risky or surprising."
  if [[ -t 0 ]]; then
    if [[ $# -eq 0 ]]; then
      echo "Usage: <cmd> | aiexplain   or   aiexplain '<command or text>'" >&2
      return 1
    fi
    _go_ai_run "${ask}"$'\n\n'"$*" </dev/null
  else
    _go_ai_run "$ask"
  fi
}

# Re-run the previous command (after confirming) and ask why it failed.
# Only ever prints a suggestion - nothing the agent says is executed.
function go_ai_fix() {
  setopt localoptions extendedglob
  local cmd output rc
  cmd=$(fc -ln -1)
  if [[ "$cmd" == (aifix|go_ai_fix)* ]]; then
    cmd=$(fc -ln -2 -2)
  fi
  cmd="${cmd##[[:space:]]#}"
  if [[ -z "$cmd" ]]; then
    echo "No previous command found." >&2
    return 1
  fi
  echo "Previous command: $cmd"
  if ! read -q "?Re-run it to capture the error? [y/N] "; then
    echo
    return 1
  fi
  echo
  output=$(eval "$cmd" 2>&1)
  rc=$?
  if [[ $rc -eq 0 ]]; then
    echo "Command succeeded (exit 0) - nothing to fix."
    return 0
  fi
  print -r -- "$output" | tail -n 80 | _go_ai_run \
    "This zsh command on macOS failed with exit code ${rc}: ${cmd}
Output (last 80 lines) follows. Explain the cause in one or two sentences, then give the corrected command. Be brief."
}

# Review the current branch against a base branch (default: main).
function go_ai_review() {
  local base="${1:-main}" diff
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "Not in a git repository." >&2; return 1; }
  diff=$(git diff "${base}...HEAD") || return 1
  if [[ -z "$diff" ]]; then
    echo "No changes between ${base} and HEAD."
    return 0
  fi
  print -r -- "$diff" | _go_ai_run \
    "Review this diff (${base}...HEAD) for bugs, risky changes and missing tests. Be specific and concise; cite file:line. Skip praise."
}

# Draft a commit message for the staged changes and open it in your editor.
# Save to commit, or empty the message to abort.
function go_ai_commit_msg() {
  local diff msg
  diff=$(git diff --cached) || return 1
  if [[ -z "$diff" ]]; then
    echo "Nothing staged - run git add first." >&2
    return 1
  fi
  msg=$(print -r -- "$diff" | _go_ai_run \
    "Write a git commit message for this staged diff: an imperative subject line under 72 characters, a blank line, then a short body explaining why. Output only the message - no code fences, no commentary.") || return 1
  git commit -e -m "$msg"
}

# Draft a PR description, open it in your editor, then confirm before
# running gh pr create. First line of the draft is the PR title.
function go_ai_pr_desc() {
  local base="${1:-main}" draft body title
  command -v gh >/dev/null 2>&1 || { echo "gh is not installed (brew install gh)." >&2; return 1; }
  git rev-parse --git-dir >/dev/null 2>&1 || { echo "Not in a git repository." >&2; return 1; }
  draft=$(mktemp -t pr_desc) || return 1
  { git log --oneline "${base}..HEAD"; echo; git diff "${base}...HEAD"; } | _go_ai_run \
    "Write a GitHub pull request description for these commits and diff. Line 1: a concise PR title (no prefix like 'Title:'). Line 2: blank. Then a markdown body with '## Summary' (bullets) and '## Test plan' sections. Output only that - no code fences." \
    > "$draft" || return 1
  "${EDITOR:-vim}" "$draft"
  title=$(head -n 1 "$draft")
  if [[ -z "$title" ]]; then
    echo "Empty title - aborted. Draft kept at $draft" >&2
    return 1
  fi
  if ! read -q "?Create PR '${title}' against ${base}? [y/N] "; then
    echo
    echo "Not created. Draft kept at $draft"
    return 0
  fi
  echo
  body=$(mktemp -t pr_body) || return 1
  tail -n +3 "$draft" > "$body"
  gh pr create --base "$base" --title "$title" --body-file "$body"
}

# Check that the AI config symlinks from this repo are intact. Some tools
# rewrite their settings by replacing the file, which silently breaks the link.
function go_ai_doctor() {
  local f target ok=1 cli
  for cli in claude agy gemini npx jq; do
    command -v "$cli" >/dev/null 2>&1 || { echo "MISSING  command: $cli"; ok=0; }
  done
  for f in ~/.claude/settings.json ~/.claude/CLAUDE.md ~/.gemini/settings.json ~/.agents/.skill-lock.json; do
    if [[ ! -e "$f" && ! -L "$f" ]]; then
      echo "MISSING  $f  (run: make link_ai)"
      ok=0
    elif [[ ! -L "$f" ]]; then
      echo "BROKEN   $f is a regular file, not a symlink - a tool replaced it."
      echo "         Fix: diff it against the repo copy, copy it into packages/, then make link_ai"
      ok=0
    else
      target=$(readlink "$f")
      [[ "$target" == *dotfiles/packages/* ]] || { echo "ODD      $f -> $target"; ok=0; }
    fi
  done
  [[ -L ~/.gemini/skills ]] || { echo "MISSING  ~/.gemini/skills -> ~/.agents/skills symlink (run: go_ai_skills_restore)"; ok=0; }
  (( ok )) && echo "AI setup OK"
  (( ok ))
}

# Reinstall every skill pinned in ~/.agents/.skill-lock.json (one `skills add`
# per source repo, for the agents recorded in the lockfile), then make sure the
# per-agent skill directories point at the shared ~/.agents/skills.
function go_ai_skills_restore() {
  local lock=~/.agents/.skill-lock.json src
  local -a names agents
  [[ -r "$lock" ]] || { echo "No lockfile at $lock (run: make link_ai)" >&2; return 1; }
  command -v jq >/dev/null 2>&1 || { echo "jq is required (brew install jq)." >&2; return 1; }
  agents=(${(f)"$(jq -r '.lastSelectedAgents[]' "$lock")"})
  for src in ${(f)"$(jq -r '[.skills[].source] | unique[]' "$lock")"}; do
    names=(${(f)"$(jq -r --arg s "$src" '.skills | to_entries[] | select(.value.source == $s) | .key' "$lock")"})
    echo "==> $src (${#names} skills)"
    npx -y skills add "$src" -g -y -s "${names[@]}" -a "${agents[@]}" || return 1
  done
  [[ -e ~/.gemini/skills ]] || ln -s ~/.agents/skills ~/.gemini/skills
  echo "Skills restored. Run go_ai_doctor to verify."
}

# ZLE widget: describe a task in plain English on the command line, press
# Ctrl-X Ctrl-A, and the line is replaced with a suggested command.
# The suggestion is never run - review it and press Enter yourself.
function _go_ai_cmd_widget() {
  setopt localoptions extendedglob
  local request="$BUFFER" suggestion
  [[ -z "$request" ]] && return 0
  zle -M "asking ${GO_AI_AGENT}..."
  zle -R
  suggestion=$(_go_ai_run "Convert this request into a single zsh command for macOS. Output only the command on one line - no explanation, no code fences, no leading \$. Request: ${request}" </dev/null 2>/dev/null)
  suggestion=${suggestion//\`\`\`(zsh|sh|bash|)/}
  suggestion=${suggestion##[[:space:]]#}
  suggestion=${suggestion%%[[:space:]]#}
  if [[ -z "$suggestion" ]]; then
    zle -M "no suggestion from ${GO_AI_AGENT}"
    return 1
  fi
  BUFFER="$suggestion"
  CURSOR=${#BUFFER}
  zle -M ""
}

if [[ -o interactive ]]; then
  zle -N _go_ai_cmd_widget
  bindkey '^X^A' _go_ai_cmd_widget
fi
