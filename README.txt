# 

Install homebrew
- make install

# Install apps/cli tools using homebrew
- make update

# Configure VIM
- vim .
- !mkdir -p ~/.vim-plug/plugged
- :source %
- :PlugInstall
- make update-vim

# Update all default config
- stow -n -vvv config -t ~/

# Add fonts
- make add-fonts

# Update all aliases
- make tools

# boom
https://zachholman.com/boom/
- gem install boom

# Install java tools

# TODO
* Fix tmp_vim
* Move .vimrc to project dirs with execrc option
* Clean vimrc
* Move vim_snippet - Contains additional snippets
* Move vim_spell - To add keywords from programming language

#
# dotfiles
