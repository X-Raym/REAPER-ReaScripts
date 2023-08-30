--[[
 * ReaScript Name: Focus media explorer
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.2
--]]

--[[
 * Changelog:
 * v1.0.2 (2023-08-30)
  # More efficient GetMediaExplorer function
 * v1.0.1 (2020-12-17)
  # Docked support
 * v1.0 (2020-12-17)
  + Initial Release
--]]

function GetMediaExplorerHWND() -- thx ultraschall!
  local state = reaper.GetToggleCommandState( 50124 )
  if state ~= 0 then return reaper.OpenMediaExplorer( "", false ) end
end

if not reaper.JS_Window_SetFocus then
  reaper.ShowConsoleMsg('Please Install js_ReaScriptAPI extension.\nhttps://forum.cockos.com/showthread.php?t=212174\n')
else
  hwnd = GetMediaExplorerHWND()

  if hwnd then

    reaper.JS_Window_SetFocus( hwnd )
  end
end
