# --- Configuration ---
# Use the HOME environment variable for portability instead of a hardcoded path.
HOME ?= $(HOME)
# Define the location of your dotfiles directory.
DOTFILES_DIR = $(HOME)/dotfiles

# Define the shell to be used for recipes.
SHELL := /bin/zsh

# --- Phony Targets ---
# .PHONY declares that these targets are not files.
# Using a multi-line declaration is cleaner and easier to maintain.
.PHONY: all clean \
	install_homebrew install_omz update_brew_bundle \
	dry_run_stow \
	link_config_files unlink_config_files \
	link_tools unlink_tools \
	init_vim_packages link_vim unlink_vim \
	link_org_sys unlink_org_sys \
	link_pvt_org_mode_snippets

# --- Base Commands ---
# Define a reusable base command for stow to keep the code DRY (Don't Repeat Yourself).
STOW = @stow --dir=$(DOTFILES_DIR)/packages/ --target=$(HOME)
STOW_DRY_RUN = $(STOW) --simulate --verbose=5
STOW_LINK = $(STOW) --verbose=3
STOW_UNLINK = $(STOW) --delete --verbose=5

# --- Main Targets ---

all: link_config_files link_tools

install_homebrew:
	@echo "Installing Homebrew on Mac..."
	@$(SHELL) -c 'source bin/install.sh && install_homebrew'
	@echo "Homebrew installation completed."

install_omz:
	@echo "Installing Oh My Zsh..."
	@$(SHELL) -c 'source bin/install.sh && install_omz'
	@echo "Oh My Zsh installation completed."

update_brew_bundle:
	@echo "Updating applications using Brewfile..."
	@brew bundle --file=$(DOTFILES_DIR)/packages/brew/brewfile

# --- Stow Operations ---

dry_run_stow:
	@echo "Performing a dry run of stow operations..."
	$(STOW_DRY_RUN) zsh
	$(STOW_DRY_RUN) ssh

link_config_files:
	@echo "Linking configuration files..."
	@stow config --dir=$(DOTFILES_DIR) --target=$(HOME) --verbose=3
	$(STOW_LINK) stow
	$(STOW_LINK) git
	$(STOW_LINK) zsh
	$(STOW_LINK) tmux
	$(STOW_LINK) emacs
	$(STOW_LINK) ssh

unlink_config_files:
	@echo "Unlinking selected config files..."
	$(STOW_UNLINK) emacs
	$(STOW_UNLINK) emacs-templates

link_tools:
	@echo "Linking tools..."
	@stow tools --dir=$(DOTFILES_DIR) --target=$(HOME) --no-folding --verbose=3

unlink_tools:
	@echo "Unlinking tools (dry run)..."
	@stow --delete tools --dir=$(DOTFILES_DIR) --target=$(HOME) --verbose=5 --simulate

# --- NeoVim Package Management ---
init_nvim:
	# brew install nvim
	# git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
	@echo "init dir structure for nvim"
	mkdir -p $(HOME)/.config
	stow --verbose=5 --dir=$(DOTFILES_DIR)/packages/ --target=$(HOME)/.config nvim 

# --- Vim Package Management ---

init_vim_packages:
	@echo "Initializing Vim package directories..."
	@mkdir -p $(DOTFILES_DIR)/packages/vim/.vim/pack/{colors,syntax,others}/{start,opt}
	@mkdir -p $(DOTFILES_DIR)/packages/vim/.vim/autoload
	@echo "Downloading vim-plug..."
	@curl -fLo $(DOTFILES_DIR)/packages/vim/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

link_vim:
	@echo "Linking Vim configuration..."
	$(STOW_LINK) vim

unlink_vim:
	@echo "Unlinking Vim configuration..."
	$(STOW_UNLINK) vim

# --- Org Mode Symlinking ---

link_org_sys:
	@echo "Linking Org mode directories..."
	@stow projects --dir=$(HOME)/Dropbox/plain_docs --target=$(HOME) --verbose=3
	@stow archives --dir=$(HOME)/Dropbox/plain_docs --target=$(HOME) --verbose=3
	@stow publish --dir=$(HOME)/Dropbox/plain_docs --target=$(HOME) --verbose=3
	@stow denote --dir=$(HOME)/Dropbox/plain_docs/area/v1 --target=$(HOME) --verbose=3
	@ln -sfn $(HOME)/Dropbox/plain_docs/area $(HOME)/area

unlink_org_sys:
	@echo "Unlinking Org mode directories (dry run)..."
	@stow --simulate area --target=$(HOME) --dir=$(HOME)/Dropbox/plain_docs --ignore='v1|journal|books|course' --verbose=3

link_pvt_org_mode_snippets:
	@echo "Linking private Org mode snippets..."
	@stow org-mode --dir=$(HOME)/templates/ --target=$(HOME)/emacs_snippets/org-mode --verbose=3

clean:
	@echo "This is a placeholder for a clean command."

# --- Makefile self-documentation ---
help:
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?$$"}; {printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/@[^ ]* //g'


# vim: set noexpandtab:
