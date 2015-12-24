--[[
 * ReaScript Name: Propagate items selection to all similary-named active takes on track
 * Description: Select items with similary-named active take of selected items on tracks.
 * Instructions: Select items. Run.
 * Screenshot:
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items selection (Various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163321
 * REAPER: 5.0
 * Extensions: SWS 2.8.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-09-22)
	+ Initial Release
 --]]
 
-- ---------- DEBUG =========> 
function Msg(variable)
  reaper.ShowConsoleMsg(tostring(variable).."\n")
end
-- <------------- END OF DEBUG

-- ---------- INIT ITEMS SELECTION =========>
-- SAVE
function SaveSelectedItems()
	
	sel_items = {} -- init table

	for i = 0, count_sel_items - 1 do
	
		sel_item = reaper.GetSelectedMediaItem(0, i)

		if reaper.GetActiveTake(sel_item) ~= nil then -- IF SEL ITEM HAS TAKE
		  table.insert(sel_items, sel_item) -- insert it in the table
		end

	end

end
-- <-------------- END OF SAVE INIT ITEM SELECTION


-- ---------- MAIN FUNCTION =========>
function Main()
  
	reaper.Undo_BeginBlock()

	SaveSelectedItems() -- Save item selection
	reaper.SelectAllMediaItems(0, false) -- unselect all items

	-- LOOP IN ALL ITEMS
	for i, sel_item in ipairs(sel_items) do

		sel_take = reaper.GetActiveTake(sel_item) -- get sel item take
		sel_take_name = reaper.GetTakeName(sel_take) -- get sel item take name
		sel_track = reaper.GetMediaItem_Track(sel_item)
		count_items_on_track = reaper.CountTrackMediaItems(sel_track)
		-- LOOP IN ALL ITEMS
		for j = 0, count_items_on_track - 1 do

			item = reaper.GetTrackMediaItem(sel_track, j) -- Get item

			item_take = reaper.GetActiveTake(item, v) -- Get Take

			name_item_take = reaper.GetTakeName(item_take) -- Get take name

			if name_item_take == sel_take_name then -- Si le nom du take selectionné est similaire au take, alors

				reaper.SetMediaItemSelected(item, true) -- Select items
  
			end -- NAMES MATCH
    
		end -- LOOP IN ITEMS
    
	end -- LOOP IN INIT SEL ITEMS

	reaper.Undo_EndBlock("Propagate items selection to all similary-named active takes on track", -1)

end
-- <---------------------- END OF MAIN

-- ---------- COUNT SEL ITEMS =========> 
count_sel_items = reaper.CountSelectedMediaItems(0)
if count_sel_items > 0 then -- IF item selected
	
	reaper.PreventUIRefresh(1)
	
	Main() -- Run
	
	reaper.UpdateArrange()
	reaper.PreventUIRefresh(-1)

end