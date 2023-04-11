--[[
 * ReaScript Name: Click at X Y screen position
 * Screenshot: https://i.imgur.com/bWsnJET.gif
 * About: Use this with the Save mouse pos toslot scripts. Useful to switch presets of VST which doesn't have other way to trigger next/previous buttons.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version:  1.0.2
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

if not reaper.JS_Window_GetFocus then
  reaper.MB('Please Install js_ReaScriptAPI extension.\nhttps://forum.cockos.com/showthread.php?t=212174\n', "Error", 1)
  return false
end

--[[
function ClickMouse(hwnd, x, y) 
  reaper.JS_WindowMessage_Post( hwnd, "WM_LBUTTONDOWN", 1, 0, x, y)
  reaper.JS_WindowMessage_Post( hwnd, "WM_LBUTTONUP", 0, 0, x, y)
end
]]

function Init()
  x = reaper.GetExtState(ext_name, "x" .. slot, false)
  y = reaper.GetExtState(ext_name, "y" .. slot, false)
  if x ~= "" and y ~= "" then
    x = tonumber( x )
    y = tonumber( y )
    if x and y then
      reaper.JS_Mouse_SetPosition( x, y )
      hwnd = reaper.JS_Window_FromPoint( x, y )
      reaper.JS_Window_SetFocus( hwnd )
      reaper.JS_Window_SetForeground( hwnd )
      --ClickMouse(hwnd, x, y)
      reaper.Main_OnCommand( reaper.NamedCommandLookup( "_S&M_MOUSE_L_CLICK" ), 0 ) -- SWS/S&M: Left mouse click at cursor position (use w/o modifier)
    end
  end
end

if not preset_file_init then
  Init()
end
