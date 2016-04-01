--[[
 * ReaScript Name: Create seamless loops from selected items sections inside time selection
 * Description: Seamless loop in one click. Multiple items at once.
 * Instructions: Create a loop section. Select items that have sections in that loop. Run.
 * Screenshot: https://youtu.be/yjGDW4wVkEQ
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > X-Raym's ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Script: Scripts (LUA): Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-04-01)
	+ Initial Release
--]]


-- Easier to define loop with time selection than with item start and end because we can actually play with loop active with time selection. That's why this script works with time selection.

-- Inspired by Musicbynumbers custom action
-- Forum Thread: I made a custom action to make crossfade loops very easy! :)
-- http://forum.cockos.com/showthread.php?t=123279&highlight=Instant+Loop


-- USER CONFIG AREA ---------------------------------------------------------

offset = 2 -- superior to one or false. propotional offset based on new created items. Should be bigger than 1

console = true -- true/false: display debug messages in the console

----------------------------------------------------- END OF USER CONFIG AREA

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


-- Delete Item
function DeleteItem(item)
	local track = reaper.GetMediaItem_Track(item)
	local retval reaper.DeleteTrackMediaItem(track, item)
	
	return retval
end


-- Split Item at Two Points, optionnaly keeping only middle section
function SplitItemAtSection(item, start_time, end_time, delete)

	local middle_item = reaper.SplitMediaItem(item, start_time)
	local last_item = reaper.SplitMediaItem(middle_item, end_time)
	
	if delete then
		DeleteItem(item)
		DeleteItem(last_item)
	end
	
	reaper.SetMediaItemInfo_Value(middle_item, "D_FADEINLEN", 0)
	reaper.SetMediaItemInfo_Value(middle_item, "D_FADEOUTLEN", 0)

	return middle_item

end


-- Sanitize offset
function SanitizeOffset(offset)
	if offset then
		if offset < 0 then offset = 1 end
	end
	return offset
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function main(item)
	
	-- Split at Time Selection Edges
	
	item = SplitItemAtSection(item, start_time, end_time, true)
	
	item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
	item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
	
	-- Cut in Middle of Time Selection
	new_item_pos = item_pos + item_len / 2
	new_item = reaper.SplitMediaItem(item, new_item_pos)
	
	-- Set Fades
	reaper.SetMediaItemInfo_Value(new_item, "D_FADEINLEN", 0)
	reaper.SetMediaItemInfo_Value(new_item, "D_FADEOUTLEN", 0)
	reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", 0)
	reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", 0)
	
	-- Invert items
	reaper.SetMediaItemInfo_Value(item, "D_POSITION", new_item_pos)
	reaper.SetMediaItemInfo_Value(new_item, "D_POSITION", item_pos)
	
	-- Offset
	if offset then
		length = item_len / offset / 2
	else
		length = item_len / 2
	end
	
	reaper.BR_SetItemEdges(item, new_item_pos - length, end_time)
	
	reaper.Main_OnCommand(41059, 0) -- Crossfade any overlappin items
	
	--reaper.Main_OnCommand(41827, 0) -- View crossfada editor
	
	--reaper.Main_OnCommand(41588, 0) -- Glue Items

end


-- INIT ---------------------------------------------------------------------


-- GET LOOP
start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
-- IF LOOP ?
if start_time ~= end_time then time_selection = true end

if time_selection then

	count_sel_items = reaper.CountSelectedMediaItems(0)
	
	if count_sel_items > 0 then
	
		reaper.PreventUIRefresh(1)

		reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
		
		init_sel_items = {}
		SaveSelectedItems(init_sel_items)
		
		offset = SanitizeOffset(offset)
		
		for i, item in ipairs(init_sel_items) do
		
			item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
			item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
			item_end = item_pos + item_len
			
			-- If time selection is inside item
			if item_pos < start_time and start_time < item_end and item_pos < end_time and end_time < item_end then
				
				reaper.SelectAllMediaItems(0, false)
				
				reaper.SetMediaItemSelected(item, true)

				main(item)
			
			end
		
		end
		
		reaper.SelectAllMediaItems(0, false)
		
		reaper.Undo_EndBlock("Create seamless loops from selected items sections inside time selection", -1) -- End of the undo block. Leave it at the bottom of your main function.

		reaper.UpdateArrange()

		reaper.PreventUIRefresh(-1)

		
	end -- if item selected
	
end -- if time selection
