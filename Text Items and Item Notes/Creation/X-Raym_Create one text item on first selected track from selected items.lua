--[[
 * ReaScript Name: Create one text item on first selected track from selected items
 * Description: Make to be used with heda's region from text items scripts, to create empty items from multiple audio samples for rendering
 * Instructions: Select a destination track. Select items. Execute.
 * Screenshot: http://i.imgur.com/YSnkn4v.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Scripts (LUA): Create Text Items Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156763
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-04-01)
	+ Initial Release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

prompt = true -- add a note right after item creation

------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems (table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end


-- Display a message in the console for debugging
function Msg(value)
	if console then
		reaper.ShowConsoleMsg(tostring(value) .. "\n")
	end
end

--------------------------------------------------------- END OF UTILITIES


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
	
	if not retval and not text_output then
		text_output = ""
	end

	track = reaper.GetSelectedTrack(0, 0) -- Get first selected track
	
	first_item = reaper.GetSelectedMediaItem(0, 0)
	first_item_color = reaper.GetMediaItemInfo_Value(first_item, "I_CUSTOMCOLOR")

	for i, item in ipairs(init_sel_items) do
		
		local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		local item_end = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") + item_pos

		if not min_pos then 
			min_pos = item_pos 
		else
			if item_pos < min_pos then min_pos = item_pos end
		end
		
		if not max_end then
			max_end = item_end
		else
			if item_end > max_end then max_end = item_end end
		end

	end
	
	new_item_length = max_end - min_pos
	
	CreateTextItem(track, min_pos, new_item_length, text_output, first_item_color)

end


-- INIT ------------------------------------------------------------------
selected_items_count = reaper.CountSelectedMediaItems(0)
selected_tracks_count = reaper.CountSelectedTracks(0)

if selected_tracks_count > 0 and selected_items_count > 0 then

	if prompt then
		retval, text_output = reaper.GetUserInputs("Item Notes", 1, "Notes?", "")
	end

	reaper.Undo_BeginBlock()

	reaper.PreventUIRefresh(1)
	
	init_sel_items = {}
	SaveSelectedItems(init_sel_items)

	main() -- Execute your main function

	reaper.PreventUIRefresh(-1)
	reaper.UpdateArrange() -- Update the arrangement (often needed)
	
	reaper.Undo_EndBlock("Create one text item on first selected track from selected items", -1) -- End of the undo block. Leave it at the bottom of your main function.

end