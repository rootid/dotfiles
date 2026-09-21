# dotfiles

Personal macOS dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Every file lives in this repo; Stow creates symlinks to it from `$HOME`, so
editing `~/.zshrc` edits `packages/zsh/.zshrc` here.

- [Quick start](#quick-start-new-machine)
- [Repository layout](#repository-layout)
- [Using the Makefile](#using-the-makefile)
- [Adding things](#adding-things)
  - [A new shell tool (functions / aliases)](#a-new-shell-tool-functions--aliases)
  - [A new config file (dotfile)](#a-new-config-file-dotfile)
  - [A new standalone script](#a-new-standalone-script)
  - [A Homebrew package](#a-homebrew-package)
- [Secrets (git-crypt)](#secrets-git-crypt)
- [Troubleshooting](#troubleshooting)

---

## Quick start (new machine)

```sh
# 1. Clone to ~/dotfiles (the Makefile works from any path, but
#    .my_sh_workflow puts ~/dotfiles/bin on $PATH)
git clone git@github.com:rootid/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Install the basics
make install_homebrew
brew install stow git-crypt
make update_brew_bundle          # installs everything in packages/brew/brewfile
make install_omz                 # Oh My Zsh (.zshrc depends on it)

# 3. Unlock secrets (needs your GPG key imported first)
git-crypt unlock

# 4. Preview, then link
make dry_run_stow                # simulate - shows what would be linked
make                             # = make all = link_config_files + link_tools

# 5. Optional editors
make init_vim_packages link_vim
make init_nvim

# 6. Open a new shell
exec zsh
```

> **Stow refuses to overwrite real files.** If `~/.zshrc` (or any target)
> already exists as a regular file, Stow reports a conflict and stops. Move the
> existing file aside (`mv ~/.zshrc ~/.zshrc.bak`) and rerun.

---

## Repository layout

There are **three stow roots**, and each is linked differently. Knowing which
one a file belongs in is the whole trick to this repo.

```
dotfiles/
├── packages/        # (1) one stow package per program; mirrors $HOME
│   ├── zsh/         #     .zshrc, .my_sh_workflow   -> ~/.zshrc, ~/.my_sh_workflow
│   ├── git/         #     .gitconfig, .gitignore     -> ~/.gitconfig, ~/.gitignore
│   ├── tmux/        #     .tmux.conf, .tmuxrc
│   ├── emacs/       #     .emacsrc, emacs_config/, emacs_snippets/, ...
│   ├── ssh/         #     .ssh/config
│   ├── stow/        #     .stow-global-ignore
│   ├── vim/         #     .vimrc, .vim/              (make link_vim)
│   ├── nvim/        #     nvim/                      -> ~/.config/nvim (make init_nvim)
│   ├── brew/        #     brewfile                   (not stowed; used by update_brew_bundle)
│   └── nix/         #     *.nix                      (not stowed)
├── tools/           # (2) ONE stow package; each subdir -> ~/<name>/ (real dir, file symlinks)
│   ├── git/         #     functions.sh, aliases.sh   -> ~/git/functions.sh, ...
│   ├── brew/ java/ gpg/ tmux/ utils/ ...
├── config/          # (3) ONE stow package; files   -> ~/<file>
│   └── .dns-block-*, (encrypted: .gitconfig, .taskrc, .local/, ...)
├── bin/             # scripts; added to $PATH by .my_sh_workflow (not stowed)
├── data/            # encrypted personal data (not stowed)
├── Makefile         # every stow command lives here - the source of truth
└── CLAUDE.md        # notes for AI assistants working in this repo
```

| Root | Stowed as | Example | Result in `$HOME` |
|---|---|---|---|
| `packages/<name>/` | separate package each, `--dir=packages/` | `packages/tmux/.tmux.conf` | `~/.tmux.conf` → symlink |
| `tools/` | single package `tools`, `--no-folding` | `tools/git/functions.sh` | `~/git/` real dir, `~/git/functions.sh` → symlink |
| `config/` | single package `config`, from repo root | `config/.dns-block-adult` | `~/.dns-block-adult` → symlink |

**Why `--no-folding` for `tools/`?** Without it Stow would symlink the whole
`~/git` directory to `tools/git`, and anything else written into `~/git` would
end up inside the repo. With `--no-folding`, `~/git` is a real directory and
only the individual files are links.

### How the shell is wired

```
~/.zshrc                      (packages/zsh/.zshrc)  — Oh My Zsh + env setup, kept minimal
  └── source ~/.my_sh_workflow (packages/zsh/.my_sh_workflow) — the registry
        ├── source ~/git/functions.sh   (tools/git/functions.sh)
        ├── source ~/git/aliases.sh     (tools/git/aliases.sh)
        ├── source ~/java/...           ...
        └── PATH += ~/dotfiles/bin
```

`.my_sh_workflow` is the **only** place that decides which tools get loaded.
Don't add tool-specific functions or aliases to `.zshrc`.

---

## Using the Makefile

Run `make help` to list targets. Running plain `make` runs `all`.

### Everyday

| Command | What it does |
|---|---|
| `make` / `make all` | `link_config_files` + `link_tools` — link everything normally in use |
| `make link_config_files` | Stow `config/`, then `packages/` `stow git zsh tmux emacs ssh` |
| `make link_tools` | Stow `tools/` into `$HOME` with `--no-folding` |
| `make dry_run_stow` | Simulate stowing `zsh` and `ssh` (verbose, changes nothing) |
| `make update_brew_bundle` | `brew bundle` against `packages/brew/brewfile` |

### Editors

| Command | What it does |
|---|---|
| `make init_vim_packages` | Create `.vim/pack/{colors,syntax,others}/{start,opt}` and download vim-plug |
| `make link_vim` / `make unlink_vim` | Stow / unstow `packages/vim` |
| `make init_nvim` | Stow `packages/nvim` into `~/.config` (→ `~/.config/nvim`) |

### Setup / install

| Command | What it does |
|---|---|
| `make install_homebrew` | Install Homebrew if `brew` isn't found (`bin/install.sh`) |
| `make install_omz` | Install Oh My Zsh (`bin/install.sh`) |

### Unlinking

| Command | What it does |
|---|---|
| `make unlink_tools` | **Dry run only** — shows what `stow --delete tools` would remove |
| `make unlink_config_files` | Unstow `ssh emacs tmux zsh git stow` and `config/` — the mirror of `link_config_files` |
| `make unlink_vim` | Unstow `packages/vim` |

### Org-mode (external, requires `~/Dropbox/plain_docs`)

| Command | What it does |
|---|---|
| `make link_org_sys` | Stow `projects`, `archives`, `publish`, `denote` from Dropbox; symlink `~/area` |
| `make unlink_org_sys` | Dry run of unstowing `area` |
| `make link_pvt_org_mode_snippets` | Stow `~/templates/org-mode` into `~/emacs_snippets/org-mode` |

### Tips

- **Preview first.** Any stow command can be simulated by adding
  `--simulate --verbose=5`. For a package not covered by `dry_run_stow`:
  ```sh
  stow --simulate --verbose=5 --dir=packages --target=$HOME tmux
  ```
- **Restow after moving/renaming files.** `stow -R` (restow) removes stale
  links and creates new ones in one step:
  ```sh
  stow -R --dir=packages --target=$HOME zsh
  stow -R --no-folding --target=$HOME tools
  ```
- **Linking is idempotent.** Rerunning `make link_tools` after adding a file is
  safe; already-correct links are left alone.
- **Order matters in `link_config_files`.** The `stow` package links
  `~/.stow-global-ignore` before the other packages are stowed. That file
  *replaces* Stow's built-in ignore list, which is what allows
  `packages/git/.gitignore` to be linked (Stow ignores `.gitignore` by
  default). It also means files like `README*` inside a package **will** be
  linked — don't put docs inside `tools/<name>/` or `packages/<name>/`.

---

## Adding things

### A new shell tool (functions / aliases)

Example: adding helpers for `docker`.

1. **Create the files** under `tools/<name>/`:
   ```sh
   mkdir -p tools/docker
   ```
   `tools/docker/functions.sh`:
   ```zsh
   #!/usr/bin/env zsh

   # Remove all stopped containers
   function go_docker_prune_containers() {
     docker container prune -f
   }
   ```
   `tools/docker/aliases.sh`:
   ```zsh
   #!/usr/bin/env zsh

   alias dps='docker ps'
   alias dimg='docker images'
   ```

   Conventions used across `tools/`:
   - Shebang `#!/usr/bin/env zsh`.
   - Function names are `go_<tool>_<action>` — type `go_<Tab>` to discover
     everything available.
   - Declare function-scoped variables with `local`, and quote expansions
     (`"$1"`, `"${var}"`).
   - Helper scripts a function calls (e.g. Python) can live alongside it, as in
     `tools/utils/go_get_eta.py`; reference them via `~/utils/...`.

2. **Register it** in `packages/zsh/.my_sh_workflow`:
   ```zsh
   # Docker
   source $ROOT_DIR/docker/functions.sh
   source $ROOT_DIR/docker/aliases.sh
   ```

3. **Link and reload:**
   ```sh
   make link_tools        # creates ~/docker/{functions,aliases}.sh
   exec zsh
   type go_docker_prune_containers   # verify
   ```
   `.my_sh_workflow` itself is already a symlink, so editing it needs no
   relinking — only a new shell.

**Adding to an existing tool** (e.g. a new git alias): just edit
`tools/git/aliases.sh` and run `exec zsh` (or `source ~/git/aliases.sh`). No
relink needed since the file is already linked. Only *new files* need
`make link_tools`.

**Secret tool?** If the functions contain private data (tokens, hosts, work
details), add a git-crypt pattern for it **before the first commit** — see
[Secrets](#secrets-git-crypt).

### A new config file (dotfile)

Decide where it goes:

- **Belongs to a program that already has a package** (e.g. another git or
  tmux file) → put it in that package, mirroring its path under `$HOME`.
- **A new program** → create `packages/<prog>/` mirroring `$HOME`. Example for
  `~/.config/starship.toml`:
  ```sh
  mkdir -p packages/starship/.config
  mv ~/.config/starship.toml packages/starship/.config/
  stow --simulate --verbose=3 --dir=packages --target=$HOME starship  # preview
  stow --dir=packages --target=$HOME starship
  ```
  Then add `$(STOW_LINK) starship` to `link_config_files` in the `Makefile`
  so it's linked on the next machine too.
- **A small standalone file, or anything that must be encrypted** →
  `config/` (e.g. `config/.taskrc` → `~/.taskrc`), linked by
  `make link_config_files`.

> For a directory like `~/.config`, if it doesn't exist yet Stow will
> *fold* — symlink the entire `~/.config` into the package. Create
> `~/.config` first (`mkdir -p ~/.config`) so only the subpath is linked.

### A new standalone script

Put executables in `bin/` and `chmod +x` them. `.my_sh_workflow` adds
`~/dotfiles/bin` to `$PATH`, so they're available by name in a new shell — no
stow step. Use `bin/` for things you want to run as commands; use `tools/`
functions for things that need to change the current shell (cd, env vars) or
are one-liners.

### A Homebrew package

Add it to `packages/brew/brewfile`:

```ruby
brew "ripgrep"
cask "iterm2"
```

then run `make update_brew_bundle`. To capture everything currently installed:
`brew bundle dump --force --file=packages/brew/brewfile` (review the diff before
committing).

---

## Secrets (git-crypt)

Paths listed in `.gitattributes` with `filter=git-crypt` are encrypted in the
repo and decrypted transparently in an unlocked checkout — e.g.
`config/.gitconfig`, `config/.local/**`, `config/.taskrc`, `data/**`,
`tools/toggl/**`, `tools/work/**`, `tools/workflow/**`.

```sh
git-crypt status -e     # list encrypted files
git-crypt unlock        # decrypt (needs your GPG key)
git-crypt lock          # re-encrypt the working tree
```

Wrappers live in `tools/git-crypt/functions.sh`: `go_git_crypt_init`,
`go_git_crypt_lock`, `go_git_crypt_unlock`, `go_git_crypt_add_gpg_user`,
`go_git_crypt_status`.

**Adding a secret file:**
1. Add the pattern to `.gitattributes` first:
   `tools/mytool/** filter=git-crypt diff=git-crypt`
2. Then create and commit the file.
3. Check it: `git-crypt status | grep mytool` should say `encrypted`.

If you commit the file before adding the pattern, the plaintext is already in
history — rotate the secret.

**While locked**, encrypted files are binary blobs. Don't stow or source them
(sourcing an encrypted `functions.sh` breaks shell startup). Keep encrypted
tools like `toggl` commented out in `.my_sh_workflow` on machines that stay
locked.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| `WARNING! stowing X would cause conflicts: existing target is neither a link nor a directory` | A real file is in the way. Back it up and remove it, then restow. |
| `my_sh_workflow: not sourced (run 'make link_tools'?): ...` on shell start | You registered a tool in `.my_sh_workflow` but didn't run `make link_tools` — or the file is git-crypt encrypted and the repo is locked. The shell still starts; only those helpers are missing. |
| New alias/function not available | Open a new shell (`exec zsh`); sourcing only happens at startup. |
| A link points to the wrong place / stale links after a rename | `stow -R ...` for that package (see [Tips](#tips)). |
| Encrypted-looking garbage in a file | Repo is locked — `git-crypt unlock`. |
| Find what a `$HOME` file links to | `ls -l ~/.zshrc` or `readlink ~/git/functions.sh` |
