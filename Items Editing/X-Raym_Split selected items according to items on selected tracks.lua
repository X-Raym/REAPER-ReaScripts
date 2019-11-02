--[[
 * ReaScript Name: Split selected items according to items on selected tracks
 * Description: A script designed for splitting long items at regions when regions are created from items, thanks to Heda's script.
 * Instructions: Select an item. Select a track. The item will be split according to the item starts and item ends on track.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.1.2
--]]

--[[
 * Changelog:
 * v1.1.2 (2019-10-20)
	# Better undo
 * v1.1.1 (2016-05-12)
	+ Bug fix
 * v1.1 (2016-04-19)
	+ Works with multiple tracks selected
	# Refactoring
 * v1.0 (2016-04-18)
	+ Initial Release
--]]

-- based on X-Raym_Split selected items according to items on first selected track and keep new items at spaces.lua

function save_item_selection()
	save_item = {}
	for f = 0, count_sel_items - 1 do
		save_item[f+1] = reaper.GetSelectedMediaItem(0, f)
	end
end


-- Count the number of times a value occurs in a table
function table_count(tt, item)
	local count
	count = 0
	for ii,xx in pairs(tt) do
		if item == xx then count = count + 1 end
	end
	return count
end


-- Remove duplicates from a table array
function table_unique(tt)
	local newtable
	newtable = {}
	for ii,xx in ipairs(tt) do
		if(table_count(newtable, xx) == 0) then
			newtable[#newtable+1] = xx
		end
	end
	return newtable
end

-- Get table of all different split points to consider
function GetSplitPoints()

	split_all = {}

	for i = 0, count_sel_tracks -1 do
		-- GET THE TRACK
		local track = reaper.GetSelectedTrack(0, i) -- Get selected track 0

		-- INITIALIZE loop through selected items
		local item_on_tracks = reaper.CountTrackMediaItems(track)
		for j = 0, item_on_tracks-1  do

			-- GET ITEM
			local item = reaper.GetTrackMediaItem(track, j) -- Get selected item i

			-- GET INFOS
			local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
			local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
			local item_end = item_pos + item_len

			table.insert(split_all, item_pos)
			table.insert(split_all, item_end)

		end -- END LOOP ITEMS ON TRACK

	end

	split_pos = table_unique(split_all)

	-- SORT THE TABLE
	table.sort(split_pos)

	return split_pos

end

-- MAIN
function main()

	for i, item in ipairs(save_item) do

		item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		item_end = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") + item_pos

		-- SPLIT ITEMS
		for j, pos in ipairs(split_pos) do

			if pos < item_end and pos > item_pos then
				item = reaper.SplitMediaItem(item, pos)
			end
			if pos > item_end then break end

		end

	end

end


-- Run ------->

-- LOOP THROUGH ITEMS ON first selected track
count_sel_tracks = reaper.CountSelectedTracks(0)
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_tracks > 0 and count_sel_items > 0 then

	reaper.Undo_BeginBlock() -- Begining of the undo block.

	reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.

	GetSplitPoints() -- Get Split Points

	save_item_selection() -- Save Item Selection

	main() -- Run

	reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

	reaper.UpdateArrange() -- Update the arrangement (often needed)

	reaper.Undo_EndBlock("Split selected items according to items on selected tracks", -1) -- End of the undo block.

end
