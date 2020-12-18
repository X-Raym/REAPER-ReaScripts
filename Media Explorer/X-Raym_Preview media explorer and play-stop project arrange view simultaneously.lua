--[[
 * ReaScript Name: Preview media explorer and play-stop project arrange view simultaneously
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

if not reaper.JS_Window_ArrayFind then
  reaper.ShowConsoleMsg('Please Install js_ReaScriptAPI extension.\nhttps://forum.cockos.com/showthread.php?t=212174\n')
else
  hwnd = GetMediaExplorer()

  if hwnd then
    reaper.JS_Window_OnCommand(hwnd, tonumber(40024)) -- Preview: Play/stop
    reaper.Main_OnCommand(40044, 0) -- Preview: Play/stop
  end
end
