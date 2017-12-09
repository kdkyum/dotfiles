# My dotfiles
Install ```rcm```
```
sudo add-apt-repository ppa:martin-frost/thoughtbot-rcm
sudo apt-get update
sudo apt-get install rcm
```

Then run
```
rcup -d ~/dotfiles -x "README*.md *.sh"
```

Install ```tmux```
```
bash tmux_build_from_source_Ubuntu.sh
```

Install ```zsh```
```
chsh -s $(which zsh)
```

Install ```Vim-Plug```
```
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Install ```fzf```
```
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

Install ```zsh-plugins``
```
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
```
