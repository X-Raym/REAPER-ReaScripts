--[[
 * ReaScript Name: Multiply selected items rate by X and adjust length
 * Description:
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items selection (Various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1600647
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-11-25)
	+ Initial Release
 --]]

function main( coef ) -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	SaveSelectedItems( init_sel_items )
  
	-- INITIALIZE loop through selected items
	for i = 1, #init_sel_items  do
		-- GET ITEMS
		item = init_sel_items[i] -- Get selected item i
		
		take = reaper.GetActiveTake( item )
		
		if take ~= nil then
		
			take_rate = reaper.GetMediaItemTakeInfo_Value( take, "D_PLAYRATE" )
			
			take_rate = take_rate * coef
			
			reaper.SetMediaItemTakeInfo_Value( take, "D_PLAYRATE", take_rate )
		
		end
		
		item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
		
		item_len = item_len / coef
		
		reaper.SetMediaItemInfo_Value( item, "D_LENGTH", item_len )

	end -- ENDLOOP through selected items

	reaper.Undo_EndBlock("Multiply selected items rate and length by X", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

-- SAVE INITIAL SELECTED ITEMS
init_sel_items = {}
function SaveSelectedItems (table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end

selected_items_count = reaper.CountSelectedMediaItems(0)

if selected_items_count > 0 then
  
	retval, retvals_csv = reaper.GetUserInputs("Multiply Rate", 1, "Rate Coefficient ( > 0 )", "1")  

      
	if retvals_csv ~= nil then
		
		coef = tonumber(retvals_csv)
		
		if coef ~= nil then
		
			coef = math.abs(coef)
		
			if coef ~= 0 then
		
				reaper.PreventUIRefresh(1)

				main( coef ) -- Execute your main function

				reaper.PreventUIRefresh(-1)

				reaper.UpdateArrange() -- Update the arrangement (often needed)
			
			end
			
		end
  
    end
  
end