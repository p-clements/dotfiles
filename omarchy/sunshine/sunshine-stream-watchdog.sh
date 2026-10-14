#!/bin/bash
# Safety net for the Sunshine "Mac Desktop" virtual display.
#
# Sunshine treats a plain Moonlight disconnect (closing the window, Mac sleep, Wi-Fi drop) as "pause":
# the app keeps running so you can resume, and its undo command (virtual-display.sh off) only runs when
# the app is quit or Sunshine stops. That is how DP-1 stayed disabled for ~39 hours after 2026-10-11 04:09.
#
# This watchdog follows Sunshine's journal. After CLIENT DISCONNECTED, if no CLIENT CONNECTED arrives
# within GRACE seconds and a stream layout is still active, it restores the physical layout and restarts
# Sunshine (which also resets its "running app", so the next connect runs `on` again).
set -u

UNIT="app-dev.lizardbyte.app.Sunshine.service"
GRACE="${SUNSHINE_RESTORE_GRACE:-300}"
VD="$HOME/.config/sunshine/virtual-display.sh"
FLAG="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/sunshine-streaming"

log() { echo "sunshine-stream-watchdog: $*"; }

stream_layout_active() {
  [[ -e $FLAG ]] && return 0
  # Also catch a stream layout left by something other than this script version.
  hyprctl -j monitors all 2>/dev/null |
    jq -e 'any(.[]; .name == "SUNSHINE-V" and .disabled == false) or any(.[]; .name == "DP-1" and .disabled == true)' >/dev/null
}

exec {jfd}< <(exec journalctl --user -f -n 0 -o cat -u "$UNIT")
log "watching $UNIT (grace ${GRACE}s)"

deadline=0
while :; do
  if ((deadline > 0)); then
    remaining=$((deadline - $(date +%s)))
    if ((remaining <= 0)); then
      deadline=0
      if stream_layout_active; then
        log "no reconnect within ${GRACE}s; restoring physical display"
        "$VD" off
        systemctl --user restart "$UNIT"
      fi
      continue
    fi
    IFS= read -r -t "$remaining" -u "$jfd" line
    rc=$?
    ((rc > 128)) && continue # timeout: loop back and fire
    ((rc != 0)) && break     # journalctl went away; systemd restarts us
  else
    IFS= read -r -u "$jfd" line || break
  fi

  case $line in
    *"Info: CLIENT DISCONNECTED"*)
      deadline=$(($(date +%s) + GRACE))
      log "client disconnected; restoring in ${GRACE}s unless it reconnects"
      ;;
    *"Info: CLIENT CONNECTED"*)
      ((deadline > 0)) && log "client reconnected; restore cancelled"
      deadline=0
      ;;
  esac
done
exit 1
