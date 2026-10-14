-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Solaar: needed for the MX Keys S emoji/dictation/screenshot/lock key rules
o.launch_on_start("solaar -w hide")

-- Virtual display for Sunshine "Mac Desktop" (rule lives in monitors.lua)
o.exec_on_start("hyprctl output create headless SUNSHINE-V")
