# dotfiles

Personal dotfiles for a consistent, version-controlled terminal and development environment across machines (macOS + WSL/Ubuntu).

## Contents

| Path | Description |
|------|-------------|
| `zshrc/.zshrc` | Cross-platform Zsh config — Homebrew, plugins, aliases, and functions |
| `zshrc/scripts/gpullall` | Pulls all git repos under a root directory, with interactive branch cleanup |
| `starship/starship.toml` | [Starship](https://starship.rs) prompt config using the Catppuccin Macchiato theme |
| `ghostty/` | [Ghostty](https://ghostty.app) terminal themes and profiles |

## Setup

Clone the repo:

```bash
git clone git@github.com:p-clements/dotfiles.git ~/repos/dotfiles
```

Symlink configs:

```bash
# Zsh
ln -sfn ~/repos/dotfiles/zshrc/.zshrc ~/.zshrc

# Zsh scripts
mkdir -p ~/.zsh/scripts
ln -sf ~/repos/dotfiles/zshrc/scripts/gpullall ~/.zsh/scripts/gpullall

# Starship
ln -sfn ~/repos/dotfiles/starship/starship.toml ~/.config/starship.toml

# Ghostty
ln -sfn ~/repos/dotfiles/ghostty ~/.config/ghostty
```

## Additional files (not committed)

These files must be created manually on each machine — they contain machine-specific or sensitive config and are excluded via `.gitignore`.

### `~/.zshrc.local`

Sourced at the end of `.zshrc`. Use this for anything machine-specific or secret:

```bash
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

- Plugins (zsh-autosuggestions, zsh-syntax-highlighting) are loaded from Homebrew on macOS or `/usr/share` on Linux — install with `brew install zsh-autosuggestions zsh-syntax-highlighting` or `apt install` equivalents.
