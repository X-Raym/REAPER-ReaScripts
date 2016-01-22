--[[
 * ReaScript Name: Create one text item on first selected track from selected items notes
 * Description: This was created as a "glue empty items concatenating their notes", but this version works with a destination track, all kind of items, and preserve original selection
 * Instructions: Select a destination track. Select items. Execute. You can use it in Custom Action with the Delete selected items action.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Scripts (LUA): Create Text Items Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156763
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.3
 * Version: 1.5
--]]
 
--[[
 * Changelog:
 * v1.5 (2016-01-22)
	# Better item creation
 * v1.4 (2015-07-29)
	# Better Set notes
 * v1.3 (2015-25-05)
	+ Now with item color preservation
 * v1.1.1 (2015-03-11)
	# Better item selection restoration
	# First selected track as last touched
 * v1.1 (2015-03-06)
	+ Multi lines support
	+ Item selection accross multiple tracks
 * v1.0 (2015-03-02)
	+ Initial Release
--]]


-- CREATE TEXT ITEMS
-- text and color are optional
function CreateTextItem(track, position, length, text, color)
    
	local item = reaper.AddMediaItemToTrack(track)
  
	reaper.SetMediaItemInfo_Value(item, "D_POSITION", position)
	reaper.SetMediaItemInfo_Value(item, "D_LENGTH", length)
  
	if text ~= nil then
		reaper.ULT_SetMediaItemNote(item, text)
	end
  
	if color ~= nil then
		reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)
	end
  
	return item

end


function main()

	text_output = ""
	
	selected_tracks_count = reaper.CountSelectedTracks(0)

	if selected_tracks_count > 0 then

		selected_items_count = reaper.CountSelectedMediaItems(0)

		if selected_items_count > 0 then

			-- THE THING

			--track = reaper.GetSelectedTrack(0, i)
			reaper.Main_OnCommand(40914,0) -- Set first selected track as last touched track
			reaper.Main_OnCommand(40644,0) -- Implode selected items into one track
			
			track = reaper.GetLastTouchedTrack()

			selected_items_count = reaper.CountSelectedMediaItems(0) -- Get selected item on track
			
			first_item = reaper.GetSelectedMediaItem(0, 0)
			first_item_color = reaper.GetMediaItemInfo_Value(first_item, "I_CUSTOMCOLOR")
			first_item_start = reaper.GetMediaItemInfo_Value(first_item, "D_POSITION")
			
			last_item = reaper.GetSelectedMediaItem(0, selected_items_count-1)
			last_item_duration = reaper.GetMediaItemInfo_Value(last_item, "D_LENGTH")
			last_item_start = reaper.GetMediaItemInfo_Value(last_item, "D_POSITION")
			last_item_end = last_item_start + last_item_duration

			-- LOOP THROUGH SELECTED ITEMS
			for i = 0, selected_items_count-1  do
				-- GET ITEMS
				loop_item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
				loop_item_track = reaper.GetMediaItem_Track(loop_item)

				text_item = reaper.ULT_GetMediaItemNote(loop_item)
				if i == 0 then
					text_output = text_item
				else
					text_output = text_output .. "\n" .. text_item
				end
					
			end -- ENDLOOP through selected items
			--msg_stl("text_output", text_output, 1)


			reaper.Main_OnCommand(40029,0)

			--reaper.Main_OnCommand(40697, 0) -- DELETE all selected items
			reaper.Undo_BeginBlock()
			
			new_item_length = last_item_end - first_item_start
			CreateTextItem(track, first_item_start, new_item_length, text_output, first_item_color)

			reaper.Undo_EndBlock("Create one text item on first selected track from selected items notes", -1) -- End of the undo block. Leave it at the bottom of your main function.
		
		else -- no selected item
			reaper.ShowMessageBox("Select at least one item","Please",0)
		end -- if select item

	else -- no selected track
		reaper.ShowMessageBox("Select a destination track before running the script","Please",0)
	end

end


-- ITEMS
-- SAVE INITIAL SELECTED ITEMS
init_sel_items = {}
local function SaveSelectedItems (table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end

-- RESTORE INITIAL SELECTED ITEMS
local function RestoreSelectedItems (table)
	reaper.Main_OnCommand(40289, 0) -- Unselect all items
	for _, item in ipairs(table) do
		reaper.SetMediaItemSelected(item, true)
	end
end


reaper.PreventUIRefresh(1)

SaveSelectedItems(init_sel_items)

reaper.Main_OnCommand(40914, 0) -- Select first track as last touched
main() -- Execute your main function

RestoreSelectedItems(init_sel_items)

reaper.PreventUIRefresh(-1)
reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.

--[[
IDEAS
 * Make it per track (loop through selected item on track and glue on tracks)
 * Make it works with track name if take is not a empty item
]]
