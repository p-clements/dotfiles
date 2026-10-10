#!/usr/bin/env bash
# Re-apply the Logitech MX Keys S key setup (Omarchy / Linux).
# Diverts the keys that otherwise send Windows-only chords, and links the rules
# that run Omarchy commands for them. Solaar must be installed.
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p ~/.config/solaar
ln -sfn "$dir/rules.yaml" ~/.config/solaar/rules.yaml

for key in "Emoji" "Dictation" "Screen Capture" "Screen Lock"; do
  solaar config "MX Keys S" divert-keys "$key" Diverted
done

pkill -x solaar || true
setsid solaar -w hide >/dev/null 2>&1 &
