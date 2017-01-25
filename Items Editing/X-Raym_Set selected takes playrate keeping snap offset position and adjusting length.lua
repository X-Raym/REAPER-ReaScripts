--[[
 * ReaScript Name: Set selected takes playrate keeping snap offset position and adjusting length
 * Description: A way to expand items in selection without moving their synch point, determined by snap offset and content at snap offset.
 * Instructions: Run.
 * Screenshot: http://i.imgur.com/O02MKFr.gifv
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2017-01-26)
  + Initial Release
--]]

--[[
 * Many thanks to mpl for this help on this script ! He made this possible :D Thanks man!
 * http:--forum.cockos.com/member.php?u=70694
--]]

-- ------ USER AREA =====>

value = 1 -- number >= 0
prompt = true -- true/false

-- <===== USER AREA ------

function main(new_rate)
		
	for i, item in ipairs ( items ) do

		-- CHECK IF ITEM HAS TAKE OR IF IT IS EMPTY ITEM
		take = reaper.GetActiveTake( item )
		if take then
			take_rate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
		else
			take_rate = 1
		end

		k = take_rate / new_rate

		-- INITIAL ITEM INFOS
		item_fadein = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")
		item_fadeout = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN")
		item_position = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
		item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
		
		-- SNAP
		item_snap_absolute = item_snap + item_position

		new_length = item_length * k
		
		new_rate = new_rate
		new_snap_offset = item_snap * k
		new_fadein = item_fadein * k
		new_fadeout = item_fadeout * k
		
		new_pos = item_snap_absolute - new_snap_offset
		
		if item_snap == 0 then
			new_pos = item_position
		end
		
		reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE", new_rate)
		reaper.SetMediaItemInfo_Value(item, "D_POSITION", new_pos)
		reaper.SetMediaItemInfo_Value(item, "D_LENGTH", new_length)
		reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", new_snap_offset)
		reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", new_fadein)
		reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", new_fadeout)
	
	end

end

function SaveSelectedItems (table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end

selected_items_count = reaper.CountSelectedMediaItems(0)

if selected_items_count > 0 then
  	
  	if prompt then
		retval, coef = reaper.GetUserInputs("Set Take Rate", 1, "Value ( > 0 )", tostring(value) )
	end 

	if retval or prompt == false then
		
		coef = tonumber(coef)
		
		if coef ~= nil then
		
			coef = math.abs(coef)
		
			if coef ~= 0 then

				reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

				items = {}
	
				SaveSelectedItems( items )
		
				reaper.PreventUIRefresh(1)

				main( coef ) -- Execute your main function

				reaper.PreventUIRefresh(-1)

				reaper.UpdateArrange() -- Update the arrangement (often needed)

				reaper.Undo_EndBlock("Set selected takes playrate keeping snap offset position and adjusting length", -1) -- End of the undo block. Leave it at the bottom of your main function.
			
			end
			
		end
  
    end
  
end