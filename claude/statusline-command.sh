#!/usr/bin/env bash
# ~/.claude/statusline-command.sh
# Catppuccin Mocha-inspired status line for Claude Code

input=$(cat)

# ── Catppuccin Mocha palette (ANSI 24-bit) ──────────────────────────────────
RED='\033[38;2;243;139;168m'      # #f38ba8
PEACH='\033[38;2;250;179;135m'    # #fab387
YELLOW='\033[38;2;249;226;175m'   # #f9e2af
GREEN='\033[38;2;166;227;161m'    # #a6e3a1
SAPPHIRE='\033[38;2;116;199;236m' # #74c7ec
SUBTEXT1='\033[38;2;186;194;222m' # #bac2de
MAUVE='\033[38;2;203;166;247m'    # #cba6f7
PINK='\033[38;2;245;194;231m'     # #f5c2e7
OVERLAY1='\033[38;2;127;132;156m' # #7f849c
RESET='\033[0m'

# ── Data from Claude Code ────────────────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
model_id=$(echo "$input" | jq -r '.model.id // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
effort_level=$(echo "$input" | jq -r '.effort.level // empty')
thinking_enabled=$(echo "$input" | jq -r '.thinking.enabled // empty')
turn_count=$(echo "$input" | jq -r '.session.turn_count // empty')
rate_limit_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
rate_limit_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.reset_at // empty')
rate_limit_week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
rate_limit_week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.reset_at // empty')

# ── 1M-context variant badge ─────────────────────────────────────────────────
# Claude Code encodes the 1M-context beta as a "[1m]" suffix on the model id
# (e.g. "claude-sonnet-5[1m]"); display_name does not carry this, so parse id.
ctx_badge=""
case "$model_id" in
  *"[1m]"*) ctx_badge=" 1M" ;;
esac

# ── Directory: truncate to last 3 components, replace $HOME with ~ ───────────
if [ -n "$cwd" ]; then
  display_dir="${cwd/#$HOME/~}"
  # Keep at most 3 path segments
  display_dir=$(echo "$display_dir" | awk -F'/' '{
    n=NF; if(n>3){ printf "…"; for(i=n-2;i<=n;i++) printf "/"$i } else print $0
  }')
fi

