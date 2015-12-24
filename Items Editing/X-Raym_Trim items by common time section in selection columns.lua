--[[
 * ReaScript Name: Trim items by common time section in selection columns
 * Description: Select item. Run. It will trim items based on their position in selection per track (firsts selected items on selected track together, seconds together etc...)
 * Instructions: Select items. Run. If an item is not un a column, it will not be trimmed. Not that it is column selection, not visual columns.
 * Screenshot: http://i.giphy.com/3o85xp8hhYNwGy76bm.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (Lua): Shuffle Items
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=159961
 * REAPER: 5.0
 * Extensions: SWS 2.8.1.
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-10-20)
	+ Initial Release
 --]]

-- INIT
count_sel_items_on_track = {}

-------------------------------------------------------------
function CountSelectedItems_OnTrack(track)
	
	count_items_on_track = reaper.CountTrackMediaItems(track)
	
	selected_item_on_track = 0
	
	for i = 0, count_items_on_track - 1  do

		item = reaper.GetTrackMediaItem(track, i)

		if reaper.IsMediaItemSelected(item) == true then
			selected_item_on_track = selected_item_on_track + 1
		end	

	end
	
	return selected_item_on_track

end

-------------------------------------------------------------
function GetSelectedItems_OnTrack(track_sel_id, idx)
	
	--track = reaper.GetSelectedTrack(0, track_sel_id)
	--msg("Track_sel_id = "..track_sel_id)
	--msg("idx = "..idx)
	--msg("sel_items_on_track = "..count_sel_items_on_track[ track_sel_id ])
	
	if idx < count_sel_items_on_track[ track_sel_id ] then
		offset = 0
		for m = 0, track_sel_id do
			----msg("m = "..m)
			previous_track_sel = count_sel_items_on_track[ m-1 ]
			if previous_track_sel == nil then previous_track_sel = 0 end
			offset =  offset + previous_track_sel
		end
		--msg("offset = "..offset)
		get_sel_item = init_sel_items[ offset + idx + 1]
	else
		get_sel_item = nil
	end
	
	return get_sel_item

end

-------------------------------------------------------------
function SelectTracksOfSelectedItems()

	-- LOOP THROUGH SELECTED ITEMS
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	-- INITIALIZE loop through selected items
	-- Select tracks with selected items
	for i = 0, selected_items_count - 1  do
		
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		-- GET ITEM PARENT TRACK AND SELECT IT
		track = reaper.GetMediaItem_Track(item)
		reaper.SetTrackSelected(track, true)
		
	end -- ENDLOOP through selected items

end

-------------------------------------------------------------
function MaxValTable(table)
	
	max_val = 0
	
	for i = 0, #table do
	
		val = table[i]
		if val > max_val then 
			max_val = val 
		end
	
	end
	
	return max_val

end
-------------------------------------------------------------
function debug(table)
	
	for i = 1, #table do

		msg("Val = " .. i .. "=>"..reaper.ULT_GetMediaItemNote(table[i]))
	
	end
	
	return max_val

end
-------
function msg(variable)		
		reaper.ShowConsoleMsg(tostring(variable).."\n")
end

-------------------------------------------------------------
function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	--reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
	UnselectAllTracks()

	SelectTracksOfSelectedItems()

	selected_tracks_count = reaper.CountSelectedTracks(0)

		-- LOOP TRHOUGH SELECTED TRACKS
	for i = 0, selected_tracks_count - 1  do
		
		-- GET THE TRACK
		track = reaper.GetSelectedTrack(0, i) -- Get selected track i

		-- LOOP THROUGH ITEM IDX
		count_sel_items_on_track[i] = CountSelectedItems_OnTrack(track)
		
	end -- ENDLOOP through selected tracks
	
	
	-- MAXIMUM OF ITEM SELECTED ON A TRACK
	max_sel_item_on_track = MaxValTable(count_sel_items_on_track)
	
	--debug(init_sel_items)
	
	-- LOOP COLUMN OF ITEMS ON TRACK
	for j = 0, max_sel_item_on_track - 1 do
	
		-- LOOP TRHOUGH SELECTED TRACKS
		min_end = nil
		max_pos = nil
		for k = 0, selected_tracks_count - 1  do
			
			-- LOOP THROUGH ITEM IDX
			item = GetSelectedItems_OnTrack(k, j)
			
			if item ~= nil then
				
				item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
				item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
				item_end = item_pos + item_length
				
				if min_end == nil then
					min_end = item_end
				else
					-- if the item is not to early compared to the others in the column
					if item_end < min_end and item_end > max_pos then min_end = item_end end
				end
				if max_pos == nil then
					max_pos = item_pos
				else
					-- if the item is not to far compared to the others in the column
					if item_pos > max_pos and item_pos < min_end then max_pos = item_pos end
				end
			
			end
		
		end -- ENDLOOP through selected tracks
		
		-- LOOP TRHOUGH SELECTED TRACKS AGAIN
		for k = 0, selected_tracks_count - 1  do
			
			-- LOOP THROUGH ITEM IDX
			item = GetSelectedItems_OnTrack(k, j)
			
			if item ~= nil then
				
				item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
				item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
				item_end = item_pos + item_length
				
				-- APPLY ONLY IF ITEMS HAS COMMON SECTION WITH THE OTHER IN THE SELECTION COLUMN
				if max_pos > item_pos and max_pos < item_end then item_pos = max_pos end
				if min_end < item_end and min_end > item_pos then item_end = min_end end
				reaper.BR_SetItemEdges(item, item_pos, item_end)
				reaper.SetMediaItemSelected(item, true)
			
			end
		
		end -- ENDLOOP through selected tracks
		
	end
	

	reaper.Undo_EndBlock("Trim items by common time section in selection columns", -1) -- End of the undo block. Leave it at the bottom of your main function.

end


-- The following functions may be passed as global if needed
--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

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

-- TRACKS
-- UNSELECT ALL TRACKS
function UnselectAllTracks()
	first_track = reaper.GetTrack(0, 0)
	reaper.SetOnlyTrackSelected(first_track)
	reaper.SetTrackSelected(first_track, false)
end

-- SAVE INITIAL TRACKS SELECTION
init_sel_tracks = {}
local function SaveSelectedTracks (table)
	for i = 0, reaper.CountSelectedTracks(0)-1 do
		table[i+1] = reaper.GetSelectedTrack(0, i)
	end
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
	UnselectAllTracks()
	for _, track in ipairs(table) do
		reaper.SetTrackSelected(track, true)
	end
end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

SaveSelectedItems(init_sel_items)
SaveSelectedTracks(init_sel_tracks)

main() -- Execute your main function

RestoreSelectedItems(init_sel_items)
RestoreSelectedTracks(init_sel_tracks)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)