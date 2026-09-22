#!/bin/zsh

function install_homebrew() {
# Check for Homebrew
  if ! command -v brew >/dev/null 2>&1
  then
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

function install_omz() {
# curl, not wget: macOS ships curl but not wget.
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# ccusage powers the session-reset countdown line in the Claude Code
# statusline (packages/claude/.claude/statusline.sh); every other line
# degrades gracefully without it. A global install is required (not a
# one-off `npx ccusage`) because the statusline checks `command -v ccusage`.
function install_statusline_deps() {
  if ! command -v npm >/dev/null 2>&1
  then
    echo "npm not found - install Node.js first (e.g. via nvm)" >&2
    return 1
  fi
  if ! command -v ccusage >/dev/null 2>&1
  then
    echo "Installing ccusage (npm)"
    npm install -g ccusage
  fi
}

