--[[
 * ReaScript Name: Snap edit cursor to nearest grid if snap is enabled
 * About: For custom action usage
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > ReaScripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0 (2019-07-14)
  + Initial release
--]]

function Main()
  local pos = reaper.GetCursorPosition()
  if reaper.GetToggleCommandState( 1157 ) then
    pos = reaper.SnapToGrid( 0, pos )
  reaper.SetEditCurPos( pos, false, false )
  end
end

Main()

