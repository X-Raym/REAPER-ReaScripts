--[[
 * ReaScript Name: Split selected items according to items on first selected track and keep new items at spaces
 * Description: A script designed for spliting an ambiance sound to put between dialog items
 * Instructions: Select an item. Select a track. The item will be split according to the item starts and item ends on track. If you want to do it on multiple tracks, or if you have overlaping items on your dialog, you create an other track, select dialog items, and use the script X-Raym_Create text items on first selected track from selected items notes.lua following by X-Raym_Merge overlapping similar text items on first selected track.lua
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URl: http://forum.cockos.com/***.html
 * REAPER: 5.0 pre 15
 * Extensions: None
 --]]
 
--[[
 * Changelog:
 * v1.1 (2015-04-01)
	+ Works on selected multiple items
 * v1.0 (2015-04-01)
	+ Initial Release
 --]]

-- ----- DEBUGGING ====>
--[[local info = debug.getinfo(1,'S');

local full_script_path = info.source

local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name

if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "..\\Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "../Functions/?.lua"
end

require("X-Raym_Functions - console debug messages")


debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]-- <==== DEBUGGING -----

-- INIT
split_pos={}
save_item={}
save_new_item={}
split_pos_total = 0
count_new_item = 0

-- SAVE TIME IN ARRAY
function save_time(time)
	table.insert(split_pos, 1, time)
	split_pos_total = split_pos_total +1
end

function save_item_selection()
	count_selected_items = reaper.CountSelectedMediaItems(0)
	for f = 0, count_selected_items-1 do
		save_item[f] = reaper.GetSelectedMediaItem(0, f)
	end
	for e = 0, count_selected_items-1 do
		reaper.Main_OnCommand(40289, 0)
		sel_item = save_item[e]
		reaper.SetMediaItemSelected(sel_item, 1)
		main()
	end
end

-- MAIN
function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- GET FIRST SELECTED ITEMS & INFOS
	sel_item_len = reaper.GetMediaItemInfo_Value(sel_item, "D_LENGTH")
	sel_item_pos = reaper.GetMediaItemInfo_Value(sel_item, "D_POSITION")
	sel_item_end = sel_item_pos + sel_item_len

	-- GET FIRST SELECTED ITEM TRACK
	track_of_sel_item = reaper.GetMediaItemTrack(sel_item)

	-- LOOP THROUGH ITEMS ON first selected track
	selected_tracks_count = reaper.CountSelectedTracks(0)

	-- GET THE TRACK
	track = reaper.GetSelectedTrack(0, 0) -- Get selected track 0

	-- INITIALIZE loop through selected items
	item_on_tracks = reaper.CountTrackMediaItems(track)
	for j = 0, item_on_tracks-1  do
		
		-- GET ITEM
		item = reaper.GetTrackMediaItem(track, j) -- Get selected item i

		-- GET INFOS
		item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
		item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		item_end = item_pos + item_len

		-- IF ITEM POS IS INSIDE OUR SELECTED ITEM
		if item_pos > sel_item_pos and item_pos < sel_item_end then

			-- IF FIRST ITEM, INSERT AUTOMATICALLY
			save_time(item_pos)
			last = false
		
		end

		-- IF ITEM END IS INSIDE OUR SELECTED ITEM
		if item_end > sel_item_pos and item_end < sel_item_end then

			-- IF LAST ITEM ON TRACK, INSERT AUTOMATICALLY
			save_time(item_end)
			last = true

		end
	
	end -- END LOOP ITEMS ON TRACK

	-- SORT THE TABLE
	table.sort(split_pos)

	-- SPLIT SELECTED ITEM
	for k = 0, split_pos_total-1 do
		reaper.SplitMediaItem(sel_item, split_pos[split_pos_total-k])
	end

	-- LOOP IN NEW CREATED ITEMS AND DELETE UNWANTED ONES
	count_selected_items = reaper.CountSelectedMediaItems(0)

	-- IF THE LAST CUT WAS A ITEM POS TIME
	if last == false then
		for t = 0, count_selected_items-1 do
			item = reaper.GetSelectedMediaItem(0, count_selected_items-1-t) -- Get selected item i
			if (t % 2 == 0) then
				--reaper.SetMediaItemSelected(item, 0)
				reaper.DeleteTrackMediaItem(track_of_sel_item, item)
			else
				--reaper.SetMediaItemSelected(item, 1)
				count_new_item = count_new_item + 1
				save_new_item[count_new_item] = item
			end
		end
	else -- ELSEIF THE LAST CUT WAS A ITEM END TIME
		for t = 0, count_selected_items-1 do
			item = reaper.GetSelectedMediaItem(0, count_selected_items-1-t) -- Get selected item i
			if (t % 2 == 0) then
				--reaper.SetMediaItemSelected(item, 1)
				count_new_item = count_new_item + 1
				save_new_item[count_new_item] = item
			else
				--reaper.SetMediaItemSelected(item, 0)
				reaper.DeleteTrackMediaItem(track_of_sel_item, item)
			end
		end
	end

	for a = 1, count_new_item do
		reaper.SetMediaItemSelected(save_new_item[a], 1)
	end

	-- UNDO
	reaper.Undo_EndBlock("Split selected items according to items on first selected track and keep new items at spaces", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_SAVEVIEWS5"), 0) ]] -- Save view
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVELOOP5"), 0 ]]-- Save loop
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_SAVE_CURSOR_POS_SLOT_8"), 0) ]]--

save_item_selection()
--main() -- Execute your main function

--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTLOOP5"), 0) ]] -- Restore loop
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_RESTORE_CURSOR_POS_SLOT_8"), 0) ]]-- Restore current position
--[[ reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_RESTIREVIEWS5"), 0) ]] -- Restore view
reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.

-- do it for every selected items ? Could be a bit more over complicated.