--[[
 * ReaScript Name: Add bold markup to selected items notes
 * Description: Add bold markup to selected items notes
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts (LUA): Text Items Formatting Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156757
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.3 #0
 * Version: 1.2
--]]
 
--[[
 * Changelog:
 * v1.2 (2015-07-29)
	# Better Set Notes
 * v1.1 (2015-03-03)
	+ Multiline support
	+ Prevent duplicated tags
 * v1.0 (2015-03-03)
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

function bold() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- LOOP THROUGH SELECTED ITEMS
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	-- INITIALIZE loop through selected items
	for i = 0, selected_items_count-1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		-- GET NOTES
		note = reaper.ULT_GetMediaItemNote(item)

		x, y = string.find(note, "<b>")

		if x == nil then
			
			-- MODIFY NOTES
			note = "<b>" .. note .. "</b>"
			
			-- SET NOTES
			reaper.ULT_SetMediaItemNote(item, note)

		end

	
	end -- ENDLOOP through selected items
	
	reaper.Undo_EndBlock("Add bold markup to selected items notes", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

bold() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

--msg_end() -- Display characters in the console to show you the end of the script execution.