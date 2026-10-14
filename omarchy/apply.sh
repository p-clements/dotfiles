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
  "hypr/monitors.lua:hypr/monitors.lua"
  "sunshine/virtual-display.sh:sunshine/virtual-display.sh"
  "sunshine/sunshine-stream-watchdog.sh:sunshine/sunshine-stream-watchdog.sh"
  "foot/foot.ini:foot/foot.ini"
  "alacritty/alacritty.toml:alacritty/alacritty.toml"
  "kitty/kitty.conf:kitty/kitty.conf"
  "ghostty/config:ghostty/config"
  "herdr/config.toml:herdr/config.toml"
)

copies=(
  "shell/shell.json:omarchy/shell.json"
  # Sunshine rewrites apps.json from its web UI; systemd units are copied, not symlinked, so `enable` behaves normally.
  "sunshine/apps.json:sunshine/apps.json"
  "systemd/sunshine-stream-watchdog.service:systemd/user/sunshine-stream-watchdog.service"
  "systemd/app-dev.lizardbyte.app.Sunshine.service.d/restore-display.conf:systemd/user/app-dev.lizardbyte.app.Sunshine.service.d/restore-display.conf"
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

# Not done automatically: enabling services is a deliberate step.
echo
echo "Sunshine virtual display: run once on a new machine (not while streaming):"
echo "  systemctl --user daemon-reload && systemctl --user enable --now sunshine-stream-watchdog"
echo "  systemctl --user restart app-dev.lizardbyte.app.Sunshine"
