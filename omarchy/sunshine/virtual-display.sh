#!/bin/bash
# Sunshine "Mac Desktop" prep command (proposed replacement for ~/.config/sunshine/virtual-display.sh).
#
#   on      Enable the headless SUNSHINE-V output, then disable the physical DP-1. Hyprland moves every
#           workspace to SUNSHINE-V when DP-1 goes away. Run by Sunshine *before* capture starts.
#   off     Enable DP-1, then disable SUNSHINE-V. Hyprland moves every workspace back to DP-1 when
#           SUNSHINE-V goes away (including ones created during the stream). Run by Sunshine on app quit/stop.
#   restore Local emergency button: `off`, then restart Sunshine so it forgets the "running" app
#           (otherwise the next Moonlight connect resumes without running `on`). Kicks any connected client.
#   status  Print the current layout (read-only).
#
# Both on/off are idempotent: a second call, or a call in the state it already produces, changes nothing.
# SUNSHINE-V is only ever enabled while streaming, so it can never hold workspaces 1-10 or trap the cursor
# while you are at the physical screen.
#
# A flag file ($XDG_RUNTIME_DIR/sunshine-streaming) records "a stream layout is active". monitors.lua reads
# it, so a `hyprctl reload` during a stream keeps the stream layout instead of tearing it down.
set -u

VIRT="SUNSHINE-V"
PHYS="DP-1"
VIRT_MODE="1512x982@60"
# Fixed, never moved, and not adjacent to DP-1 (0..1920): the cursor can't wander between the two in the
# short window where both are enabled. While streaming it is the only output, so its position is irrelevant
# to Sunshine/Moonlight; keeping it constant avoids changing geometry under a live Sunshine session.
VIRT_POS="4000x0"
PHYS_MODE="preferred"
PHYS_POS="0x0"
PHYS_SCALE="1"

RUNDIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
FLAG="$RUNDIR/sunshine-streaming"
PREV_WS="$RUNDIR/sunshine-prev-ws" # workspace DP-1 showed before `on`
VIRT_WS="99"                       # SUNSHINE-V's own default workspace (workspace_rule in monitors.lua)
LOG="${XDG_STATE_HOME:-$HOME/.local/state}/sunshine-virtual-display.log"
SUNSHINE_UNIT="app-dev.lizardbyte.app.Sunshine.service"
ACTION="${1:-status}"

mkdir -p "$(dirname "$LOG")" 2>/dev/null
log() { printf '%s [%s] %s\n' "$(date '+%F %T')" "$ACTION" "$*" | tee -a "$LOG" >&2; }

hypr() { timeout 5 hyprctl "$@" 2>/dev/null; }
hypr_ok() { hypr -j monitors >/dev/null; }
ev() { hypr eval "$1" >/dev/null; }
dsp() { hypr dispatch "$1" >/dev/null; }
mons() { hypr -j monitors all; }

# is_on <name>: output exists and is enabled
is_on() { mons | jq -e --arg n "$1" 'any(.[]; .name == $n and .disabled == false)' >/dev/null; }
exists() { mons | jq -e --arg n "$1" 'any(.[]; .name == $n)' >/dev/null; }
active_ws() { mons | jq -r --arg n "$1" '.[] | select(.name == $n and .disabled == false) | .activeWorkspace.id // empty'; }

# wait_until <on|off> <name>: poll up to ~5s. Monitor rules added at runtime are applied on the next
# rendered frame (MonitorRuleManager::scheduleReload -> render preChecks), not synchronously.
wait_until() {
  local want=$1 name=$2 n=50
  while ((n-- > 0)); do
    if [[ $want == on ]]; then is_on "$name" && return 0; else is_on "$name" || return 0; fi
    sleep 0.1
  done
  return 1
}

# Make sure some output is rendering, so a scheduled monitor-rule change actually gets applied.
# (DPMS enable only touches enabled outputs; it can never turn a *disabled* output on.)
wake() { dsp 'hl.dsp.dpms({ action = "enable" })'; }

focus_ws() { # focus_ws <numeric id>
  [[ ${1:-} =~ ^[0-9]+$ ]] || return 0
  dsp "hl.dsp.focus({ workspace = \"$1\" })"
}

# Move every normal workspace that is not on $1 to $1 (fallback only; Hyprland normally does this itself
# when an output is disabled). Special workspaces are skipped; named ones only with a safe name.
sweep_to() {
  local target=$1 id name sel
  hypr -j workspaces | jq -r --arg t "$target" '.[] | select(.monitor != $t) | "\(.id)\t\(.name)"' |
    while IFS=$'\t' read -r id name; do
      if [[ $name == special:* ]]; then continue
      elif [[ $id =~ ^[0-9]+$ ]]; then sel="$id"
      elif [[ $name =~ ^[A-Za-z0-9._\ -]+$ ]]; then sel="name:$name"
      else log "sweep: skipping workspace with unusual name"; continue
      fi
      dsp "hl.dsp.workspace.move({ workspace = \"$sel\", monitor = \"$target\" })"
    done
}

