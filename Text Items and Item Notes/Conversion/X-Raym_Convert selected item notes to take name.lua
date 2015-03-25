--[[
 * ReaScript Name: Convert selected item notes to take name
 * Description: Convert selected item notes to take name
 * Instructions: Select an item. Use it.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URl: http://forum.cockos.com/***.html
 * Version: v1.1
 * Version Date: 2015-03-25
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.6.0
 --]]
 
--[[
 * Changelog:
 * v1.1 (2015-03-25)
	+ bug fix (if empty item was selected)
 * v1.0 (2015-03-24)
	+ Initial Release
 --]]

--[[ ----- DEBUGGING ====>
function get_script_path()
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    return debug.getinfo(1,'S').source:match("(.*".."\\"..")"):sub(2) -- remove "@"
  end
    return debug.getinfo(1,'S').source:match("(.*".."/"..")"):sub(2)
end

package.path = package.path .. ";" .. get_script_path() .. "?.lua"
require("X-Raym_Functions - console debug messages")

debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]-- <==== DEBUGGING -----

-- From Heda's HeDa_SRT to text items.lua ====>
--[[dbug_flag = 0 -- set to 0 for no debugging messages, 1 to get them
function dbug (text) 
	if dbug_flag==1 then  
		if text then
			reaper.ShowConsoleMsg(text .. '\n')
		else
			reaper.ShowConsoleMsg("nil")
		end
	end
end]]
-- <==== From Heda's HeDa_SRT to text items.lua 

function notes_to_names() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.


	-- LOOP THROUGH SELECTED ITEMS
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	-- INITIALIZE loop through selected items
	for i = 0, selected_items_count-1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
		take = reaper.GetActiveTake(item)

		if take ~= nil then
			-- GET NOTES
			note = reaper.ULT_GetMediaItemNote(item)
			note = note:gsub("\n", " ")
			--reaper.ShowConsoleMsg(note)

			-- MODIFY TAKE
			retval, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", note, 1)
		end

	end -- ENDLOOP through selected items
	
	reaper.Undo_EndBlock("Convert selected item notes to take name", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

--[[ reaper.PreventUIRefresh(1) ]]-- Prevent UI refreshing. Uncomment it only if the script works.
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_SAVEVIEWS5"), 0) ]] -- Save view
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVELOOP5"), 0 ]]-- Save loop
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_SAVE_CURSOR_POS_SLOT_8"), 0) ]]--


notes_to_names() -- Execute your main function

--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTLOOP5"), 0) ]] -- Restore loop
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_RESTORE_CURSOR_POS_SLOT_8"), 0) ]]-- Restore current position
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_RESTIREVIEWS5"), 0) ]] -- Restore view
--[[ reaper.PreventUIRefresh(-1) ]] -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.