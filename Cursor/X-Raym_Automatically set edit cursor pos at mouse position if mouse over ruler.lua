--[[
 * ReaScript Name: Automatically set edit cursor pos at mouse position if mouse over ruler
 * Screenshot: https://i.imgur.com/UUECQNl.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Transport (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1601342
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2019-12-12)
  + Initial Release
--]]
 
 -- Set ToolBar Button State
function SetButtonState( set )
  if not set then set = 0 end
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end


-- Main Function (which loop in background)
function main()

  local window, segment, details = reaper.BR_GetMouseCursorContext()
  
  if segment == 'timeline' then
    local pos = reaper.BR_PositionAtMouseCursor( true )
    reaper.SetEditCurPos( pos, false, false )
  end
  
  reaper.defer( main )
  
end

-- RUN
SetButtonState( 1 )
main()
reaper.atexit( SetButtonState )
