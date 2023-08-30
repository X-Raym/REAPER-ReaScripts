--[[
 * ReaScript Name: Set media explorer volume up a bit
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.2
 * Provides: [main=mediaexplorer] .
--]]

--[[
 * Changelog:
 * v1.0.2 (2023-08-30)
  # More efficient GetMediaExplorer function
 * v1.0.1 (2020-12-18)
  + disable ignore mousewheel on all faders internally
 * v1.0 (2020-12-17)
  + Initial Release
--]]

val = 1
mouse_events_count = 15

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
  mouse_wheel_ignore_pref = reaper.SNM_GetIntConfigVar("mousewheelmode", -666)
  reaper.SNM_SetIntConfigVar("mousewheelmode", 0 )
  for adr in list:gmatch("%w+") do
    elm_hwnd = reaper.JS_Window_HandleFromAddress( adr )
    title = reaper.JS_Window_GetTitle( elm_hwnd )
    if title == "vol" then
      for i = 1,  15 do
        reaper.JS_WindowMessage_Send( elm_hwnd, "WM_MOUSEWHEEL", mouse_events_count,val, 0, 0 )
      end
      break
    end
  end
  reaper.SNM_SetIntConfigVar("mousewheelmode", mouse_wheel_ignore_pref )
end

if not reaper.JS_Window_ArrayFind and not reaper.SNM_GetIntConfigVar then
  reaper.ShowConsoleMsg('Please install js_ReaScriptAPI extension.\nhttps://forum.cockos.com/showthread.php?t=212174\nAnd SWS extension:\nhttps://www.sws-extension.org/')
else
  hwnd = GetMediaExplorerHWND()

  if hwnd then
    Main(hwnd)
  end
end
