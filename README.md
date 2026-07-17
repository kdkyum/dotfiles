# My dotfiles

## Structure

```
dotfiles/
├── vimrc              → ~/.vimrc
├── tmux.conf          → ~/.tmux.conf
├── gitconfig          → ~/.gitconfig
├── config/
│   ├── ghostty/       → ~/.config/ghostty/
│   └── starship.toml  → ~/.config/starship.toml
├── claude/            → ~/.claude/
│   ├── settings.json
│   └── hooks/
└── local/bin/         → ~/.local/bin/
    ├── slurm-claude
    ├── slurm-top
    └── tat
```

## Install scripts

```bash
# slurm-claude
curl -fsSL https://raw.githubusercontent.com/kdkyum/dotfiles/master/local/bin/slurm-claude \
  -o ~/.local/bin/slurm-claude && chmod +x ~/.local/bin/slurm-claude
```

```bash
# slurm-top
curl -fsSL https://raw.githubusercontent.com/kdkyum/dotfiles/master/local/bin/slurm-top \
  -o ~/.local/bin/slurm-top && chmod +x ~/.local/bin/slurm-top
```

```bash
# tat
curl -fsSL https://raw.githubusercontent.com/kdkyum/dotfiles/master/local/bin/tat \
  -o ~/.local/bin/tat && chmod +x ~/.local/bin/tat
```

## dbxcli (Dropbox CLI)

The Claude artifact hook (`claude/hooks/upload-artifact-dropbox.sh`) uses
[`dbxcli`](https://github.com/dropbox/dbxcli) to upload published artifacts to
`/Apps/artifacts/`. Copy-paste to install the latest release into `~/.local/bin`
(with checksum verification, no `sudo`):

```bash
# dbxcli → ~/.local/bin/dbxcli
set -e
mkdir -p ~/.local/bin
tmp=$(mktemp -d)
ver=$(curl -sL https://api.github.com/repos/dropbox/dbxcli/releases/latest \
  | grep -o '"tag_name": *"v[^"]*"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')
base="dbxcli_${ver}_linux_amd64"
curl -sL -o "$tmp/$base.tar.gz" \
  "https://github.com/dropbox/dbxcli/releases/download/v${ver}/${base}.tar.gz"
curl -sL -o "$tmp/SHA256SUMS" \
  "https://github.com/dropbox/dbxcli/releases/download/v${ver}/SHA256SUMS"
( cd "$tmp" && grep "$base.tar.gz" SHA256SUMS | sha256sum -c - )
tar -xzf "$tmp/$base.tar.gz" -C "$tmp"
install -m 0755 "$tmp/$base/dbxcli" ~/.local/bin/dbxcli
rm -rf "$tmp"
dbxcli version
# First run prompts for Dropbox OAuth; token is stored in ~/.config/dbxcli/auth.json
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
