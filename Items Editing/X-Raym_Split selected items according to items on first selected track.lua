--[[
 * ReaScript Name: Split selected items according to items on first selected track
 * Description: A script designed for splitting long items at regions when regions are created from items, thanks to Heda's script.
 * Instructions: Select an item. Select a track. The item will be split according to the item starts and item ends on track.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2016-04-18)
	+ Initial Release
--]]

-- based on X-Raym_Split selected items according to items on first selected track and keep new items at spaces.lua

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
			item = reaper.GetSelectedMediaItem(0, count_selected_items-1-t) --
			count_new_item = count_new_item + 1
			save_new_item[count_new_item] = item
		end
	end

	for a = 1, count_new_item do
		reaper.SetMediaItemSelected(save_new_item[a], 1)
	end

	-- UNDO
	reaper.Undo_EndBlock("Split selected items according to items on first selected track", 0) -- End of the undo block. Leave it at the bottom of your main function.

end


reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.

save_item_selection()

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
