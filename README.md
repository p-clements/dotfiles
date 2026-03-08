# dotfiles

Personal dotfiles for a consistent, version-controlled terminal and development environment across machines (macOS + WSL/Ubuntu).

## Contents

| Path | Description |
|------|-------------|
| `zshrc/.zshrc` | Cross-platform Zsh config — Homebrew, pyenv, plugins, aliases, and functions |
| `zshrc/scripts/gpullall` | Pulls all git repos under a root directory, with interactive branch cleanup |
| `zshrc/scripts/pip-upgrade-all` | Upgrades all outdated pip packages in the current Python environment |
| `starship/starship.toml` | [Starship](https://starship.rs) prompt config using the Catppuccin Macchiato theme |
| `ghostty/` | [Ghostty](https://ghostty.app) terminal themes and profiles |
| `warp/` | [Warp](https://warp.dev) custom themes (manual import) |

## Setup

Clone the repo:

```bash
git clone git@github.com:p-clements/dotfiles.git ~/code/repos/dotfiles
```

Symlink configs:

```bash
# Zsh
ln -sfn ~/code/repos/dotfiles/zshrc/.zshrc ~/.zshrc

# Zsh scripts
mkdir -p ~/.zsh/scripts
ln -sf ~/code/repos/dotfiles/zshrc/scripts/gpullall ~/.zsh/scripts/gpullall
ln -sf ~/code/repos/dotfiles/zshrc/scripts/pip-upgrade-all ~/.zsh/scripts/pip-upgrade-all

# Starship
ln -sfn ~/code/repos/dotfiles/starship/starship.toml ~/.config/starship.toml

# Ghostty
ln -sfn ~/code/repos/dotfiles/ghostty ~/.config/ghostty
```

Warp themes can be manually imported from `warp/` if needed.

## Additional files (not committed)

These files must be created manually on each machine — they contain machine-specific or sensitive config and are excluded via `.gitignore`.

### `~/.zshrc.local`

Sourced at the end of `.zshrc`. Use this for anything machine-specific or secret:

```bash
# Repos root for gpullall
export REPOS_ROOT="$HOME/code/repos"

# LiteLLM / Codex endpoints (work machine)
export LITELLM_API_BASE="https://..."
export OPENAI_API_KEY="sk-..."

# AWS profile
export AWS_PROFILE="default"
export AWS_DEFAULT_REGION="eu-west-1"

# Git identity (if different per machine)
export GIT_AUTHOR_EMAIL="you@example.com"
export GIT_COMMITTER_EMAIL="you@example.com"
```

## Notes

- Starship uses the `catppuccin_macchiato` palette by default. Change the palette in `starship.toml` to switch flavour.
- `gpullall` reads `REPOS_ROOT` env var if set, otherwise defaults to `~/repos`. Set it in `~/.zshrc.local` to match your machine's layout.
- Plugins (zsh-autosuggestions, zsh-syntax-highlighting) are loaded from Homebrew on macOS or `/usr/share` on Linux — install with `brew install zsh-autosuggestions zsh-syntax-highlighting` or `apt install` equivalents.
