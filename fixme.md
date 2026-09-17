# fixme.md

Review of the shell/config code in this dotfiles repo. Findings are grouped by
category and ordered roughly by impact within each group. Line numbers are from
the state of the repo at the time of review (branch `fix_feature`).

---

## Security

### 1. `git add .` + auto-push, with secret-exclusion depending on a not-yet-linked global ignore

- **Where:** `tools/git/functions.sh:13-22` (`go_git_save_work`), `packages/git/.gitignore:8,16`
- **Problem:** `go_git_save_work` runs `git add .` → `git commit -m "WIP"` → `git push origin $new_branch`
  with no review step. The patterns that keep secrets out (`.env`, `.envrc`) live **only** in
  `packages/git/.gitignore`, which is wired up as a *global* `core.excludesfile` (`packages/git/.gitconfig:12`).
  In any repo on a machine where `make link_config_files` hasn't run yet — or for any collaborator —
  that protection silently does not exist, and the blind `git add .` will sweep `.env` files
  straight into a pushed branch.
- **Suggested fix:** Don't rely on the global excludes for secret exclusion. Either drop the `git add .`
  in favour of `git add -u` (tracked files only), or print `git status --short` and require confirmation
  before committing. Independently, add `.env`/`.envrc` to each repo's own `.gitignore`.

### 2. Private GPG key exported to a world-readable plaintext file

- **Where:** `tools/gpg/functions.sh:44-46` (`go_gpg_export_pvt_key`)
- **Problem:** `gpg --export-secret-keys $1 > $1_pvt.key` writes the secret key into the current
  working directory using the default umask (commonly `644`), with no cleanup guidance. If the cwd
  happens to be a git repo or a synced folder (Dropbox is used elsewhere in this config), the key
  leaves the machine.
- **Suggested fix:** Create the file with restricted permissions and a fixed, non-synced destination:

  ```sh
  function go_gpg_export_pvt_key() {
    local out="${HOME}/.gnupg/$1_pvt.key"
    (umask 077 && gpg --export-secret-keys "$1" > "$out") && echo "Wrote $out (shred it after use)"
  }
  ```

### 3. `.gitattributes` git-crypt rule doesn't match the gitconfig that actually exists

- **Where:** `.gitattributes` (`config/.gitconfig filter=git-crypt`), actual file at `packages/git/.gitconfig:173-175`
- **Problem:** The encryption rule targets `config/.gitconfig`, but no such file exists. The real,
  committed gitconfig is `packages/git/.gitconfig` and is **not** covered by any git-crypt pattern,
  so its contents (real name `rootid`, email `vsinhsawant@gmail.com`) ship in plaintext. If the intent
  was for the gitconfig to be encrypted, that intent is silently not being honoured.
- **Suggested fix:** Decide which is true and make it explicit — either update `.gitattributes` to
  `packages/git/.gitconfig filter=git-crypt diff=git-crypt`, or delete the stale `config/.gitconfig`
  rule so the file's plaintext status is intentional rather than accidental. Run
  `go_git_crypt_status` after changing to confirm. Note that several other `.gitattributes` entries
  (`tools/work/**`, `tools/gcalcli/**`, `tools/task-war*/**`, `TODO-new-place/*`) also point at paths
  that don't currently exist — worth the same audit.

### 4. Unquoted expansion piped through `sudo tee` into `/etc/hosts`

- **Where:** `tools/utils/functions.sh:119-125` (`go_block_dns`)
- **Problem:** `echo $line | sudo tee -a /etc/hosts` uses an unquoted `$line`, so contents of the
  block-list file undergo word-splitting and glob expansion before being appended to a root-owned
  system file. A line containing `*` can expand to the cwd's filenames. `read line` without `-r`
  additionally mangles backslashes.
- **Suggested fix:**

  ```sh
  while IFS= read -r line; do
    [ -n "$line" ] && printf '%s\n' "$line" | sudo tee -a /etc/hosts > /dev/null
  done < "$dns_file"
  ```

### 5. Remote installers executed with no integrity verification

- **Where:** `bin/install.sh:11,14,21`
- **Problem:** `ruby -e "$(curl -fsSL …)"` and `sh -c "$(wget -O- …)"` execute whatever the remote
  endpoint returns, with no checksum or signature check. This is the conventional bootstrap pattern,
  but it is a supply-chain risk and it's worth being deliberate about it.
- **Suggested fix:** At minimum pin to a tagged release URL rather than `master`, and download to a
  file for inspection before executing. See also Correctness #6 — these URLs are stale and broken anyway.

---

## Correctness

