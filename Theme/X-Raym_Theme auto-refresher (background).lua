--[[
 * ReaScript Name: Theme auto-refresher (background)
 * Screenshot: https://i.imgur.com/yJnbHLQ.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Forum Thread: Script: Theme auto-refresher
 * Forum Thread URL: https://forum.cockos.com/showthread.php?p=2436611#post2436611
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-04-25)
  + Initial Release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console
refresh_rate = 0.1

------------------------------------------------------- END OF USER CONFIG AREA

if not reaper.JS_File_Stat then
  reaper.MB("Missing dependency:\nPlease install js_reascriptAPI REAPER extension available from reapack. See Reapack.com for more infos.", "Error", 1 )
  return
end

 -- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

-- Main Function (which loop in background)
function Main()

    time = reaper.time_precise()
    if time - init_time >= refresh_rate then
      local retval, size, accessedTime, modifiedTime, cTime, deviceID, deviceSpecialID, inode, mode, numLinks, ownerUserID, ownerGroupID = reaper.JS_File_Stat( rt_config_path )
      if modifiedTime ~= last_modifiedTime then
        reaper.OpenColorThemeFile(theme_path)
        reaper.UpdateArrange()
        reaper.UpdateTimeline()
        local mouse_x, mouse_y = reaper.GetMousePosition()
        reaper.TrackCtl_SetToolTip("Theme Updated: " .. modifiedTime:sub(3), mouse_x + 17, mouse_y + 17, true)
        last_modifiedTime = modifiedTime
      end
      init_time = time
    end

    reaper.defer(Main)


end

-- INIT
reaper.ClearConsole()

theme_path = reaper.GetLastColorThemeFile()
for line in io.lines(theme_path) do
  folder = line:match("ui_img=(.+)")
  if folder then
    break
  end
end

Msg("Current Theme:\n" .. theme_path)

os_sep = package.config:sub(1,1)
rt_config_path = reaper.GetResourcePath() .. os_sep .. "ColorThemes" .. os_sep .. folder .. os_sep .. "rtconfig.txt"

if not reaper.file_exists( rt_config_path ) then
  Msg("rtconfig.txt file not found.")
  return
end

Msg("Config File:\n" .. rt_config_path)
Msg("Modify and save this file to update the theme.")

init_time = reaper.time_precise()

retval, size, accessedTime, modifiedTime, cTime, deviceID, deviceSpecialID, inode, mode, numLinks, ownerUserID, ownerGroupID = reaper.JS_File_Stat( rt_config_path )
last_modifiedTime = modifiedTime

-- RUN
SetButtonState( 1 )
Main()
reaper.atexit( SetButtonState )
