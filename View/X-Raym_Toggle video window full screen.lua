--[[
 * ReaScript Name: Toggle video window full screen
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2020-12-13)
  # Initial release
--]]

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

if not reaper.JS_Window_SetOpacity then
  Msg("Please install JS_ReaScript REAPER extension, available in Reapack extension, under ReaTeam Extensions repository.")
  return
end

function GetWindow(name)
  local title = reaper.JS_Localize(name, "common")
  local arr = reaper.new_array({}, 1024)
  reaper.JS_Window_ArrayFind(title, true, arr)
  local adr = arr.table()
  for j = 1, #adr do
    local hwnd = reaper.JS_Window_HandleFromAddress(adr[j])
    -- verify window by checking if it also has a specific child.
    --if reaper.JS_Window_FindChildByID(hwnd, 1045) then -- 1045:ID of volume control in media explorer.
      return hwnd
    --end
  end
end

hwnd = GetWindow("Video Window")
if hwnd then
  --tval, val = reaper.BR_Win32_GetPrivateProfileString( "reaper_video", "fullscreen", "",  reaper.get_ini_file() )
  reaper.JS_WindowMessage_Send(hwnd, "WM_LBUTTONDBLCLK", 1,1,0,0)
end
