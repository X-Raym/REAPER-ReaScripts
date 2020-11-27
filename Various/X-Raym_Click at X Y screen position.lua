--[[
 * ReaScript Name: Click at X Y screen position
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version:  1.0
 * MetaPackage: true
 * Provides:
 *   [main] . > X-Raym_Click at X Y screen position_slot 1.lua
 *   [main] . > X-Raym_Click at X Y screen position_slot 2.lua
 *   [main] . > X-Raym_Click at X Y screen position_slot 3.lua
 *   [main] . > X-Raym_Click at X Y screen position_slot 4.lua
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

function Init()
  x = reaper.GetExtState(ext_name, "x" .. slot, false)
  y = reaper.GetExtState(ext_name, "y" .. slot, false)
  aaaaaaaa = x
  if x ~= "" and y ~= "" then
    x = tonumber( x )
    y = tonumber( y )
    if x and y then
      reaper.Undo_BeginBlock()
      reaper.JS_Mouse_SetPosition( x, y )
      reaper.Main_OnCommand( reaper.NamedCommandLookup( "_S&M_MOUSE_L_CLICK" ), 0 ) -- SWS/S&M: Left mouse click at cursor position (use w/o modifier)
      reaper.Undo_EndBlock("Click", -1)
    end
  end
end

if not preset_file_init then
  Init()
end
