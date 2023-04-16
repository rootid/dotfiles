.PHONY: install_homebrew install_omz

SHELL := /bin/zsh

install_homebrew:
	@echo "Installing Homebrew on Mac"
	source bin/install.sh && install_homebrew
	@echo "Installation completed"

install_omz:
	@echo "Installing ZSH on mac"
	source bin/install.sh && install_omz
	@echo "Installation completed"

update_brew_bundle:
	@echo "Adding Apps/Install using brewfile"
	brew bundle --file=packages/brew/brewfile

install_python_bins:
	@echo "Installing python bins"
	pip3 install -r tools/python/requirements.txt

add_fonts:
	@echo "Adding font"
	fonts/install.sh

link_config:
	@echo "Adding/updating config"
	@stow -t ~ config -vvv

update_ssh_config:
	@echo "Adding/updating ssh config"
	@stow -t ~ ssh -vvv

update_tools:
	@echo "Updating tools shortcuts"
	@stow -t ~ tools --no-folding -vvv

unlink_tools:
	@echo "unlinking tools shortcuts"
	@stow -D tools -vvv

unlink_config:
	@echo "unlinking config shortcuts"
	@stow -D config -vvv

update_vim:
	# To update color clone repo and add color to vim/.vim/color dir and run this command
	@echo "Updating vim config"
	@stow -t ~ vim --no-folding -vvv
	mkdir -p $(HOME)/.vim-plug/plugged

unlink_vim:
	@stow -D vim

# stow test the changes first eg. stow -n -t ~ ssh -vvv
# vim: noexpandtab
