#!/usr/bin/env bash
# Restore (or back up) my Omarchy customisations.
#
#   ./apply.sh        link/copy the files in this folder into ~/.config
#   ./apply.sh pull   copy the live COPIED files (shell.json, autostart) back into the repo
#
# Symlinked files are edited in place, so the repo is always current.
# Copied files are ones the app rewrites itself (a symlink would be replaced),
# so run `pull` after changing them, then commit.
# Anything already at a target is moved to <name>.pre-dotfiles first.
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cfg="${XDG_CONFIG_HOME:-$HOME/.config}"

# repo path (under this folder) -> target (under ~/.config)
links=(
  "hypr/input.lua:hypr/input.lua"
  "hypr/bindings.lua:hypr/bindings.lua"
  "hypr/autostart.lua:hypr/autostart.lua"
  "foot/foot.ini:foot/foot.ini"
  "alacritty/alacritty.toml:alacritty/alacritty.toml"
  "kitty/kitty.conf:kitty/kitty.conf"
  "ghostty/config:ghostty/config"
  "herdr/config.toml:herdr/config.toml"
)

copies=(
  "shell/shell.json:omarchy/shell.json"
  "autostart/com.onepassword.OnePassword.desktop:autostart/com.onepassword.OnePassword.desktop"
  "autostart/remmina-applet.desktop:autostart/remmina-applet.desktop"
)

if [[ ${1:-} == pull ]]; then
  for pair in "${copies[@]}"; do
    cp "$cfg/${pair#*:}" "$dir/${pair%%:*}"
    echo "pulled ${pair#*:}"
  done
  exit 0
fi

stash() {
  local target=$1
  if [[ -e $target || -L $target ]]; then
    [[ -L $target && $(readlink "$target") == "$2" ]] && return 1
    mv "$target" "$target.pre-dotfiles"
  fi
  return 0
}

for pair in "${links[@]}"; do
  src="$dir/${pair%%:*}" target="$cfg/${pair#*:}"
  mkdir -p "$(dirname "$target")"
  stash "$target" "$src" && ln -sfn "$src" "$target"
  echo "linked $target"
done

for pair in "${copies[@]}"; do
  src="$dir/${pair%%:*}" target="$cfg/${pair#*:}"
  mkdir -p "$(dirname "$target")"
  if ! cmp -s "$src" "$target" 2>/dev/null; then
    [[ -e $target ]] && mv "$target" "$target.pre-dotfiles"
    cp "$src" "$target"
  fi
  echo "copied $target"
done
