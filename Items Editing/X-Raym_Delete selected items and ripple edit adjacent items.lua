--[[
 * ReaScript Name: Delete selected items and ripple edit adjacent items
 * Description: See title
 * Instructions: Select items. Run.
 * Screenshot: http://i.giphy.com/3o8doN6hJOcw77QX8Q.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-12-02)
	+ Initial Release
 --]]
 
function msg(val)
	reaper.ShowConsoleMsg(tostring(val).."\n")
end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- LOOP THROUGH SELECTED TAKES
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	delete_items = {}

	for i = 0, selected_items_count-1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		track = reaper.GetMediaItemTrack(item) -- Get the active take
			
		-- GET INFOS
		item_idx = reaper.GetMediaItemInfo_Value(item, "IP_ITEMNUMBER")
		item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		item_len =  reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
		item_end = item_pos + item_len
		
		next_item = reaper.GetTrackMediaItem(track, item_idx + 1)
		
		if next_item ~= nil then
			next_item_pos = reaper.GetMediaItemInfo_Value(next_item, "D_POSITION")
			
			if next_item_pos <= item_end + 0.0000000000001 then
				reaper.SetMediaItemInfo_Value(next_item, "D_POSITION", item_pos)
				table.insert(delete_items, item)
			end
			
		end
			
	
	end -- ENDLOOP through selected items
	
	for i = 1, #delete_items do
		track = reaper.GetMediaItemTrack(delete_items[i])
		reaper.DeleteTrackMediaItem(track, delete_items[i])
	end

	reaper.Undo_EndBlock("Delete selected items and ripple edit adjacent items", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
