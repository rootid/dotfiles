#!/usr/bin/env zsh

# Save every tmux pane (folder + running agent) before a reboot, and rebuild
# them afterwards. Claude Code and agy panes reopen their exact conversation;
# other panes come back as a shell in the same folder.
#
#   go_tmux_save      # before rebooting
#   go_tmux_restore   # after rebooting
TMUX_SNAPSHOT_FILE=~/.tmux-snapshot.tsv

# Print the resume command for the agent running under shell PID $1, or "-".
function _go_tmux_agent_cmd() {
  local shell_pid=$1 pid ppid comm id
  ps -axo pid=,ppid=,comm= | while read -r pid ppid comm; do
    [[ $ppid == "$shell_pid" ]] || continue
    case ${comm:t} in
      claude)
        # Claude Code keeps one file per running process with its session id
        id=$(jq -r '.sessionId // empty' ~/.claude/sessions/$pid.json 2>/dev/null)
        print -r -- "claude${id:+ --resume $id}"; return
        ;;
      agy)
        # agy locks presence/<conversation-id>.lock while a conversation is open
        id=$(lsof -p $pid 2>/dev/null | grep -o 'presence/[^/]*\.lock' | head -1)
        id=${${id#presence/}%.lock}
        # No lock yet = nothing typed in it; start a fresh agy there
        print -r -- "agy${id:+ --conversation $id}"; return
        ;;
    esac
  done
  print -- "-"
}

function go_tmux_save() {
  local tmp=$TMUX_SNAPSHOT_FILE.tmp line s w name auto cwd shell_pid
  : > $tmp
  tmux list-panes -a -F $'#{session_name}\t#{window_index}\t#{window_name}\t#{automatic-rename}\t#{pane_current_path}\t#{pane_pid}' |
    while IFS=$'\t' read -r s w name auto cwd shell_pid; do
      # Keep only names you set yourself; auto names are just the command
      [[ $auto == 1 ]] && name="-"
      print -r -- "$s"$'\t'"$w"$'\t'"$name"$'\t'"$cwd"$'\t'"$(_go_tmux_agent_cmd $shell_pid)" >> $tmp
    done
  mv $tmp $TMUX_SNAPSHOT_FILE
  local panes=$(wc -l < $TMUX_SNAPSHOT_FILE | tr -d ' ')
  local agents=$(grep -cv $'\t-$' $TMUX_SNAPSHOT_FILE)
  echo "Saved $panes panes ($agents agents) to $TMUX_SNAPSHOT_FILE"
}

function go_tmux_restore() {
  [[ -r $TMUX_SNAPSHOT_FILE ]] || { echo "No snapshot at $TMUX_SNAPSHOT_FILE"; return 1; }
  local s w name cwd cmd key target
  local -A win_of skip
  while IFS=$'\t' read -r s w name cwd cmd; do
    [[ -d $cwd ]] || cwd=~
    key="$s:$w"
    if [[ -n ${win_of[$key]} ]]; then
      # Another pane in a window we already made
      target=$(tmux split-window -d -P -F '#{pane_id}' -t ${win_of[$key]} -c "$cwd")
    elif [[ -n ${skip[$s]} ]]; then
      continue
    elif ! tmux has-session -t "=$s" 2>/dev/null; then
      target=$(tmux new-session -d -P -F '#{pane_id}' -s "$s" -c "$cwd")
    elif [[ -z ${win_of[(I)$s:*]} ]]; then
      # Session existed before this restore: don't add duplicate windows
      echo "Skipping session '$s': it already exists"
      skip[$s]=1
      continue
    else
      target=$(tmux new-window -d -P -F '#{pane_id}' -t "=$s:" -c "$cwd")
    fi
    [[ -n ${win_of[$key]} ]] || win_of[$key]=$(tmux display -p -t $target '#{window_id}')
    [[ $name != "-" ]] && tmux rename-window -t $target "$name"
    [[ $cmd != "-" ]] && tmux send-keys -t $target "$cmd" Enter
  done < $TMUX_SNAPSHOT_FILE
  echo "Restored from $TMUX_SNAPSHOT_FILE. Attach with: tmux attach"
}
