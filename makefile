.PHONY: install_homebrew install_omz update_brew_bundle dry_run_stow link_config_files unlink_config_files link_tools unlink_tools link_vim unlink_vim init_vim_packages link_org_sys link_pvt_org_mode_snippets

HOME_DIR = /Users/vmat
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
	@brew bundle --file=packages/brew/brewfile

dry_run_stow:
	@stow --simulate zsh --dir=$(HOME_DIR)/dotfiles/packages/ --target=$(HOME_DIR) --verbose=5

link_config_files:
	@stow config --dir=$(HOME_DIR)/dotfiles/ --target=$(HOME_DIR) --verbose=3 # the base config file only for non packaged apps
	@stow stow --dir=$(HOME_DIR)/dotfiles/packages/ --target=$(HOME_DIR) --verbose=3
	@stow git --dir=$(HOME_DIR)/dotfiles/packages/ --target=$(HOME_DIR) --verbose=3
	@stow zsh --dir=$(HOME_DIR)/dotfiles/packages/ --target=$(HOME_DIR) --verbose=3
	@stow tmux --dir=$(HOME_DIR)/dotfiles/packages/ --target=$(HOME_DIR) --verbose=3
	@stow emacs --dir=$(HOME_DIR)/dotfiles/packages/ --target=$(HOME_DIR) --verbose=3

unlink_config_files:
	@echo "unlinking selected config files"
	@stow --delete emacs --dir=$(HOME_DIR)/dotfiles/packages/ --verbose=5 
	@stow --delete emacs-templates --dir=$(HOME_DIR)/dotfiles/packages/ --verbose=5 
	#@stow --delete emacs --dir=$(HOME_DIR)/dotfiles/packages/ --verbose=5 --simulate 

link_tools:
	@echo "Updating tools shortcuts"
	@stow tools --dir=$(HOME_DIR)/dotfiles --target=$(HOME_DIR) --no-folding --verbose=3 

unlink_tools:
	@echo "unlinking tools shortcuts"
	@stow -D tools --verbose=5 --simulate

link_vim :
	#stow --simulate vim -t ~ --dir=$(HOME_DIR)/dotfiles/packages/ --no-folding --verbose=3
	#stow --simulate vim -t ~ --dir=$(HOME_DIR)/dotfiles/packages/ --verbose=3
	@stow vim --target=$(HOME_DIR) --dir=$(HOME_DIR)/dotfiles/packages/ --verbose=3

unlink_vim :
	#@stow --simulate --delete vim --dir=$(HOME_DIR)/dotfiles/packages/ --verbose=5
	@stow --delete vim --dir=$(HOME_DIR)/dotfiles/packages/ --verbose=5

init_vim_packages:
	# To add any vim package add to either start(regular) or opt(experimental) dir 
	@echo "Move the latest repo @ top"
	# TODO - Fix the error handling by checking not continue if dir exists
	#
	mkdir -p $(HOME_DIR)/dotfiles/packages/vim/.vim/pack/{colors,syntax,others}/{start,opt} 
	@git -C $(HOME_DIR)/dotfiles/packages/vim/.vim/pack/others/start clone git@github.com:tpope/vim-obsession.git  
	@git -C $(HOME_DIR)/dotfiles/packages/vim/.vim/pack/others/start clone git@github.com:tpope/vim-repeat.git  
	@git -C $(HOME_DIR)/dotfiles/packages/vim/.vim/pack/others/start clone git@github.com:tpope/vim-abolish.git  
	@git -C $(HOME_DIR)/dotfiles/packages/vim/.vim/pack/others/start clone git@github.com:tpope/vim-fugitive.git  
	@git -C $(HOME_DIR)/dotfiles/packages/vim/.vim/pack/others/start clone git@github.com:tpope/vim-commentary.git  
	@git -C $(HOME_DIR)/dotfiles/packages/vim/.vim/pack/others/start clone git@github.com:tpope/vim-surround.git 

	#@stow --delete publish --dir=$(HOME_DIR)/plain_docs --verbose=3
	#@stow --delete projects --dir=$(HOME_DIR)/plain_docs --verbose=3
	#@stow --delete archives --dir=$(HOME_DIR)/plain_docs --verbose=3
	#@stow --delete publish --dir=$(HOME_DIR)/plain_docs --verbose=3 --simulate

unlink_org_sys:
	#@stow --delete area --dir=$(HOME_DIR)/Dropbox/plain_docs --verbose=3
	#@stow --delete others  --dir=$(HOME_DIR)/Dropbox/plain_docs/area --verbose=3
	#@stow --delete books   --dir=$(HOME_DIR)/Dropbox/plain_docs/area --verbose=3
	#@stow --delete courses  --dir=$(HOME_DIR)/Dropbox/plain_docs/area --verbose=3
	@stow --simulate area --target=$(HOME_DIR) --dir=$(HOME_DIR)/Dropbox/plain_docs --ignore='v1|journal|books|course' --verbose=3  
	#--no-folding

#courses -> Dropbox/plain_docs/area/courses

link_org_sys:
	# PreReq - first clone the plain_docs directory
	# To add any project 
	# mkdir ~/Dropbox/projects/<project_name>
	# make link_org_sys
	@stow projects --dir=$(HOME_DIR)/Dropbox/plain_docs --target=$(HOME_DIR) --verbose=3 
	@stow archives --dir=$(HOME_DIR)/Dropbox/plain_docs --target=$(HOME_DIR) --verbose=3 
	@stow publish --dir=$(HOME_DIR)/Dropbox/plain_docs --target=$(HOME_DIR) --verbose=3 
	# Keep only first level stow directories 
	#@stow --target=$(HOME_DIR) --dir=$(HOME_DIR)/Dropbox/plain_docs --ignore='jour*' area --verbose=3  
	ln -s $(HOME_DIR)/Dropbox/plain_docs/area ~/area

link_pvt_org_mode_snippets:
	@stow org-mode --dir=$(HOME_DIR)/templates/ --target=$(HOME_DIR)/emacs_snippets/org-mode --verbose=3 
# TODO: 
#stow --target=/Users/vmat/emacs_snippets/org-mode --dir=/Users/vmat/templates org-mode --verbose=3 

#install_python_bins:
#	@echo "Installing python bins"
#	pip3 install -r tools/python/requirements.txt
#
#add_fonts:
#	@echo "Adding font"
#	fonts/install.sh
#
#link_config:
#	@echo "Adding/updating config"
#	@stow -t ~ config -vvv
#
#update_ssh_config:
#	@echo "Adding/updating ssh config"
#	@stow -t ~ ssh -vvv
#
#unlink_config:
#	@echo "unlinking config shortcuts"
#	@stow -D config -vvv
#
#update_vim:
#	# To update color clone repo and add color to vim/.vim/color dir and run this command
#	@echo "Updating vim config"
#	@stow -t ~ vim --no-folding -vvv
#	mkdir -p $(HOME)/.vim-plug/plugged
#

# stow test the changes first eg. stow -n -t ~ ssh -vvv
# vim: noexpandtab
