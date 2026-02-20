# My dotfiles

Install [`rcm`](https://github.com/thoughtbot/rcm)
```bash
# Ubuntu
sudo add-apt-repository ppa:martin-frost/thoughtbot-rcm
sudo apt-get update
sudo apt-get install rcm
```

```bash
# Mac OS X
brew tap thoughtbot/formulae
brew install rcm
```

```bash
curl -sL install-node.now.sh/lts | bash
```

Then run
```bash
rcup -d ~/dotfiles -x "README*.md *.sh"
```

Install [`tmux`](https://github.com/tmux/tmux) and [`tpm`](https://github.com/tmux-plugins/tpm)
```bash
bash tmux_build_from_source_Ubuntu.sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Install [`zsh`](https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH)
```bash
# Ubuntu
sudo apt-get install zsh
chsh -s $(which zsh)
```

```bash
# Mac OS X
brew install zsh zsh-completions
chsh -s $(which zsh)
```

Install [`Vim-Plug`](https://github.com/junegunn/vim-plug)
```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

Install [`fzf`](https://github.com/junegunn/fzf)
```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

Install [`oh-my-zsh`](https://github.com/robbyrussell/oh-my-zsh), [`zsh-plugins`](), [`powerlevel9k`](https://github.com/bhilburn/powerlevel9k), and [`sindresorhus/pure`](https://github.com/sindresorhus/pure)
```bash
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

git clone https://github.com/zdharma/fast-syntax-highlighting.git \
    $ZSH_CUSTOM/plugins/fast-syntax-highlighting


git clone https://github.com/zsh-users/zsh-autosuggestions \
    $ZSH_CUSTOM/plugins/zsh-autosuggestions

git clone https://github.com/bhilburn/powerlevel9k.git \
    ~/.oh-my-zsh/custom/themes/powerlevel9k

npm install --global pure-prompt
```

Install Powerline fonts from [`nerd-font`](https://github.com/ryanoasis/nerd-fonts)

## slurm-claude

A script to launch persistent Claude Code sessions on SLURM compute nodes using tmux.

### Setup

Add `~/dotfiles/bin` to your PATH:
```bash
export PATH="$HOME/dotfiles/bin:$PATH"
```

Create a config file at `~/.config/slurm-claude/slurm-claude.conf`:
```bash
mkdir -p ~/.config/slurm-claude
cat > ~/.config/slurm-claude/slurm-claude.conf << 'EOF'
SLURM_CLAUDE_PARTITION="h100"
SLURM_CLAUDE_ACCOUNT="aics_h100"
EOF
```

### Usage

```bash
# Default: 12h, 1 GPU, 50G RAM, 10 CPUs
slurm-claude

# Custom time and GPUs
slurm-claude -t 4-00:00 -g 2

# All options
slurm-claude -t 4-00:00 -g 2 -m 100G -c 20 -p h100sxm -a myaccount --constraint h100-nvl

# Reconnect after detach (Ctrl+B, D) or disconnect
slurm-claude --attach <JOB_ID>

# Cancel the job when done
scancel <JOB_ID>
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `-t, --time` | Run time | `12:00:00` |
| `-g, --gpus` | Number of GPUs | `1` |
| `-m, --mem` | Memory | `50G` |
| `-c, --cpus` | CPUs per task | `10` |
| `-p, --partition` | SLURM partition | `gpu` |
| `-a, --account` | SLURM account | (none) |
| `--constraint` | Node feature | (none) |
| `--attach JOB_ID` | Reattach to existing session | |
