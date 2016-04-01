--[[
 * ReaScript Name: Create text items on first selected track from selected items groups
 * Description: Make to be used with heda's region from text items scripts, to create empty items from multiple audio samples for rendering
 * Instructions: Select a destination track. Select items. Execute.
 * Screenshot: http://i.imgur.com/fv87llV.gifv
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

-- No need to select all items in group.


-- UTILITIES -------------------------------------------------------------
console = true
-- Display a message in the console for debugging
function Msg(value)
	if console then
		reaper.ShowConsoleMsg(tostring(value) .. "\n")
	end
end


-- Get Groups Infos From Selected Items
-- based on function KeepSelOnlyFirstItemInGroups()
function GetGroupsFromSelectedItems()
	
	-- Count Sel Items (maybe it is already in GLobal variable)
	if not count_sel_items then
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

			local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
			local item_end = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") + item_pos
			
			-- If group is new, then create one
			if not groups[group] then

				groups[group]={}

				groups[group].item = item -- Min item of the group
				groups[group].pos = item_pos -- Min item pos of the selected items in the group

			else -- if group exists in table, check item pos against min group item pos

				if item_pos < groups[group].pos then -- unselect previous item and set new one as reference
					groups[group].item = item
					groups[group].pos = item_pos
				end

			end -- If group don't exist

		end -- END IF GROUP (no else)

	end -- END LOOP sel items

end -- End of KeepSelOnlyFirstItemInGroups()


-- Insert infos about groups in the groups table
function InsertGroupInfos()
	
	-- Count Items
	if not count_items then
		count_items = reaper.CountMediaItems(0)
	end
	
	-- Loop in All Items
	for i = 0, count_items - 1 do
	
		local item = reaper.GetMediaItem(0, i)
		local group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
		
		-- If Item is in Group
		if group > 0 and groups[group] then
			
			local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
			local item_end = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") + item_pos
			
			-- Group Color
			if not groups[group].color then
				item_color = reaper.GetMediaItemInfo_Value(item, "I_CUSTOMCOLOR")
				
				if item_color > 0 then
					groups[group].color = item_color
				end
			end
			
			-- Group Min Pos
			if groups[group].min_pos then
			
				if item_pos < groups[group].min_pos then
					groups[group].min_pos = item_pos
				end
			
			else
				groups[group].min_pos = item_pos -- Min item pos of the group
			end
			
			-- Group Max End
			if groups[group].max_end then
				
				if item_end > groups[group].max_end then
					groups[group].max_end = item_end
				end
				
			else	
				groups[group].max_end = item_end	
			end
			
		end -- if groups
	
	end -- if items

end -- InsertGroupInfos()

--------------------------------------------------------- END OF UTILITIES


-- CREATE TEXT ITEMS
-- text and color are optional
function CreateTextItem(track, position, length, text, color)
    
	local item = reaper.AddMediaItemToTrack(track)
  
	reaper.SetMediaItemInfo_Value(item, "D_POSITION", position)
	reaper.SetMediaItemInfo_Value(item, "D_LENGTH", length)
  
	if text then
		reaper.ULT_SetMediaItemNote(item, text)
	end
  
	if color then
		reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)
	end
  
	return item

end


-- MAIN ------------------------------------------------------------------
function main()

	GetGroupsFromSelectedItems() -- Get Groups infos
	InsertGroupInfos() -- Get More Groups Infos (min pox, max end, color)

	track = reaper.GetSelectedTrack(0, 0) -- Get first selected track
	
	-- LOOP in Groups
	for i, group in pairs(groups) do
		
		new_item_length = group.max_end - group.min_pos
	
		new_item = CreateTextItem(track, group.min_pos, new_item_length, "Group " .. i, group.color)
		
		reaper.SetMediaItemInfo_Value(new_item, "I_GROUPID", i)
	
	end

end -- main()


-- INIT ------------------------------------------------------------------
count_sel_items = reaper.CountSelectedMediaItems(0)
count_sel_tracks = reaper.CountSelectedTracks(0)

if count_sel_tracks > 0 and count_sel_items > 0 then

	reaper.Undo_BeginBlock()

	reaper.PreventUIRefresh(1)
	
	main() -- Execute your main function

	reaper.PreventUIRefresh(-1)
	reaper.UpdateArrange() -- Update the arrangement (often needed)
	
	reaper.Undo_EndBlock("Create text items on first selected track from selected items groups", -1) -- End of the undo block. Leave it at the bottom of your main function.

end