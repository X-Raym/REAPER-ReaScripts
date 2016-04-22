--[[
 * ReaScript Name: Snap selected items to region or marker with same name as their active take
 * Description: A way to snap items to regions according to their names.
 * Instructions: Have regions or markers.
 * Screenshot: http://i.giphy.com/xTiTntThSvTeIV8gsE.gif
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
 * v1.0 (2015-09-13)
	+ Initial Release
--]]
 
-- ---------- USER CONFIG AREA ====>

unselect = true -- keep only selected items that didn't move

------------ END OF USER CONFIG AREA
 
function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	-- SAVE ITEMS SELECTION
	sel_items = {}
	for i = 0, selected_items_count do
		sel_items[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
	
	-- INITIALIZE loop through selected items
	for j = 0, #sel_items - 1  do
		-- GET ITEMS
		item = sel_items[j+1] -- Get selected item i
		
		take = reaper.GetActiveTake(item) -- Get the active take

		if take ~= nil then

			-- GET INFOS
			take_name = reaper.GetTakeName(take)
			
			-- LOOP IN REGIONS
			i=0
			repeat
			
				retval, isrgn, pos, rgnend, name, markrgnindex = reaper.EnumProjectMarkers2(0, i)
				
				if name == take_name then -- if name mtach activate take name
					
					reaper.SetMediaItemInfo_Value(item, "D_POSITION", pos) -- Set the value to the parameter
					
					if unselect == true then
						reaper.SetMediaItemSelected(item, false) -- unselect if there is a match
					end
					
					break -- prevent moving item several times if there is several regions with same name
				
				end
				
				i = i+1
				
			until retval == 0 -- end loop regions and markers
			
		end -- if active take
	
	end -- selected items loop
	
	reaper.Undo_EndBlock("Snap selected items to region or marker with same name as their active take", -1)
	
end -- of function


-- LOOP THROUGH SELECTED ITEMS
selected_items_count = reaper.CountSelectedMediaItems(0)
retval, markers_count, regions_count = reaper.CountProjectMarkers(0)

if selected_items_count > 0 and (markers_count > 0 or regions_count > 0) then

	reaper.PreventUIRefresh(1)

	main() -- Execute your main function

	reaper.PreventUIRefresh(-1)
	
end