#!/bin/bash
# Custom Antigravity CLI (agy) statusline
# Features: directory, git/vcs, model (+effort), version, plan tier, context remaining,
#           native .quota reset & usage %, cost & burn rate ($/h), tokens & tpm, mode/agent bar
# Enabled by "statusLine" in ~/.gemini/antigravity-cli/settings.json (not in the
# repo: that file also holds machine-specific trustedWorkspaces).

input=$(cat)
now_sec=$(date +%s)

# ---- time & formatting helpers ----
to_epoch() {
  ts="$1"
  [ -z "$ts" ] && return 1
  if command -v gdate >/dev/null 2>&1; then gdate -d "$ts" +%s 2>/dev/null && return; fi
  date -u -j -f "%Y-%m-%dT%H:%M:%S%z" "${ts/Z/+0000}" +%s 2>/dev/null && return
  python3 - "$ts" <<'PY' 2>/dev/null
import sys, datetime
s = sys.argv[1].replace('Z', '+00:00')
print(int(datetime.datetime.fromisoformat(s).timestamp()))
PY
}

fmt_time_hm() {
  epoch="$1"
  if date -r 0 +%s >/dev/null 2>&1; then date -r "$epoch" +"%H:%M"; else date -d "@$epoch" +"%H:%M"; fi
}

progress_bar() {
  pct="${1:-0}"; width="${2:-10}"
  [[ "$pct" =~ ^[0-9]+$ ]] || pct=0; ((pct<0))&&pct=0; ((pct>100))&&pct=100
  filled=$(( pct * width / 100 )); empty=$(( width - filled ))
  printf '%*s' "$filled" '' | tr ' ' '='
  printf '%*s' "$empty" '' | tr ' ' '-'
}

