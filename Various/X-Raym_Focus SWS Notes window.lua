--[[
 * ReaScript Name: Focus SWS Notes window
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2019-12-12)
  + Initial Release
--]]

local sws_notes_hwnd = reaper.JS_Window_Find( "Notes", true )
if sws_notes_hwnd then
  local sws_notes_edit_hwnd = reaper.JS_Window_FindChildByID(sws_notes_hwnd, 1096)
  if not sws_notes_edit_hwnd then return end
  reaper.JS_Window_SetFocus( sws_notes_edit_hwnd )
end