# ── Git branch + status ──────────────────────────────────────────────────────
git_info=""
if git_dir=$(git -C "$cwd" rev-parse --git-dir --no-optional-locks 2>/dev/null | head -1); then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    # Collect status indicators (same symbols Starship uses)
    status_flags=""
    gitstatus=$(git -C "$cwd" status --porcelain 2>/dev/null)
    [ -n "$gitstatus" ] && status_flags="*"
    stash_count=$(git -C "$cwd" stash list 2>/dev/null | wc -l | tr -d ' ')
    [ "$stash_count" -gt 0 ] && status_flags="${status_flags}\$${stash_count}"
    ahead=$(git -C "$cwd" rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
    behind=$(git -C "$cwd" rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
    [ "$ahead" -gt 0 ]  && status_flags="${status_flags}⇡${ahead}"
    [ "$behind" -gt 0 ] && status_flags="${status_flags}⇣${behind}"

    git_info=" ${branch}${status_flags:+ $status_flags}"
  fi
fi

# ── Context bar (10 blocks) ──────────────────────────────────────────────────
ctx_display=""
if [ -n "$used_pct" ]; then
  filled=$(echo "$used_pct" | awk '{printf "%d", int($1/10 + 0.5)}')
  [ "$filled" -gt 10 ] && filled=10
  empty=$((10 - filled))
  bar=$(printf '█%.0s' $(seq 1 $filled 2>/dev/null) 2>/dev/null || python3 -c "print('█'*$filled)")
  bar_empty=$(printf '░%.0s' $(seq 1 $empty 2>/dev/null) 2>/dev/null || python3 -c "print('░'*$empty)")
  ctx_display="${bar}${bar_empty} $(printf '%.0f' "$used_pct")%"
fi

# ── Effort level ─────────────────────────────────────────────────────────────
# Sourced from .effort.level in the JSON payload. Hidden when not set or "medium" (default).
effort_display=""
if [ -n "$effort_level" ] && [ "$effort_level" != "medium" ]; then
  effort_display=" ${effort_level}"
fi

# ── Thinking mode ────────────────────────────────────────────────────────────
# Sourced from .thinking.enabled in the JSON payload. Uses nf-md-brain glyph (󰧑, U+F09D1) —
# the old codepoint here (U+F0379) was actually nf-md-monitor, not brain.
thinking_display=""
if [ "$thinking_enabled" = "true" ]; then
  thinking_display=" 󰧑"
fi

# ── Assemble ─────────────────────────────────────────────────────────────────
parts=""

# Directory segment
[ -n "$display_dir" ] && parts="${parts}$(printf "${PEACH} ${display_dir} ${RESET}")"

# Git segment
[ -n "$git_info" ] && parts="${parts}$(printf "${YELLOW}${git_info} ${RESET}")"

# Separator
[ -n "$parts" ] && parts="${parts}$(printf "${OVERLAY1}│${RESET} ")"

# Model + turn count + 1M-context badge
if [ -n "$model" ]; then
  turn_suffix=""
  [ -n "$turn_count" ] && [ "$turn_count" -gt 0 ] 2>/dev/null && turn_suffix=" ·${turn_count}"
  parts="${parts}$(printf "${SAPPHIRE}%s${RESET}\033[1m${PINK}%s${RESET}" "${model}${turn_suffix}" "$ctx_badge")"
fi

# Effort level — hidden when "medium" or absent
[ -n "$effort_display" ] && parts="${parts}$(printf "${YELLOW}${effort_display}${RESET}")"

# Thinking mode — nf-md-brain glyph
[ -n "$thinking_display" ] && parts="${parts}$(printf "${MAUVE}${thinking_display}${RESET}")"

# Context bar
if [ -n "$ctx_display" ]; then
  if [ "$(echo "$used_pct >= 80" | bc 2>/dev/null)" = "1" ]; then
    bar_color="$RED"
  elif [ "$(echo "$used_pct >= 60" | bc 2>/dev/null)" = "1" ]; then
    bar_color="$YELLOW"
  else
    bar_color="$GREEN"
  fi
  parts="${parts}$(printf " ${OVERLAY1}│${RESET} ${bar_color}%s${RESET}" "$ctx_display")"
fi

# Session (5h) usage — shown at any usage; reset time appended when >= 60%
if [ -n "$rate_limit_pct" ]; then
  rate_int=$(printf '%.0f' "$rate_limit_pct" 2>/dev/null)
  if [ -n "$rate_int" ]; then
    if [ "$rate_int" -ge 80 ] 2>/dev/null; then
      rate_color="$RED"
    elif [ "$rate_int" -ge 60 ] 2>/dev/null; then
      rate_color="$YELLOW"
    else
      rate_color="$GREEN"
    fi
    limit_str="session used:${rate_int}%"
    if [ "$rate_int" -ge 60 ] && [ -n "$rate_limit_reset" ]; then
      reset_time=$(date -d "$rate_limit_reset" +"%H:%M" 2>/dev/null \
                || date -jf "%Y-%m-%dT%H:%M:%SZ" "$rate_limit_reset" +"%H:%M" 2>/dev/null \
                || echo "")
      [ -n "$reset_time" ] && limit_str="${limit_str} resets ${reset_time}"
    fi
    parts="${parts}$(printf " ${OVERLAY1}│${RESET} ${rate_color}%s${RESET}" "$limit_str")"
  fi
fi

# Weekly (7d) usage — Claude Code only exposes session (5h) and weekly (7d)
# usage; there is no daily bucket, so this is the closest longer-horizon read.
if [ -n "$rate_limit_week_pct" ]; then
  week_int=$(printf '%.0f' "$rate_limit_week_pct" 2>/dev/null)
  if [ -n "$week_int" ]; then
    if [ "$week_int" -ge 80 ] 2>/dev/null; then
      week_color="$RED"
    elif [ "$week_int" -ge 60 ] 2>/dev/null; then
      week_color="$YELLOW"
    else
      week_color="$GREEN"
    fi
    week_str="week used:${week_int}%"
    if [ "$week_int" -ge 60 ] && [ -n "$rate_limit_week_reset" ]; then
      week_reset_time=$(date -d "$rate_limit_week_reset" +"%a %H:%M" 2>/dev/null \
                  || date -jf "%Y-%m-%dT%H:%M:%SZ" "$rate_limit_week_reset" +"%a %H:%M" 2>/dev/null \
                  || echo "")
      [ -n "$week_reset_time" ] && week_str="${week_str} resets ${week_reset_time}"
    fi
    parts="${parts}$(printf " ${OVERLAY1}│${RESET} ${week_color}%s${RESET}" "$week_str")"
  fi
fi

printf "%b" "$parts"
