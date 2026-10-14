-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Sunshine/Moonlight virtual display for the MacBook.
-- The headless output is created in autostart.lua; ~/.config/sunshine/virtual-display.sh on/off switches
-- between the two layouts below. It writes $XDG_RUNTIME_DIR/sunshine-streaming while a stream layout is
-- active, so a `hyprctl reload` mid-stream keeps the stream layout instead of tearing it down.
-- (The flag lives in the runtime dir, so it is gone after a reboot/re-login: you always boot to DP-1.)
-- Remove this block, the autostart.lua line and ~/.config/sunshine/virtual-display.sh to undo.
local function sunshine_streaming()
  local dir = os.getenv("XDG_RUNTIME_DIR")
  if not dir then return false end
  local f = io.open(dir .. "/sunshine-streaming", "r")
  if f then f:close() return true end
  return false
end

if sunshine_streaming() then
  hl.monitor({ output = "SUNSHINE-V", mode = "1512x982@60", position = "4000x0", scale = 1 })
  hl.monitor({ output = "DP-1", disabled = true })
else
  hl.monitor({ output = "DP-1", mode = "preferred", position = "0x0", scale = 1 })
  hl.monitor({ output = "SUNSHINE-V", disabled = true })
end

-- When SUNSHINE-V is switched on it gets its own workspace instead of grabbing the lowest free number (1-10).
-- Not persistent on purpose: a persistent workspace would have to live somewhere while SUNSHINE-V is off.
hl.workspace_rule({ workspace = "99", monitor = "SUNSHINE-V", default = true })
