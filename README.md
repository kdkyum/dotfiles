# My dotfiles

## Structure

```
dotfiles/
├── vimrc
├── tmux.conf
├── gitconfig
├── config/
│   ├── ghostty/
│   └── starship.toml
├── claude/
│   ├── settings.json
│   └── hooks/
└── local/bin/
    ├── slurm-claude
    └── tat
```

## Dependencies

Install [`tmux`](https://github.com/tmux/tmux) and [`tpm`](https://github.com/tmux-plugins/tpm)
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
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

Install [`starship`](https://starship.rs/)
```bash
curl -sS https://starship.rs/install.sh | sh
```

## slurm-claude

A script to launch persistent Claude Code sessions on SLURM compute nodes using tmux.

### Setup
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
