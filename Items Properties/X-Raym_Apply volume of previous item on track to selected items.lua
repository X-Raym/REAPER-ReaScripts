--[[
 * ReaScript Name: Apply volume of previous item on track to selected item
 * Description: A very nice way to set item volume for dialog editing.
 * Instructions: Select items. Run.
 * Screenshot: http://i.giphy.com/xTiTnBqy5MgtePvLLG.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Nudge selected items volume
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=152009
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-10-02)
	+ Initial Release
 --]]

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	for i = 0, count_sel_items - 1 do
	
		item = reaper.GetSelectedMediaItem(0, i)
		
		track = reaper.GetMediaItem_Track(item)
		
		item_id = reaper.GetMediaItemInfo_Value(item, "IP_ITEMNUMBER")
		
		prev_item = reaper.GetTrackMediaItem(track, item_id - 1)
		
		if prev_item ~= nil then
		
			prev_item_vol = reaper.GetMediaItemInfo_Value(prev_item, "D_VOL")
			
			reaper.SetMediaItemInfo_Value(item, "D_VOL", prev_item_vol)
		
		end
	
		
	end
	
	reaper.Undo_EndBlock("Apply volume of previous item on track to selected item", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

count_sel_items = reaper.CountSelectedMediaItems(0)
if count_sel_items > 0 then
	reaper.PreventUIRefresh(1)

	main() -- Execute your main function

	reaper.UpdateArrange() -- Update the arrangement (often needed)

	reaper.PreventUIRefresh(-1)
end