### 1. `exit` used inside sourced shell functions — kills the interactive shell

- **Where:** `tools/utils/functions.sh:58,67` (`go_pdf_shrink`); `bin/install.sh:17` (`install_homebrew`)
- **Problem:** These are `source`d functions, not standalone scripts. `exit 1` terminates the *calling
  shell*, so a missing `ps2pdf` or a typo'd filename closes the user's terminal/tmux pane instead of
  just aborting the function. The commented-out batch loop at `tools/utils/functions.sh:47-50` makes
  this worse — the first bad file in the loop ends the session.
- **Suggested fix:** Replace every `exit N` in `tools/**/functions.sh` with `return N`. In
  `bin/install.sh:17`, the trailing `exit 0` should simply be deleted (it also prevents the Makefile's
  `source bin/install.sh && install_homebrew` from ever reporting a real status).

### 2. `go_git_save_work` never returns to the original branch

- **Where:** `tools/git/functions.sh:13-22`
- **Problem:** Line 21 prints `"Switching to branch ${old_branch} from ${new_branch}"`, but there is no
  `git checkout` after the push. The function leaves the user stranded on the `save_*` WIP branch while
  claiming to have moved them back — so the next `git commit` lands on the wrong branch.
- **Suggested fix:** Add `git checkout "${old_branch}"` before the final `echo`, and quote the variable
  expansions (`"${new_branch}"`) throughout. Consider `git push -u origin "${new_branch}"` so the
  branch tracks on first push.

### 3. Tilde in a single-quoted variable breaks every VLC helper

- **Where:** `tools/vlc/functions.sh:3`, used at lines 12 and 16
- **Problem:** `VLC='~/Applications/VLC.app/Contents/MacOS/VLC'` — tilde expansion only applies to
  literal words at parse time, never to the *result* of a parameter expansion. `$VLC` therefore resolves
  to a literal path beginning with a `~` directory that does not exist, so `open_all_mp4` and `vlc_2x`
  can never launch VLC. (`tools/zsh/aliases.sh:18` gets this right by leaving the tilde unquoted.)
- **Suggested fix:** `VLC="$HOME/Applications/VLC.app/Contents/MacOS/VLC"` and quote the usages:
  `"$VLC" --rate 2.0 --playlist-autostart "$1"`.

### 4. `go_chrome_open_vanilla` reads the wrong variable

- **Where:** `tools/utils/functions.sh:146,150`
- **Problem:** The variable is defined as `CHROME_APP` but the function invokes `"$chrome_app"`
  (lowercase, unset). The result is an empty command — the function silently does nothing.
- **Suggested fix:** `"$CHROME_APP"`.

### 5. `gl1` alias expands `$2` at definition time, not at call time

- **Where:** `tools/git/aliases.sh:15`
- **Problem:** `alias gl1="git status --porcelain | awk '{print $2}'"` is **double**-quoted, so zsh
  expands `$2` when `.my_sh_workflow` is sourced at shell startup. In an interactive shell `$2` is empty,
  so the stored alias is permanently `awk '{print }'` and never prints the filename column. Every other
  awk-bearing alias in the file correctly uses single quotes.
- **Suggested fix:** `alias gl1='git status --porcelain | awk "{print \$2}"'` — or simpler, use the
  purpose-built `git ls-files` forms already aliased nearby (`glm`, `gut`).

### 6. Homebrew/Linuxbrew bootstrap URLs are long dead

- **Where:** `bin/install.sh:11,14`
- **Problem:** Homebrew removed the Ruby installer at `Homebrew/install/master/install` years ago;
  the current installer is a bash script at `.../install/HEAD/install.sh`. `make install_homebrew`
  cannot succeed as written. The Linuxbrew line is doubly stale (Linuxbrew merged into Homebrew).
- **Suggested fix:** Replace both branches with the single current one-liner, or drop the function and
  document `brew` as a manual prerequisite (`make update_brew_bundle` already assumes brew is present).

### 7. Duplicate `Host github.com` block is unreachable

- **Where:** `packages/ssh/.ssh/config:3-11`
- **Problem:** ssh applies the **first** value obtained for each parameter across all matching `Host`
  stanzas. Since block one (lines 3-6) already sets `HostName`, `User` and `IdentityFile`, the second
  block's `rootid23` identity (lines 8-11) is dead config that will never be used.
