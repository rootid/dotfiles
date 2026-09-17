# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS dotfiles managed with **GNU Stow**. There is no build/test/lint
toolchain — "correctness" here means: the right file lives in the right stow
package, and `stow` symlinks it to the right place in `$HOME`.

## Stow layout (read this before adding any file)

There are **three separate stow roots**, each stowed differently. Getting a
new file into the wrong root means it won't get linked correctly.

1. **`packages/<name>/`** — stowed with `--dir=$(DOTFILES_DIR)/packages/`.
   Each subdirectory (`zsh`, `git`, `tmux`, `emacs`, `ssh`, `vim`, `nvim`,
   `stow`, `brew`, `nix`) is an independent stow package whose contents mirror
   `$HOME` layout, e.g. `packages/zsh/.zshrc` → `~/.zshrc`,
   `packages/tmux/.tmux.conf` → `~/.tmux.conf`.
2. **`tools/<name>/`** — stowed as a *single* package (`tools`) directly from
   the repo root, target `$HOME`, with `--no-folding`. This means every
   `tools/<name>/` subdirectory becomes a real directory in `$HOME` (not a
   symlinked directory) containing symlinks to the individual files, e.g.
   `tools/git/functions.sh` → `~/git/functions.sh`. This is what lets
   `~/.my_sh_workflow` do `source ~/git/functions.sh`.
3. **`config/`** — stowed directly from the repo root (not from `packages/`),
   target `$HOME`, e.g. `config/.dns-block-adult` → `~/.dns-block-adult`.

`packages/nvim` is stowed separately into `~/.config` (see `init_nvim`
target), not `~/`.

## Shell function/alias workflow (`packages/zsh/.my_sh_workflow`)

The `.zshrc` deliberately stays minimal — it just sources
`~/.my_sh_workflow` (linked from `packages/zsh/.my_sh_workflow`). That file is
the actual registry of what gets loaded into the shell, and it works together
with the `tools/` stow package described above:

1. Create `tools/<name>/functions.sh` and/or `tools/<name>/aliases.sh` for a
   new tool.
2. Add a `source $ROOT_DIR/<name>/functions.sh` line to
   `packages/zsh/.my_sh_workflow` (`ROOT_DIR=~`, so this resolves through the
   `tools` stow symlinks described above).
3. Run `make link_tools` (and `make link_config_files` if `.my_sh_workflow`
   itself changed) so the symlinks exist before the next shell start.

Never add tool-specific logic straight into `.zshrc` — follow this
functions.sh/aliases.sh-per-tool pattern instead.

## Secrets: git-crypt

Files matching patterns in `.gitattributes` (e.g. `config/.gitconfig`,
`config/.local/**`, `config/.taskrc`, `config/.togglrc`, `data/**`,
`tools/gcalcli/**`, `tools/work/**`, `tools/workflow/**`, `tools/toggl/**`,
`tools/task-war*/**`) are transparently encrypted via `git-crypt` (filter
`git-crypt`). Helper functions for this live in `tools/git-crypt/functions.sh`
(`go_git_crypt_init`, `go_git_crypt_lock`, `go_git_crypt_unlock`,
`go_git_crypt_add_gpg_user`, `go_git_crypt_status`). Never try to view or
edit these paths as plaintext without confirming the repo is unlocked
(`git-crypt status`); some of these directories/files may not exist in a
locked checkout.

## Common commands (see `Makefile`)

- `make link_config_files` — stow `config`, then `stow`, `git`, `zsh`,
  `tmux`, `emacs`, `ssh` from `packages/`.
- `make link_tools` — stow the `tools` package (no-folding) into `$HOME`.
- `make unlink_config_files` / `make unlink_tools` — reverse the above
  (`unlink_tools` runs as a dry run / `--simulate` by default).
- `make dry_run_stow` — simulate stowing `zsh` and `ssh` (`--simulate`).
- `make init_vim_packages` / `make link_vim` / `make unlink_vim` — set up
  `packages/vim/.vim/pack/...` dirs and vim-plug, then link/unlink the vim
  package.
- `make init_nvim` — stow `packages/nvim` into `~/.config`.
- `make install_homebrew` / `make install_omz` — run the corresponding
  function in `bin/install.sh`.
- `make update_brew_bundle` — `brew bundle --file=packages/brew/brewfile`.
- `make link_org_sys` / `make unlink_org_sys` / `make link_pvt_org_mode_snippets`
  — stow Org-mode directories that live outside this repo, under
  `~/Dropbox/plain_docs` (these targets assume that path exists).
- `make help` — self-documents targets by grepping the `Makefile`.

All stow invocations in the `Makefile` are the source of truth for how a
given directory should be linked — check the relevant target before manually
running `stow`.

## Repo root scratch files

The repo root accumulates stray scratch/output files (`*.out`, `tmp.*`,
`.Makefile.swp`) from editor sessions and ad-hoc scripts; they are not part
of the intended structure. Don't treat them as configuration to maintain, and
don't assume new stray files at the root are safe to delete without checking
`git status`/content first — some may be `git-crypt`-tracked (`data/*.txt`).
