--[[
 * ReaScript Name: Toggle video window opacity
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

-- USER CONFIG AREA ----------------

opacity_default = 0.5

------------------------------------

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

section = "XR_VideoWindowOpacity"
key = "toggle"

hwnd = GetWindow("Video Window")
if hwnd then

  if reaper.HasExtState( section, key ) then -- Workarround cause there is no get opacity
    opacity = tonumber( reaper.GetExtState( section, key ) )
  else
    opacity = 1
  end

  if opacity == 1 then
    opacity = opacity_default
  else
    opacity = 1
  end
  reaper.JS_Window_SetOpacity( hwnd, "ALPHA", opacity )
  reaper.SetExtState( section, key, opacity, true )
end
