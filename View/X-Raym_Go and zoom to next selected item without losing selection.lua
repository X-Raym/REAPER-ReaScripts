--[[
 * ReaScript Name: Go and zoom to next selected item without losing selection
 * Description: A way to find items more easily on huge project, without losing selection
 * Screenshot: https://i.imgur.com/sHBYUgL.gifv
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: View and Zoom (Various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=160800
 * REAPER: 5.0 pre 32
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2018-06-21)
	+ Initial Release
--]]

-- Save item selection
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

function RestoreSelectedItems(table)
	for i, item in ipairs(table) do
		reaper.SetMediaItemSelected(item, true)
	end
end

function Main()

	cursor = reaper.GetCursorPosition()
	local loop = true
	for i = 0, count_sel_items - 1 do
		
		local item = reaper.GetSelectedMediaItem(0, i)
		local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
		if cursor < item_pos then
			reaper.SelectAllMediaItems( 0, false )
			reaper.SetMediaItemSelected( item, true )
			reaper.SetEditCurPos( item_pos, true, true )
			reaper.Main_OnCommand(41622, 0) -- View: Toggle zoom to selected items
			loop = false
			break
		end

	end
	
	if loop then
		local item = reaper.GetSelectedMediaItem(0, 0)
		local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
		reaper.SelectAllMediaItems( 0, false )
		reaper.SetMediaItemSelected( item, true )
		reaper.SetEditCurPos( item_pos, true, true )
		reaper.Main_OnCommand(41622, 0) -- View: Toggle zoom to selected items
	end

end

count_sel_items = reaper.CountSelectedMediaItems( 0 )

if count_sel_items > 0 then

	reaper.PreventUIRefresh(1)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	init_sel_items = {}
	SaveSelectedItems (init_sel_items)
	
	Main() -- Execute your main function

	RestoreSelectedItems(init_sel_items)

	reaper.UpdateArrange() -- Update the arrangement (often needed)

	reaper.Undo_EndBlock("Go and zoom to next selected item without losing selection", -1) -- End of the undo block. Leave it at the bottom of your main function.

	reaper.PreventUIRefresh(-1)

end
