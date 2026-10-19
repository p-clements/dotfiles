# dotfiles

Personal dotfiles for a consistent, version-controlled terminal and development environment across machines (macOS + WSL/Ubuntu).

## Contents

| Path                           | Description                                                                                              |
| ------------------------------ | -------------------------------------------------------------------------------------------------------- |
| `zshrc/.zshrc`                 | Cross-platform Zsh config — Homebrew, plugins, aliases, and functions                                    |
| `zshrc/scripts/gpullall`       | Pulls all git repos under a root directory, with interactive branch cleanup                              |
| `starship/starship.toml`       | [Starship](https://starship.rs) prompt config using the Catppuccin Macchiato theme                       |
| `ghostty/`                     | [Ghostty](https://ghostty.app) terminal themes and profiles                                              |
| `claude/settings.json`         | [Claude Code](https://claude.com/claude-code) global settings (permissions, plugins, model, status line) |
| `claude/statusline-command.sh` | Custom Claude Code status line — dir/git, model + context badge, context/usage bars                      |
| `solaar/`                      | Logitech MX Keys S key setup for Omarchy — `rules.yaml` (emoji, dictation, screenshot, lock) + `apply.sh` |
| `omarchy/`                    | Omarchy (Arch/Hyprland) customisations — Hyprland keyboard/bindings/autostart, terminals, herdr, bar config, `apply.sh` |
| `macos/herdr/`                | Mac Herdr client profile based on Omarchy, with Ctrl+B prefix and prefix+arrow pane navigation |

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

# Claude Code
ln -sfn ~/repos/dotfiles/claude/settings.json ~/.claude/settings.json
ln -sfn ~/repos/dotfiles/claude/statusline-command.sh ~/.claude/statusline-command.sh

# Solaar (Omarchy/Linux, MX Keys S) — links rules.yaml and diverts the keys
~/repos/dotfiles/solaar/apply.sh

# Herdr (macOS) — backs up the existing config and symlinks the Mac profile
bash ~/repos/dotfiles/macos/herdr/apply.sh
```

The Mac Herdr profile links `macos/herdr/config.toml` to
`~/.config/herdr/config.toml`. It keeps Omarchy's action bindings, uses
`Ctrl+B` as the prefix, and adds prefix+arrow shortcuts for pane focus.
Connect with `herdr --remote pclements@omarchy --remote-keybindings local`;
detach with `Ctrl+B`, release, then `d`. The installer can be run repeatedly.

## Omarchy (Linux) — personal settings

The [curated settings guide](omarchy/backup/README.md) explains ownership,
capture and restore. One reviewed list covers 27 personal configuration and
preference files. Omarchy defaults, installed plugins and generated state are
recreated by their owning tools; package/plugin/theme choices are reference
inventories.

```bash
bash omarchy/apply.sh pull          # preview capture
bash omarchy/apply.sh pull --apply  # capture reviewed files
bash omarchy/apply.sh               # preview restore
bash omarchy/apply.sh --apply       # restore copies, backing up replaced files
```

Restore with the graphical session logged out; review the guide first. Both
operations leave live services alone. Run `bash solaar/apply.sh` separately to
recreate MX Keys action-key diversions.

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