- **Suggested fix:** Give the second account a distinct alias and use `git remote set-url` to point the
  relevant repos at it:

  ```
  Host github-rootid23
    HostName github.com
    User git
    IdentityFile ~/.ssh/rootid23
    IdentitiesOnly yes
  ```

  Also add `IdentitiesOnly yes` to the existing blocks so ssh doesn't offer every loaded agent key.
  The `Include` on line 1 is still flagged `TODO fix path` and silently does nothing — either fix or remove it.

### 8. `go_git_sync_gitignore` is path-sensitive and destructive-looking

- **Where:** `tools/git/functions.sh:8-11`
- **Problem:** `git rm -rf --cached .` operates relative to the **current directory**, not the repo root.
  Run from a subdirectory it only re-indexes that subtree, which quietly does not accomplish the
  intended "re-apply .gitignore across the repo". It also leaves the index fully unstaged if the
  follow-up `git add .` fails for any reason.
- **Suggested fix:** Anchor to the repo root and bail if not in a repo:

  ```sh
  function go_git_sync_gitignore() {
    local root; root=$(git rev-parse --show-toplevel) || return 1
    git -C "$root" rm -r --cached . && git -C "$root" add .
  }
  ```

---

## Performance

### 1. `compression = 0` disables git object compression globally

- **Where:** `packages/git/.gitconfig:4-5`
- **Problem:** This applies to *every* repo on the machine. Objects are stored and transferred
  uncompressed, inflating `.git` size and slowing clones/fetches/pushes over the network. There's no
  comment explaining the tradeoff; this setting is usually only worth it as a temporary workaround
  for a CPU-bound clone over a fast LAN.
