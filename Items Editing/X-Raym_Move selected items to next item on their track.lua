--[[
 * ReaScript Name: Move selected items to next item on their track
 * Description: Move item (position) so that its touches the next item on track (if any).
 * Instructions: Here is how to use it. (optional)
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
 * v1.0 (2015-09-09)
	+ Initial Release
 --]]


function main()

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	count_sel_items = reaper.CountSelectedMediaItems(0)
	
	for i = 1, count_sel_items do
	
		item = reaper.GetSelectedMediaItem(0, count_sel_items - i)
	
		track = reaper.GetMediaItem_Track(item)
		
		item_id = reaper.GetMediaItemInfo_Value(item, "IP_ITEMNUMBER")
		
		next_item = reaper.GetTrackMediaItem(track, item_id + 1)
		
		if next_item ~= nil then
		
			item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
			item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
			
			next_item_pos = reaper.GetMediaItemInfo_Value(next_item, "D_POSITION")
			
			reaper.SetMediaItemInfo_Value(item, "D_POSITION", next_item_pos - item_length)
			
		end
		
	end
	
	reaper.Undo_EndBlock("Move selected items to next item on their track", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1)

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)