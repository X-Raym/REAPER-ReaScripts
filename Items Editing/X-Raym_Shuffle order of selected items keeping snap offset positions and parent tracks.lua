--[[
 * ReaScript Name: Shuffle order of selected items keeping snap offset positions and parent tracks
 * Description: See title.
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: 
 * Licence: GPL v3
 * Forum Thread: Script (Lua): Shuffle Items
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=159961
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.2.
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2016-01-07)
	+ Preserve grouping if groups active. Treat first selected item (in position) in each group as group leader (other are ignored during the alignement).
 * v1.0 (2015-05-11)
	+ Initial Release
--]]
 
-- ----- DEBUGGING ====>
reselect_groups = true
-- <==== DEBUGGING -----


-- FUNCTION TO EXECUTE BEFORE MAIN LOOPS
function KeepSelOnlyFirstItemInGroups()
	
	-- Count Sel Items (maybe it is already in GLobal variable)
	if count_sel_items == nil then
		count_sel_items = reaper.CountSelectedMediaItems(0)
	end

	groups = {} -- Table to store groups infos (min item and min pos)
	unselect = {} -- Table to store items to unselect after

	-- Loop in Sel Items
	for i = 0, count_sel_items - 1 do
	  local item = reaper.GetSelectedMediaItem(0, i)
	  
	  -- Check Group
	  local group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
	  if group > 0 then
	  
		local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		-- If group is new, then create one
		if groups[group] == nil then

			groups[group]={}

			groups[group].item = item -- Min item of the group
			groups[group].pos = pos -- Min item pos of the group

			else -- if group exists in table, check item pos against min group item pos
			
				if pos < groups[group].pos then -- unselect previous item and set new one as reference
					table.insert(unselect, groups[group].item)
					groups[group].item = item
					groups[group].pos = pos
				else -- unselect the current item
					table.insert(unselect, item)
				end

			end

		end -- END IF GROUP (no else)

	end -- END LOOP sel items
	
	-- Unselect Items
	for i, item in ipairs(unselect) do
	  reaper.SetMediaItemSelected(item, false)
	end


end -- End of KeepSelOnlyFirstItemInGroups()


-- SHUFFLE TABLE FUNCTION
-- from Tutorial: How to Shuffle Table Items by Rob Miracle
-- https://coronalabs.com/blog/2014/09/30/tutorial-how-to-shuffle-table-items/
math.randomseed( os.time() )

local function ShuffleTable( t )
	local rand = math.random 
	
	local iterations = #t
	local w
	
	for z = iterations, 2, -1 do
		w = rand(z)
		t[z], t[w] = t[w], t[z]
	end
end


function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	--reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
	UnselectAllTracks()

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


	-- LOOP TRHOUGH SELECTED TRACKS
	selected_tracks_count = reaper.CountSelectedTracks(0)

	for i = 0, selected_tracks_count - 1  do
		-- GET THE TRACK
		track = reaper.GetSelectedTrack(0, i) -- Get selected track i

		count_items_on_track = reaper.CountTrackMediaItems(track)

		-- REINITILIAZE THE TABLE
		sel_items_on_track = {}
		snap_sel_items_on_track = {}
		snap_sel_items_on_tracks_len = 1 

		-- LOOP THROUGH ITEMS ON TRACKS AND STORE SELECTED ITEMS (for later moving) AND OFFSET
		for j = 0, count_items_on_track - 1  do

			item = reaper.GetTrackMediaItem(track, j)

			if reaper.IsMediaItemSelected(item) == true then
				sel_items_on_track[snap_sel_items_on_tracks_len] = item
				snap_sel_items_on_track[snap_sel_items_on_tracks_len] = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET") + reaper.GetMediaItemInfo_Value(item, "D_POSITION")
				snap_sel_items_on_tracks_len = snap_sel_items_on_tracks_len + 1
			end     

		end

		-- SHUFFLE THE TABLE
		--reaper.ShowConsoleMsg("")
		ShuffleTable(snap_sel_items_on_track)

		-- LOOP THROUGH SELECTED ITEMS ON TRACKS
		for k = 1, snap_sel_items_on_tracks_len - 1 do
			
			--reaper.ShowConsoleMsg(tostring(snap_sel_items_on_track[k]).. "\n")
			
			item = sel_items_on_track[k]
			item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
			item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

			reaper.SetMediaItemInfo_Value(item, "D_POSITION", snap_sel_items_on_track[k] - item_snap)
			
			offset = reaper.GetMediaItemInfo_Value(item, "D_POSITION") - item_pos
			if group_state == 1 then
				-- Check Group
				group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
				if group > 0 then
					groups[group].offset = offset
				end
			end
			
		end
		
	end -- ENDLOOP through selected tracks
	
	if group_state == 1 then
		-- Loop all items in table (cause they will move)
		all_items = {}
		for i = 0, reaper.CountMediaItems(0) - 1 do
			item = reaper.GetMediaItem(0, i)
			table.insert(all_items, item)
		end
		-- Loop in all items
		for i, item in ipairs(all_items) do
			-- Check Group
			group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
			if group > 0 then
				if reaper.IsMediaItemSelected(item) == false then
					if groups[group] ~= nil then -- if it was in the initial selection and if it has an offset
						pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
						reaper.SetMediaItemInfo_Value(item, "D_POSITION", pos + groups[group].offset)
					end
				end
			end
		end
		
		if reselect_groups == true then
			-- Unselect Items
			for i, item in ipairs(unselect) do
			  reaper.SetMediaItemSelected(item, true)
			end
		end
	end

	reaper.Undo_EndBlock("Shuffle order of selected items keeping snap offset positions and parent tracks", 0) -- End of the undo block. Leave it at the bottom of your main function.

end


--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

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

selected_items_count = reaper.CountSelectedMediaItems(0)

if selected_items_count >= 2 then

	-- INIT
	parent_tracks = {}
	t = {}

	reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

	SaveSelectedTracks(init_sel_tracks)

	group_state = reaper.GetToggleCommandState(1156, 0)

	if group_state == 1 then
		KeepSelOnlyFirstItemInGroups()
	end
	main() -- Execute your main function

	RestoreSelectedTracks(init_sel_tracks)

	reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

	reaper.UpdateArrange() -- Update the arrangement (often needed)
	
end
