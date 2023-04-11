--[[
 * ReaScript Name: Save mouse cursor X Y screen position relative to focused window 
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version:  1.0
 * MetaPackage: true
 * Provides:
 *   [main] . > X-Raym_Save mouse cursor X Y screen position relative to focused window_slot 1.lua
 *   [main] . > X-Raym_Save mouse cursor X Y screen position relative to focused window_slot 2.lua
 *   [main] . > X-Raym_Save mouse cursor X Y screen position relative to focused window_slot 3.lua
 *   [main] . > X-Raym_Save mouse cursor X Y screen position relative to focused window_slot 4.lua
--]]

ext_name = "XR_MousePositionsRelativeWindow"

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
  if not message then return false end
  local x, y = reaper.GetMousePosition()
  reaper.TrackCtl_SetToolTip( message, x+17, y+17, false )
end

function Msg( val )
  reaper.ShowConsoleMsg( tostring(val) .. "\n" )
end

function GetTopParent( hwnd )
  if hwnd ~= main_hwnd or main_title ~= reaper.JS_Window_GetTitle( hwnd ) then
    hwnd = GetTopParent( reaper.JS_Window_GetParent( hwnd ) )
  end
  return hwnd
end

function Init()
  reaper.ClearConsole()
  hwnd = reaper.JS_Window_GetFocus()
  if not hwnd then return false end
  
  -- NOTE: address doesnt work cause restart every time
  -- address = math.floor( reaper.JS_Window_AddressFromHandle( hwnd ) )
  -- hwnd_id = math.floor( reaper.JS_Window_GetLong( hwnd, "ID" ) )
  -- main_hwnd = reaper.GetMainHwnd()
  -- main_title = reaper.JS_Window_GetTitle( main_hwnd )
  -- hwnd_2 = GetTopParent( hwnd )
  -- hwnd_title = reaper.JS_Window_GetTitle( hwnd )
  
  x, y = reaper.GetMousePosition()
  x, y = reaper.JS_Window_ScreenToClient( hwnd, x, y )
  --reaper.SetExtState(ext_name, "hwnd_id" .. slot, hwnd_id, true)
  --reaper.SetExtState(ext_name, "hwnd_title" .. slot, hwnd_title, true)
  reaper.SetExtState(ext_name, "x" .. slot, x, true)
  reaper.SetExtState(ext_name, "y" .. slot, y, true)
  DisplayTooltip("Relative mouse position saved to slot " .. slot )
  --Msg(hwnd_title)
end

if not preset_file_init then
  Init()
end
