--[[
 * ReaScript Name: Move items to start preserving groups timing relative positions
 * Description: A template script for REAPER ReaScript.
 * Instructions: Leader of groups is first selected item (in time position) for a group.
 * Screenshot: http://i.giphy.com/3o6UBfWs5qRzh0r3b2.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: 
 * Licence: GPL v3
 * Forum Thread: 
 * Forum Thread URI: 
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-01-11)
	+ Initial Release
--]]

--[[ ----- INSTRUCTIONS ====>

You only need to modify what is inside the loop in the main() function.

--]]

-- ----- DEBUGGING ====>

reselect_groups = true
dest_pos = 0

-- <==== DEBUGGING -----


-------------------------------------------------------------------------------------------------------------		
-- CONSOLE MSG

function Msg(variable)
	reaper.ShowConsoleMsg(tostring(variable).."\n")
end


-------------------------------------------------------------------------------------------------------------		
-- FUNCTION TO EXECUTE BEFORE MAIN LOOPS
-- A WAY TO UNSELECT ITEMS NOT CONSIDERED IN THE TRANSFORMATION (aka, items in groups that are lot Leader)

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


-------------------------------------------------------------------------------------------------------------	
-- FOR EACH ITEM TRANSFORMATION, CHECK GROUP AND STORE OFFSET IF NEEDED
function StoreOffsetInGroups(item, item_pos)
	local offset = reaper.GetMediaItemInfo_Value(item, "D_POSITION") - item_pos
	if group_state == 1 then
		-- Check Group
		group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
		if group > 0 then
			groups[group].offset = offset
		end
	end
end


-------------------------------------------------------------------------------------------------------------		
-- APPLY ITEM GROUPS OFFSET

function ApplyItemsGroupsOffset()

	-- Loop all items in table (cause they will move)
	all_items = {}
	for i = 0, reaper.CountMediaItems(0) - 1 do
		local item = reaper.GetMediaItem(0, i)
		table.insert(all_items, item)
	end
	-- Loop in all items
	for i, item in ipairs(all_items) do
		-- Check Group
		local group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
		if group > 0 then
			if reaper.IsMediaItemSelected(item) == false then
				if groups[group] ~= nil then -- if it was in the initial selection and if it has an offset
					local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
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


-------------------------------------------------------------------------------------------------------------		
-- SAVE
function SaveSelectedItems(table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end


-------------------------------------------------------------------------------------------------------------		
-- MAIN

function Main()
	
	-- Save items in selection in a table because they will move
	sel_items = {}
	SaveSelectedItems(sel_items)
	
	-- LOOP THROUGH SELECTED ITEMS ON TRACKS
	for i, item in ipairs(sel_items) do
		
		-- Store Initial Pos
		item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

		 -- Transformation
		reaper.SetMediaItemInfo_Value(item, "D_POSITION", dest_pos)
		
		-- Store offset in a table
		StoreOffsetInGroups(item, item_pos)
		
	end

end

-------------------------------------------------------------------------------------------------------------		
-- INIT

count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then
	
	reaper.PreventUIRefresh(1)
	
	reaper.Undo_BeginBlock()
	-- If group active keep only first selected items of each groups
	group_state = reaper.GetToggleCommandState(1156, 0)
	if group_state == 1 then
		KeepSelOnlyFirstItemInGroups()
	end
	
	Main() -- Execute your main function

	-- If group active, apply offset on items of same groups
	if group_state == 1 then
		ApplyItemsGroupsOffset()
	end
	
	reaper.Undo_EndBlock("Move items to start preserving groups timing relative positions", -1)
	
	reaper.UpdateArrange()
	reaper.PreventUIRefresh(-1)

end