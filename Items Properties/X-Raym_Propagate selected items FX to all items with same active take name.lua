--[[
 * ReaScript Name: Propagate selected items FX to all items with same active take name
 * Description: Move group of selected items to next item end on all visible tracks, according to max end of items in selection.
 * Instructions: Select items. Run.
 * Screenshot: http://i.giphy.com/xTiTnrxH3rbBO8D2da.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1574697#post1574697
 * REAPER: 5.0
 * Extensions: SWS 2.8.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-09-22)
	+ Initial Release
 --]]

-- REQUEST BY Bernadette Michelle
 
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

-- RESTORE
function RestoreSelItems()
	reaper.SelectAllMediaItems(0, false) -- unselect all items
	for i, sel_item in ipairs(sel_items) do
	 reaper.SetMediaItemSelected(sel_item, true)
	end
end
-- <-------------- END OF SAVE INIT ITEM SELECTION

-- ---------- MAIN FUNCTION =========>
function Main()
  
	reaper.Undo_BeginBlock()

	SaveSelectedItems() -- Save item selection

	count_items = reaper.CountMediaItems(0) -- Count All Media items once

	-- LOOP IN ALL ITEMS
	for i, sel_item in ipairs(sel_items) do

		reaper.SelectAllMediaItems(0, false) -- unselect all items
		reaper.SetMediaItemSelected(sel_item, true) -- Select only one item from init sel items
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYFXCHAIN1"), 0) -- Copy FX chain from selected item

		sel_take = reaper.GetActiveTake(sel_item) -- get sel item take
		sel_take_name = reaper.GetTakeName(sel_take) -- get sel item take name

		-- LOOP IN ALL ITEMS
		for j = 0, count_items - 1 do

			item = reaper.GetMediaItem(0, j) -- Get item

			if item ~= sel_item then

				-- LOOP IN TAKES
				-- takes_count = reaper.CountTakes(item) -- Count takes
				-- for v = 0, takes_count-1 do

					-- item_take = reaper.GetTake(item, v) -- Get Take
					item_take = reaper.GetActiveTake(item, v) -- Get Take

					name_item_take = reaper.GetTakeName(item_take) -- Get take name

					if name_item_take == sel_take_name then -- Si le nom du take selectionné est similaire au take, alors

						reaper.SetMediaItemSelected(sel_item, false) -- Unselect current sel item
						reaper.SetMediaItemSelected(item, true) -- Select items
						reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYFXCHAIN3"), 0) -- Paste (replace) FX chain to selected items
          
					end -- NAMES MATCH
          
				--end -- LOOP TAKES
      
			end -- IF DIFFERENT THAN CURRENT ITEM
    
		end -- LOOP IN ITEMS
    
	end -- LOOP IN INIT SEL ITEMS

	RestoreSelItems()

	reaper.Undo_EndBlock("Propagate selected items FX to all items with same active take name", -1)

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