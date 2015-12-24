--[[
 * ReaScript Name: Rename selected items active takes from REAPER MIDI notes to Kontakt notes
 * Description: Use this after the X-Raym_Analyse pitch of items on selected tracks and commit as item notes.lua script.
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: 
 * Forum Thread URI: 
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-10-02)
	+ Initial Release
 --]]

function swap() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.


	-- LOOP THROUGH SELECTED ITEMS
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	-- INITIALIZE loop through selected items
	for i = 0, selected_items_count-1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
		take = reaper.GetActiveTake(item)

		if take ~= nil then

			take_name = reaper.GetTakeName(take)
			
			note, sep, key = take_name:match("([^,]+)([%s])([^,]+)")
			
			if key ~= nil then
			
				note = tonumber(note) + 12
				note = tostring(note)
				
				sep = "_"
				
				take_name = note .. sep .. key
				
				retval, take_name = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", take_name, 1)
			
			end
			
		end

	end -- ENDLOOP through selected items
	
	reaper.Undo_EndBlock("Swap selected item notes and take name", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

swap() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