status() {
  echo "flag: $([[ -e $FLAG ]] && echo present || echo absent) ($FLAG)"
  mons | jq -r '.[] | "\(.name): \(if .disabled then "disabled" else "enabled at \(.x)x\(.y), workspace \(.activeWorkspace.name)" end)"'
  hypr -j workspaces | jq -r '.[] | "  ws \(.name) -> \(.monitor) (\(.windows) windows)"'
}

do_on() {
  if ! hypr_ok; then log "Hyprland not reachable; aborting"; exit 1; fi
  if [[ -e $FLAG ]] && is_on "$VIRT" && ! is_on "$PHYS"; then
    log "already in stream layout; nothing to do"; exit 0
  fi

  local was_ws
  was_ws=$(active_ws "$PHYS")
  touch "$FLAG"
  [[ $was_ws =~ ^[0-9]+$ ]] && echo "$was_ws" >"$PREV_WS"

  if ! exists "$VIRT"; then
    hypr output create headless "$VIRT" >/dev/null
    local n=30; until exists "$VIRT" || ((n-- <= 0)); do sleep 0.1; done
  fi

  wake
  ev "hl.monitor({ output = \"$VIRT\", mode = \"$VIRT_MODE\", position = \"$VIRT_POS\", scale = 1 })"
  if ! wait_until on "$VIRT"; then
    log "$VIRT did not come up; reverting to physical layout"
    rm -f "$FLAG"; do_off_inner; exit 1   # non-zero: Sunshine aborts the launch instead of streaming DP-1
  fi

  # Only now drop the physical output: there is always at least one enabled output.
  ev "hl.monitor({ output = \"$PHYS\", disabled = true })"
  if ! wait_until off "$PHYS"; then
    log "WARNING: $PHYS still enabled; moving workspaces manually"
    sweep_to "$VIRT"
  fi

  # Show on the stream whatever was on the physical screen.
  focus_ws "$was_ws"
  log "stream layout active (was on workspace ${was_ws:-?})"
}

do_off_inner() {
  # Which workspace to show on DP-1 afterwards: only change focus if we are really ending a stream
  # (DP-1 currently off). Prefer what the stream was showing, else what DP-1 showed before `on`.
  local was_ws=""
  if ! is_on "$PHYS"; then
    was_ws=$(active_ws "$VIRT")
    if [[ -z $was_ws || $was_ws == "$VIRT_WS" ]]; then
      was_ws=$(cat "$PREV_WS" 2>/dev/null)
    fi
  fi
  rm -f "$PREV_WS"

  if ! is_on "$PHYS"; then
    wake
    ev "hl.monitor({ output = \"$PHYS\", mode = \"$PHYS_MODE\", position = \"$PHYS_POS\", scale = $PHYS_SCALE })"
    if ! wait_until on "$PHYS"; then
      # Flag is already gone, so monitors.lua now describes the physical layout.
      log "$PHYS did not come up via rule; falling back to hyprctl reload"
      hypr reload >/dev/null
      wait_until on "$PHYS"
    fi
  fi

  if ! is_on "$PHYS"; then
    # Never disable the virtual output if that would leave zero outputs.
    log "ERROR: $PHYS is not enabled (unplugged?); leaving $VIRT as it is"
    return 1
  fi

  if is_on "$VIRT"; then
    # Disabling SUNSHINE-V makes Hyprland move all of its workspaces (and windows) to DP-1.
    ev "hl.monitor({ output = \"$VIRT\", disabled = true })"
    wait_until off "$VIRT" || log "WARNING: $VIRT still enabled"
  fi
  sweep_to "$PHYS"

  dsp "hl.dsp.focus({ monitor = \"$PHYS\" })"
  focus_ws "$was_ws"
  log "physical layout active (showing workspace ${was_ws:-unchanged})"
}

do_off() {
  if ! hypr_ok; then log "Hyprland not reachable; nothing to do"; rm -f "$FLAG"; exit 0; fi
  rm -f "$FLAG"
  if is_on "$PHYS" && ! is_on "$VIRT"; then
    log "already in physical layout; nothing to do"; exit 0
  fi
  do_off_inner
}

case "$ACTION" in
  on) do_on ;;
  off) do_off ;;
  restore)
    ACTION=off; ( do_off ); ACTION=restore
    log "restarting Sunshine so the next connection runs 'on' again"
    systemctl --user restart "$SUNSHINE_UNIT"
    ;;
  status) status ;;
  *) echo "usage: $0 on|off|restore|status" >&2; exit 2 ;;
esac