# ---- extract all fields with a single jq call ----
# Fields are joined with \x1f (unit separator): unlike tab, a non-whitespace
# IFS keeps empty fields, so a missing value doesn't shift the ones after it.
# The quota bucket is picked here too: 3p models (claude/gpt) use the 3p-*
# buckets, Argon its own weekly bucket, other Gemini models gemini-*.
fields=""
if command -v jq >/dev/null 2>&1; then
  fields=$(printf '%s' "$input" | jq -r '
    def s: if . == null then "" else tostring | gsub("[\n\u001f]"; " ") end;
    def n: if type == "number" then floor else null end;
    (.model.id // "") as $mid
    | (.model.display_name // .model.id // "Antigravity") as $mname
    | ("\($mid) \($mname)" | ascii_downcase) as $mlc
    | (if   $mlc | test("claude|opus|sonnet|haiku|gpt") then "3p"
       elif $mlc | test("argon") then "argon"
       else "gemini" end) as $qclass
    | (if (.quota | type) == "object" then .quota else {} end) as $q
    | (if   $qclass == "3p"    then $q["3p-5h"] // $q["3p-weekly"]
       elif $qclass == "argon" then $q["gemini-5h"] // $q["gemini-argon-wtu-weekly"] // $q["gemini-weekly"]
       else                         $q["gemini-5h"] // $q["gemini-weekly"] end
       // ([$q[] | objects | select((.disabled // false) == false)][0])) as $b
    | (.context_window.current_usage // null) as $u
    | [ (.workspace.current_dir // .cwd // ""),
        $mid, $mname, (.model.effort // ""),
        (.session_id // ""), (.conversation_id // ""), (.transcript_path // ""),
        (.version // ""), (.output_style.name // .plan_tier // ""),
        (.vcs.branch // ""), (.cycle_mode // ""), (.agent.name // ""),
        ((.subagents // []) | length),
        (.context_window.remaining_percentage | if type == "number" then (. + 0.5 | floor) else null end),
        (.context_window.context_window_size // 200000),
        (if $u then ($u.input_tokens // 0) + ($u.cache_creation_input_tokens // 0) + ($u.cache_read_input_tokens // 0) else null end),
        (if $u then ($u.input_tokens // 0) + ($u.output_tokens // 0) + ($u.cache_creation_input_tokens // 0) + ($u.cache_read_input_tokens // 0) else null end),
        (.context_window.total_input_tokens // 0), (.context_window.total_output_tokens // 0),
        (.cost.total_usd // .cost.total_cost_usd), (.cost.total_duration_ms | n),
        $qclass,
        (if $b then ((1 - ($b.remaining_fraction // 1)) * 100 | if . < 0 then 0 elif . > 100 then 100 else . end | . + 0.5 | floor) else null end),
        ($b.reset_time? // null),
        ($b.reset_time? | if type == "string" then (try (sub("\\.[0-9]+"; "") | fromdateiso8601 | floor) catch null) else null end),
        ($b.reset_in_seconds? | n)
      ] | map(s) | join("\u001f")' 2>/dev/null)
fi

IFS=$'\x1f' read -r ws_dir model_id model_name model_effort session_id conversation_id \
  transcript_path agy_version style_or_tier vcs_branch cycle_mode agent_name subagent_count \
  ctx_rem_pct ctx_size ctx_tokens usage_total input_tokens output_tokens \
  cost_usd total_duration_ms quota_class q_used_pct q_reset_str q_reset_epoch q_reset_in \
  <<< "$fields"

: "${model_name:=Antigravity}"
tilde='~'  # via a variable: bash 3.2 keeps the backslash in ${x/#p/\~}
current_dir="${ws_dir:-unknown}"
[ -n "$ws_dir" ] && current_dir="${ws_dir/#"$HOME"/$tilde}"

# Append effort to model_name if present and not already shown in display_name
if [ -n "$model_effort" ]; then
  case "$model_name" in
    *\(*\)*) ;;
    *) model_name="${model_name} (${model_effort})" ;;
  esac
fi

# ---- git / vcs branch ----
# Ask git about the workspace, not wherever agy happened to start this script.
git_branch=""
git_dir="."
[ -d "$ws_dir" ] && git_dir="$ws_dir"
if [ -n "$vcs_branch" ]; then
  git_branch="$vcs_branch"
elif git -C "$git_dir" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git -C "$git_dir" branch --show-current 2>/dev/null)
  [ -z "$git_branch" ] && git_branch=$(git -C "$git_dir" rev-parse --short HEAD 2>/dev/null)
fi

# ---- context window calculation ----
context_pct=""
context_remaining_pct=""
if [ -n "$ctx_rem_pct" ]; then
  context_remaining_pct="$ctx_rem_pct"
elif [[ "$ctx_tokens" =~ ^[0-9]+$ ]] && [[ "$ctx_size" =~ ^[0-9]+$ ]] && (( ctx_size > 0 )); then
  context_remaining_pct=$(( 100 - ctx_tokens * 100 / ctx_size ))
fi
if [[ "$context_remaining_pct" =~ ^-?[0-9]+$ ]]; then
  (( context_remaining_pct < 0 )) && context_remaining_pct=0
  (( context_remaining_pct > 100 )) && context_remaining_pct=100
  context_pct="${context_remaining_pct}%"
fi

# ---- quota reset & usage (from agy native .quota) ----
# Cached per bucket class as "<used-pct> <reset-epoch>" so a render without
# .quota still shows the last value - but only until that window resets.
session_txt=""
session_bar=""
quota_cache="/tmp/agy-statusline-quota-${USER:-default}-${quota_class:-gemini}"
q_end=""
if [ -n "$q_used_pct" ]; then
  q_end="$q_reset_epoch"
  [ -z "$q_end" ] && [ -n "$q_reset_str" ] && q_end=$(to_epoch "$q_reset_str")
  [ -z "$q_end" ] && [[ "$q_reset_in" =~ ^[0-9]+$ ]] && q_end=$(( now_sec + q_reset_in ))
  [[ "$q_end" =~ ^[0-9]+$ ]] && printf '%s %s\n' "$q_used_pct" "$q_end" > "$quota_cache" 2>/dev/null
elif [ -f "$quota_cache" ]; then
  read -r q_used_pct q_end < "$quota_cache"
fi

if [[ "$q_used_pct" =~ ^[0-9]+$ ]] && [[ "$q_end" =~ ^[0-9]+$ ]]; then
  if (( q_end > now_sec )); then
    remaining=$(( q_end - now_sec ))
    end_hm=$(fmt_time_hm "$q_end")
    if [ "$remaining" -ge 86400 ]; then
      rd=$(( remaining / 86400 ))
      rh=$(( (remaining % 86400) / 3600 ))
      session_txt="$(printf '%dd %dh until reset at %s (%d%%)' "$rd" "$rh" "$end_hm" "$q_used_pct")"
    else
      rh=$(( remaining / 3600 ))
      rm=$(( (remaining % 3600) / 60 ))
      session_txt="$(printf '%dh %dm until reset at %s (%d%%)' "$rh" "$rm" "$end_hm" "$q_used_pct")"
    fi
    session_bar=$(progress_bar "$q_used_pct" 10)
  else
    # That window has reset: its usage % no longer applies.
    rm -f "$quota_cache" 2>/dev/null
  fi
fi

# ---- cost, duration, burn rate, and token analytics ----
cost_per_hour=""
tpm=""
tot_tokens=""

# Derive elapsed session duration if total_duration_ms is not directly provided by agy
if [ -z "$total_duration_ms" ]; then
  start_sec=""
  if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    btime=$(stat -f %B "$transcript_path" 2>/dev/null)
    [[ "$btime" =~ ^[0-9]+$ ]] && (( btime > 0 )) && start_sec="$btime"
  fi
  # Only with a real id: a shared fallback key would time every session from
  # the first render after boot and drag $/h and tpm toward zero.
  sid_key=$(printf '%s' "${conversation_id:-$session_id}" | tr -cd 'a-zA-Z0-9_-')
  if [ -z "$start_sec" ] && [ -n "$sid_key" ]; then
    start_file="/tmp/agy-statusline-start-${sid_key}"
    if [ -f "$start_file" ]; then
      start_sec=$(cat "$start_file" 2>/dev/null)
    else
      start_sec="$now_sec"
      printf '%s\n' "$start_sec" > "$start_file" 2>/dev/null
    fi
  fi
  if [[ "$start_sec" =~ ^[0-9]+$ ]]; then
    elapsed_sec=$(( now_sec - start_sec ))
    (( elapsed_sec > 0 )) && total_duration_ms=$(( elapsed_sec * 1000 ))
  fi
fi

if [ -n "$cost_usd" ] && [[ "$total_duration_ms" =~ ^[0-9]+$ ]] && (( total_duration_ms > 0 )); then
  cost_per_hour=$(awk -v c="$cost_usd" -v d="$total_duration_ms" 'BEGIN { printf "%.2f", c * 3600000 / d }')
fi

if [[ "$input_tokens" =~ ^[0-9]+$ ]] && [[ "$output_tokens" =~ ^[0-9]+$ ]]; then
  tot_tokens=$(( input_tokens + output_tokens ))
  (( tot_tokens == 0 )) && [[ "$usage_total" =~ ^[0-9]+$ ]] && tot_tokens="$usage_total"
  [ "${tot_tokens:-0}" -eq 0 ] 2>/dev/null && tot_tokens=""
fi

if [ -n "$tot_tokens" ] && [[ "$total_duration_ms" =~ ^[0-9]+$ ]] && (( total_duration_ms > 0 )); then
  tpm=$(awk -v t="$tot_tokens" -v d="$total_duration_ms" 'BEGIN { printf "%.0f", t * 60000 / d }')
fi

# ---- render statusline ----
# Line 1: Core info (directory, git branch, model, agy version, plan tier/style)
printf '📁 %s' "$current_dir"
if [ -n "$git_branch" ]; then
  printf '  🌿 %s' "$git_branch"
fi
printf '  🤖 %s' "$model_name"
if [ -n "$agy_version" ]; then
  printf '  📟 v%s' "$agy_version"
fi
if [ -n "$style_or_tier" ]; then
  printf '  🎨 %s' "$style_or_tier"
fi

# Line 2: Context remaining and quota reset
if [ -n "$context_pct" ]; then
  context_bar=$(progress_bar "$context_remaining_pct" 10)
  line2="🧠 Context Remaining: ${context_pct} [${context_bar}]"
else
  line2="🧠 Context Remaining: TBD"
fi
if [ -n "$session_txt" ]; then
  line2="$line2  ⏳ ${session_txt} [${session_bar}]"
fi

# Line 3: Cost and token usage analytics
line3=""
if [[ "$cost_usd" =~ ^[0-9.]+$ ]]; then
  if [[ "$cost_per_hour" =~ ^[0-9.]+$ ]]; then
    line3="💰 \$$(printf '%.2f' "$cost_usd") (\$${cost_per_hour}/h)"
  else
    line3="💰 \$$(printf '%.2f' "$cost_usd")"
  fi
fi
if [[ "$tot_tokens" =~ ^[0-9]+$ ]]; then
  if [[ "$tpm" =~ ^[0-9.]+$ ]]; then
    tok_str="📊 ${tot_tokens} tok (${tpm} tpm)"
  else
    tok_str="📊 ${tot_tokens} tok"
  fi
  if [ -n "$line3" ]; then
    line3="$line3  $tok_str"
  else
    line3="$tok_str"
  fi
fi

# Line 4: Agy mode / agent name & subagents hint.
# Only what agy reports: a guessed default mode would often be wrong
# (e.g. agentMode "accept-edits" in settings.json).
line4=""
mode_label=""
if [ -n "$cycle_mode" ]; then
  mode_label="${cycle_mode} mode on (shift+tab to cycle)"
fi
if [ -n "$agent_name" ]; then
  mode_label="${mode_label:+${mode_label} · }agent: ${agent_name}"
fi
if [[ "$subagent_count" =~ ^[0-9]+$ ]] && (( subagent_count > 0 )); then
  line4="▸▸ ${mode_label:+${mode_label} · }${subagent_count} agent(s) (← for agents)"
elif [ -n "$mode_label" ]; then
  line4="▸▸ ${mode_label} · ← for agents"
fi

# Print lines
[ -n "$line2" ] && printf '\n%s' "$line2"
[ -n "$line3" ] && printf '\n%s' "$line3"
[ -n "$line4" ] && printf '\n%s' "$line4"
printf '\n'
