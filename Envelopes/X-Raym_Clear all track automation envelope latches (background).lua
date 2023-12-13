--[[
 * ReaScript Name: Clear all track automation envelope latches (background)
 * About: Workarround for JSFX not writting value if track is in Touch mode and play is stopped
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Writing automation in touch mode with JSFX GUIs doesn't work properly
 * Forum Thread https://forum.cockos.com/showthread.php?t=242479
 * REAPER: 6.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2023-12-13)
  + Initial Release
--]]
 
-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

-- Main Function (which loop in background)
function Main()
  time = reaper.time_precise()
  if time - last_time > 0.3 then
    reaper.Main_OnCommand( 42025, 0 ) -- Automation: Clear all track envelope latches
    last_time = time
  end
  reaper.defer( Main )
end

-- RUN
last_time = reaper.time_precise()
SetButtonState( 1 )
Main()
reaper.atexit( SetButtonState )
