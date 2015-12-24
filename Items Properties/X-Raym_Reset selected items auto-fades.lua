--[[
 * ReaScript Name: Reset selected items auto-fades
 * Description: See title
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Scripts: Item Fades (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1538659
 * REAPER: 5.0 pre 36
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-09-29)
	+ Initial Release
 --]]

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- LOOP THROUGH SELECTED ITEMS
	
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	-- INITIALIZE loop through selected items
	for i = 0, selected_items_count-1  do
		
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		-- GET INFOS
		reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO", 0)
		reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO", 0)
		
	end -- ENDLOOP through selected items

	reaper.Undo_EndBlock("Reset selected items auto-fades", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)  -- Restore UI Refresh. Uncomment it only if the script works.