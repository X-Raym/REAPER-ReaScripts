--[[
 * ReaScript Name: Split first selected item at edit caret position in SWS notes window
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items selection (Various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=163321
 * REAPER: 5.0
 * Version: 1.0.2
--]]

--[[
 * Changelog:
 * v1.0.2 (2025-07-30)
  # Renamed: typo in script name fix
 * v1.0.1 (2024-07-18)
  + SWS HWND 2.4.0 fix
 * v1.0 (2019-12-12)
  + Initial Release
--]]

local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "../Functions/utf8.lua")
dofile(script_path .. "../Functions/utf8data.lua")

function Msg(val)
  reaper.ShowConsoleMsg( tostring(val) .. "\n" )
end

function trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

item = reaper.GetSelectedMediaItem(0,0)
if not item then return end

notes = reaper.ULT_GetMediaItemNote( item )

local sws_notes_hwnd = reaper.JS_Window_Find( "Notes", true )
if not sws_notes_hwnd then return end

local sws_notes_edit_hwnd = reaper.JS_Window_FindChildByID(sws_notes_hwnd, 1019)
if not sws_notes_edit_hwnd then return end

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock()

local EM_GETSEL = "0x00B0"
local retval = reaper.JS_WindowMessage_Send(sws_notes_edit_hwnd, EM_GETSEL, 0,0,0,0)
local caret_pos = retval & 0xFFFF

notes_left = utf8.sub(notes, 0, caret_pos)
notes_right = utf8.sub(notes, caret_pos+1, utf8.len(notes) )
notes_right = notes_right:gsub( '^\r+', '')
notes_right = notes_right:gsub( '^\n+', '')

notes_right = trim(notes_right)
notes_left = trim(notes_left)

edit_pos = reaper.GetCursorPosition( 0 )

new_item = reaper.SplitMediaItem( item, edit_pos )

if new_item and caret_pos > 0 then
  reaper.ULT_SetMediaItemNote( item, notes_left )
  reaper.ULT_SetMediaItemNote( new_item, notes_right )

  -- Refresh SWS Notes window
  reaper.Main_OnCommand(40289,0) -- Unselect all items
  reaper.SetMediaItemSelected( new_item, true )
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_SHOWNOTESHELP"),0)
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_ITEMNOTES"),0)
end

reaper.Undo_EndBlock("Split first selected item at edit caret position in SWS notes window", 0)

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)
