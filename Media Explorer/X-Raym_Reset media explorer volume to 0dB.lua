--[[
 * ReaScript Name: Reset media explorer volume to 0dB
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
 * Provides: [main=mediaexplorer] .
--]]
 
--[[
 * Changelog:
 * v1.0 (2020-12-17)
  + Initial Release
--]]

reaper.ClearConsole()

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

function GetMediaExplorer()
  local title = reaper.JS_Localize("Media Explorer", "common")
  local arr = reaper.new_array({}, 1024)
  reaper.JS_Window_ArrayFind(title, true, arr)
  local adr = arr.table()
  for j = 1, #adr do
    local hwnd = reaper.JS_Window_HandleFromAddress(adr[j])
    -- verify window by checking if it also has a specific child.
    if reaper.JS_Window_FindChildByID(hwnd, 1045) then -- 1045:ID of volume control in media explorer.
      return hwnd
    end 
  end
end

function Main(hwnd)
  retval, list = reaper.JS_Window_ListAllChild( hwnd )
  for adr in list:gmatch("%w+") do
    elm_hwnd = reaper.JS_Window_HandleFromAddress( adr )
    title = reaper.JS_Window_GetTitle( elm_hwnd )
    if title == "vol" then
        reaper.JS_WindowMessage_Send(      elm_hwnd, "WM_LBUTTONDBLCLK", mouse_events_count,val, 0, 0)
      break
    end
  end
end

if not reaper.JS_Window_ArrayFind then
  reaper.ShowConsoleMsg('Please Install js_ReaScriptAPI extension.\nhttps://forum.cockos.com/showthread.php?t=212174\n')
else
  hwnd = GetMediaExplorer()

  if hwnd then
    Main(hwnd)
  end
end
