# My dotfiles
Install ```rcm```
```
sudo add-apt-repository ppa:martin-frost/thoughtbot-rcm
sudo apt-get update
sudo apt-get install rcm
```

Then run
```
EXCLUDES="README*.md *.sh"; rcup -d ~/dotfiles -x $EXCLUDES
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