- **Suggested fix:** Remove the line (git's default of `-1`/zlib level 6 is a good balance), or move it
  to a per-repo config if some specific large repo motivated it.

### 2. `alias python` runs a subprocess at every shell startup and freezes the path

- **Where:** `tools/zsh/aliases.sh:19`
- **Problem:** `alias python=`which python3`` uses backticks, so `which python3` executes when the
  alias is *defined* — forking a process on every new shell. Worse, the resolved path is baked in
  permanently: it won't follow a later `pyenv`/`nvm`-style switch, and if `python3` isn't on `PATH`
  yet at that point in startup, the alias silently becomes empty and `python` breaks entirely.
- **Suggested fix:** `alias python=python3` — resolution then happens at call time, with no subprocess.

### 3. Four version managers initialised eagerly on every shell start

- **Where:** `packages/zsh/.zshrc:104,109,110,116-117`
- **Problem:** `direnv hook`, `sdkman-init.sh`, `rbenv init`, and nvm + its bash completion all run
  unconditionally at startup. `sdkman-init.sh` and nvm's completion in particular are well-known
  multi-hundred-millisecond costs, paid on every single new terminal/tmux pane regardless of whether
  Java or Node is used in that session.
- **Suggested fix:** Profile first (`zmodload zsh/zprof` at the top of `.zshrc`, `zprof` at the bottom),
  then lazy-load the expensive ones behind wrapper functions that source the real init on first use.
  Dropping nvm's `bash_completion` line alone is usually a cheap win.

### 4. `PATH` entries appended repeatedly

- **Where:** `packages/zsh/.zshrc:123-124` and `140-141` (`BUN_INSTALL` block duplicated verbatim),
  plus `.local/bin` added at both line 130 (via `env`) and line 146
- **Problem:** The same directories get prepended to `PATH` more than once per shell, and because these
  are prepends rather than guarded appends, `PATH` grows on every re-source of `.zshrc`. Long duplicated
  `PATH`s slow every command lookup marginally and make debugging shadowed binaries harder.
- **Suggested fix:** Delete the duplicated bun block (lines 139-141), and add
  `typeset -U path PATH` near the top of `.zshrc` so zsh de-duplicates automatically.

---

## Style / Maintainability

### 1. ~110 lines of commented-out config carrying its own unresolved TODO

- **Where:** `packages/git/.gitconfig:48-159`
- **Problem:** A large block of commented-out aliases prefaced with `## TODO : DO clean up`. Dead
  config is hard to distinguish from active config when scanning the file, and several commented
  entries duplicate live ones above (e.g. `stat`, `user`).
- **Suggested fix:** Delete it — git history is the archive. Same applies to `packages/ssh/.ssh/config:17-20`
  and the commented `install_omz`/toggl entries elsewhere.

### 2. `go_<tool>_<action>` naming convention is documented but inconsistently applied

- **Where:** convention stated in `tools/gpg/functions.sh:1`; violated in `tools/java/functions.sh`
  (`mdi`, `keytool_list`), `tools/vlc/functions.sh` (`open_all_mp4`, `vlc_2x`, `hb_compress_video`,
  `remove_space`), `tools/utils/functions.sh` (`default_block`)
- **Problem:** The `go_` prefix is what makes these discoverable by tab-completion — it's effectively the
  namespace. Functions that skip it are both undiscoverable and at risk of colliding with real binaries
  (`remove_space`, `default_block` are generic enough to shadow or be shadowed).
- **Suggested fix:** Rename the stragglers to `go_java_dep_find`, `go_vlc_play_2x`, `go_video_compress`,
  `go_file_remove_space`, etc.

### 3. Shebangs are inconsistent and misleading on `source`d files

- **Where:** `tools/*/functions.sh` — mix of `#!/usr/bin/env zsh`, `#!/bin/sh` (`git-crypt`, `os_utils`),
  `#!/bin/bash` (`vlc`), and none at all (`gpg`, `java`, `ssh`, `emacs/aliases.sh`)
- **Problem:** None of these files are ever executed directly, so the shebang is decorative — but the
  `#!/bin/sh` ones are actively misleading, since they use `function name() {}` syntax that isn't POSIX sh.
- **Suggested fix:** Pick one (`#!/usr/bin/env zsh`, matching how they're actually sourced) and apply it
  uniformly, or drop shebangs from all of them.

### 4. `tools/nix/functions.sh` is ~90% commented reference notes

- **Where:** `tools/nix/functions.sh:10-70`
- **Problem:** One real function (`go_nix_install_macos`) followed by sixty lines of URLs and command
  snippets. This file is sourced into every interactive shell to define a single function, and the notes
  are much harder to search here than in a document.
- **Suggested fix:** Move the notes to `tools/nix/README.md` (stow won't link `.md` into `$HOME` in a way
  that matters) and keep `functions.sh` to actual functions.

### 5. Generated/backup files committed inside stowed package directories

- **Where:** `packages/emacs/emacs_config/basic.org.save.out`, `basic.org.save_1.out`,
  `packages/nvim/nvim/meta.out`, `packages/nvim/nvim/tmp.py`, `packages/zsh/.zshrc.save`,
  `packages/emacs/emacs_config/basic.org` vs `basic.el`
- **Problem:** Because stow symlinks package directories wholesale, this junk is materialised live into
  `~/.emacs.d` / `~/.config/nvim`. `packages/zsh/.zshrc.save` is a particular trap — a stale copy of the
  shell config sitting right next to the real one.
- **Suggested fix:** Delete them. Note `packages/emacs/emacs_config/basic.el` is gitignored while
  `basic.org` is tracked, implying a tangle step — that generation step should be documented in the
  Makefile rather than left implicit.

### 6. Repo cleanliness depends on a global ignore file stored in this same repo

- **Where:** `packages/git/.gitignore:14` (`*.out`) vs repo root `.gitignore`
- **Problem:** The ~8 stray `*.out` files and `.Makefile.swp` at the repo root are invisible to
  `git status` only because `core.excludesfile` points at this repo's own `packages/git/.gitignore`.
  This is circular: on a fresh machine, before `make link_config_files` has run, all that clutter
  becomes visible and commit-able. See Security #1 for the sharp edge this creates.
- **Suggested fix:** Duplicate the `*.out` / `*.swp` patterns into the repo's own `.gitignore` so the
  repo is self-contained, and delete the existing scratch files at the root.

### 7. Duplicate and empty config sections

- **Where:** `packages/git/.gitconfig:4-6` and `11-13` (two `[core]` blocks), `:14` (empty `[init]`);
  `packages/zsh/.zshrc:123-124` / `140-141` (duplicate bun block)
- **Problem:** Functionally harmless — git merges duplicate sections — but it makes the file confusing
  to read and invites contradictory settings being added to the two halves.
- **Suggested fix:** Merge each into a single block; delete the empty `[init]`.

### 8. `tools/emacs/functions.sh` is empty but still sourced

- **Where:** `tools/emacs/functions.sh` (3 blank lines), sourced at `packages/zsh/.my_sh_workflow:51`
- **Problem:** Dead file in the load path.
- **Suggested fix:** Remove the file and its `source` line, or add the intended content.

---

## Suggested order of work

1. **Correctness #1** (`exit` → `return`) — one-line change, removes the worst day-to-day failure mode.
2. **Correctness #3, #4, #5** — three broken functions/aliases, each a one-line fix.
3. **Security #1 + #2** — the two realistic paths to leaking something off the machine.
4. **Correctness #2, #7** — behaviour that silently contradicts what it prints/claims.
5. **Performance #1, #2, #4** — cheap wins, no behavioural risk.
6. Everything else as cleanup.
