--[[
 * ReaScript Name: Reset media explorer volume to 0dB
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.3
 * Provides: [main=mediaexplorer] .
--]]

--[[
 * Changelog:
 * v1.0.3 (2023-08-30)
  # More efficient GetMediaExplorer function
 * v1.0 (2020-12-17)
  + Initial Release
--]]

reaper.ClearConsole()

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

function GetMediaExplorerHWND() -- thx ultraschall!
  local state = reaper.GetToggleCommandState( 50124 )
  if state ~= 0 then return reaper.OpenMediaExplorer( "", false ) end
end

function Main(hwnd)
  retval, list = reaper.JS_Window_ListAllChild( hwnd )
  for adr in list:gmatch("%w+") do
    elm_hwnd = reaper.JS_Window_HandleFromAddress( adr )
    title = reaper.JS_Window_GetTitle( elm_hwnd )
    if title == "vol" then
        reaper.JS_WindowMessage_Send(      elm_hwnd, "WM_LBUTTONDBLCLK", 0,0, 0, 0)
      break
    end
  end
end

if not reaper.JS_WindowMessage_Send then
  reaper.ShowConsoleMsg('Please Install js_ReaScriptAPI extension.\nhttps://forum.cockos.com/showthread.php?t=212174\n')
else
  hwnd = GetMediaExplorerHWND()

  if hwnd then
    Main(hwnd)
  end
end
