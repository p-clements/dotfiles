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
```

## Omarchy (Linux) — restoring after a reinstall

Everything specific to my Omarchy desktop lives in `omarchy/`. After a fresh Omarchy install, clone the repo and run:

```bash
~/Work/repos/dotfiles/omarchy/apply.sh   # links/copies everything below
~/Work/repos/dotfiles/solaar/apply.sh    # MX Keys S keys (needs Solaar; see below)
```

`apply.sh` moves any existing file aside as `<name>.pre-dotfiles` before linking.

**Symlinked** (edit in place; the repo is always current):

| Repo file                          | Symlink target                    | What it holds                                         |
| ---------------------------------- | --------------------------------- | ----------------------------------------------------- |
| `omarchy/hypr/input.lua`           | `~/.config/hypr/input.lua`        | Swiss French keyboard layout (`ch` / `fr`)            |
| `omarchy/hypr/bindings.lua`        | `~/.config/hypr/bindings.lua`     | Numeric-keypad workspace bindings                     |
| `omarchy/hypr/autostart.lua`       | `~/.config/hypr/autostart.lua`    | Starts Solaar hidden at login                         |
| `omarchy/foot/foot.ini`            | `~/.config/foot/foot.ini`         | GeistMono font, right-click paste, selection to both  |
| `omarchy/alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | GeistMono font                                     |
| `omarchy/kitty/kitty.conf`         | `~/.config/kitty/kitty.conf`      | GeistMono font                                        |
| `omarchy/ghostty/config`           | `~/.config/ghostty/config`        | GeistMono font (the top-level `ghostty/` dir is the macOS/WSL profile) |
| `omarchy/herdr/config.toml`        | `~/.config/herdr/config.toml`     | `agent_panel_sort = "priority"`                       |
| `starship/starship.toml`           | `~/.config/starship.toml`         | Shared prompt (see Setup above)                       |

**Copied, not linked** (the app rewrites these, which would replace a symlink). After changing one, run `omarchy/apply.sh pull` and commit:

| Repo file                                  | Copied to                                  | What it holds                                   |
| ------------------------------------------ | ------------------------------------------ | ----------------------------------------------- |
| `omarchy/shell/shell.json`                 | `~/.config/omarchy/shell.json`             | Transparent bar, Tailscale module, pinned 1Password tray icon |
| `omarchy/autostart/*.desktop`              | `~/.config/autostart/`                     | 1Password and Remmina autostart                 |

**Solaar (MX Keys S):** install `solaar`, then run `solaar/apply.sh`. It diverts the emoji, dictation, screenshot and lock keys and links `~/.config/solaar/rules.yaml`. It does not touch `Super+L`, `Super+Shift+S` or any other Omarchy default.

**Deliberately not tracked:** `hypr/monitors.lua` (experimenting with Sunshine), `git/config` (identity is `Peter` / the GitHub noreply address; set it with `git config --global`), Omarchy's own hooks, and the herdr-managed `opencode` plugin files.

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
