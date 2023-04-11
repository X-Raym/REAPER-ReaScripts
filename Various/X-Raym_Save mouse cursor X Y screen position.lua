--[[
 * ReaScript Name: Save mouse cursor X Y screen position
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version:  1.0.1
 * MetaPackage: true
 * Provides:
 *   [main] . > X-Raym_Save mouse cursor X Y screen position_slot 1.lua
 *   [main] . > X-Raym_Save mouse cursor X Y screen position_slot 2.lua
 *   [main] . > X-Raym_Save mouse cursor X Y screen position_slot 3.lua
 *   [main] . > X-Raym_Save mouse cursor X Y screen position_slot 4.lua
--]]

ext_name = "XR_MousePositions"

script_name = ({reaper.get_action_context()})[2]:match("([^/\\_]+)%.lua$")

slot = script_name:match("slot (%d+)")
if slot then
  slot = tonumber(slot)
  if slot then slot = math.max(math.min(32, slot), 1) else slot = 1 end
else
  slot = 1
end

if not reaper.JS_Window_GetFocus then
  reaper.MB('Please Install js_ReaScriptAPI extension.\nhttps://forum.cockos.com/showthread.php?t=212174\n', "Error", 1)
  return false
end

function DisplayTooltip(message)
  local x, y = reaper.GetMousePosition()
  reaper.TrackCtl_SetToolTip( message, x+17, y+17, false )
end

function Init()
  x, y = reaper.GetMousePosition()
  retval_x, x = reaper.SetExtState(ext_name, "x" .. slot, x, true)
  retval_y, y = reaper.SetExtState(ext_name, "y" .. slot, y, true)
  DisplayTooltip("Mouse position saved to slot " .. slot .. ".")
end

if not preset_file_init then
  Init()
end
