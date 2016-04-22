--[[
 * ReaScript Name: Align selected items across tracks
 * Description: A way to align items across tracks, with their snap offset. Useful for layering in sound design.
 * Instructions Select two items minimum on two different tracks minimum. Run. Items that don't have pairs will not be moved.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (Lua): Shuffle Items
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=159961
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.2
 * Version: 1.2
--]]
 
--[[
 * Changelog:
 * v1.2 (2016-01-05)
	+ Preserve grouping if groups active. Treat first selected item (in position) in each group as group leader (other are ignored during the alignement).
 * v1.1 (2015-12-28)
	+ Track under mouse as reference
 * v1.0 (2015-05-19)
	+ Initial Release
--]]

-- ----- DEBUGGING ====>
reselect_groups = true
-- <==== DEBUGGING -----

function Msg(variable)
    reaper.ShowConsoleMsg(tostring(variable).."\n")
end



function KeepSelOnlyFirstItemInGroups()
	
	-- Count Sel Items (maybe it is already in GLobal variable)
	if count_sel_items == nil then
		count_sel_items = reaper.CountSelectedMediaItems(0)
	end

	groups = {} -- Table to store groups infos (min item and min pos)
	unselect = {} -- Table to store items to unselect after

	-- Loop in Sel Items
	for i = 0, count_sel_items - 1 do
	  item = reaper.GetSelectedMediaItem(0, i)
	  
	  -- Check Group
	  group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
	  if group > 0 then
	  
		pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
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

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELTRKWITEM"), 0) -- Select only track with selected items
	
	selected_tracks = reaper.CountSelectedTracks(0)
	
	if selected_tracks >= 2 then
		
		-- Get the first selected track and save item selected
		
		-- Get track under mouse
		first_sel_track, context, position = reaper.BR_TrackAtMouseCursor()
		-- If no track under mouse
		if first_sel_track == nil then
			first_sel_track = reaper.GetSelectedTrack(0, 0)
		else -- track under rmouse
			-- Check if the track is not selecyed
			if reaper.IsTrackSelected(first_sel_track) == false then
				first_sel_track = reaper.GetSelectedTrack(0, 0)
			end
		end
		
		first_snap_abs = {}
		
		for i = 0, reaper.CountTrackMediaItems(first_sel_track)-1 do
		
			item = reaper.GetTrackMediaItem(first_sel_track, i)
			
			if reaper.IsMediaItemSelected(item) == true then
				
				snap_abs = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
				table.insert(first_snap_abs, snap_abs)
			
			end -- end if item on first track is selected
		
		end -- loop through item on first track
		
		-- LOOP ON SELECTED TRACKS
		for i = 0, selected_tracks - 1 do
			
			track = reaper.GetSelectedTrack(0, i)
			if track ~= first_sel_track then
			
				sel_items = {} -- init table of selected items on track
				
				for j = 0, reaper.CountTrackMediaItems(track)-1 do
			
					item = reaper.GetTrackMediaItem(track, j)
				
					if reaper.IsMediaItemSelected(item) == true then
						
						table.insert(sel_items, item)
				
					end -- end if item on first track is selected
			
				end -- loop through item on first track
				
				-- LOOP THROUGH SAVE ITEMS ON TRACKS
				for k = 1, #first_snap_abs do
					
					item = sel_items[k]
					
					if item ~= nil then
						
						item_abs_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
						reaper.SetMediaItemInfo_Value(sel_items[k], "D_POSITION", first_snap_abs[k] - reaper.GetMediaItemInfo_Value(sel_items[k], "D_SNAPOFFSET"))
						offset = reaper.GetMediaItemInfo_Value(item, "D_POSITION") - item_abs_pos
						
						if group_state == 1 then
							-- Check Group
							group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
							if group > 0 then
								groups[group].offset = offset
							end
						end
					end
				
				end
				
			end
		
		end -- loop tracks with selected items
		
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
		
	end -- more than two tracks selected

	reaper.Undo_EndBlock("Align selected items across tracks", -1) -- End of the undo block. Leave it at the bottom of your main function.

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

--[[ <==== INITIAL SAVE AND RESTORE ----- ]]

-- INIT
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