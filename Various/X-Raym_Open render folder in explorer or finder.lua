--[[
 * ReaScript Name: Open render folder in explorer or finder
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Various
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1622146
 * REAPER: 7.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2024-01-10)
  + Initial Release
--]]

function Tooltip(message) -- DisplayTooltip() already taken by the GUI version
  local x, y = reaper.GetMousePosition()
  reaper.TrackCtl_SetToolTip( tostring(message), x+17, y+17, false )
end

if not reaper.CF_ShellExecute then
  reaper.MB("Missing dependency: SWS extension.\nPlease download it from http://www.sws-extension.org/", "Error", 0)
  return false
end

retval, render_path = reaper.GetSetProjectInfo_String( 0, "RENDER_FILE", "", false )
if render_path ~= "" then
  reaper.CF_ShellExecute(render_path)
else
  Tooltip( "Empty render path" )
end
