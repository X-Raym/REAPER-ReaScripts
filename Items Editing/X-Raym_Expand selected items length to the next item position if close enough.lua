--[[
 * ReaScript Name: Expand selected items length to the next item position if close enough
 * Description: Expand selected items to the next item position
 * Instructions: Select items and perform the script.
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
 * v1.0 (2015-08-23)
  + Initial Release
--]]
 
-- TO DO: ITEMS INSIDE OTHERS

threshold = 1

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- LOOP THROUGH SELECTED ITEMS  
  selected_items_count = reaper.CountSelectedMediaItems(0)

  for i=0, selected_items_count - 1 do

	  item = reaper.GetSelectedMediaItem(0, i)
      
      -- GET INFOS
      item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- Get the value of a the parameter

      -- GET TRACK
      item_track = reaper.GetMediaItemTrack(item)

      -- GET ID ON TRACK
      item_id = reaper.GetMediaItemInfo_Value(item, "IP_ITEMNUMBER")
	  
	  item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
	  
	  item_end = item_pos + item_len 

      -- GET NEXT ITEM
      next_item = reaper.GetTrackMediaItem(item_track, item_id+1)

      -- IF NEXT ITEM
      if next_item ~= nil then

        next_item_pos = reaper.GetMediaItemInfo_Value(next_item, "D_POSITION")
		
		distance = next_item_pos - item_end
		
		if distance < threshold then
			-- MODIFY INFOS
			item_len_input = next_item_pos - item_pos -- Prepare value output
		  
			-- SET INFOS
			reaper.SetMediaItemInfo_Value(item, "D_LENGTH", item_len_input) -- Set the value to the parameter
		
		else
		
			if distance < threshold * 2 then
		
				reaper.SetMediaItemInfo_Value(item, "D_LENGTH", item_len + threshold)
			
			end
			
		end

      end
      
  end -- ENDLOOP through selected items
  

  reaper.Undo_EndBlock("Expand selected items length to the next item position if close enough", -1) -- End of the undo block. Leave it at the bottom of your main function.
end

retval, user_input = reaper.GetUserInputs("Consecutivity Threshold",1,"Consecutivity Threshold (s)",tostring(threshold))

if retval then
	
	threshold = tonumber(user_input)
	
	if threshold ~= nil then
		
		reaper.PreventUIRefresh(1)
		
		main() -- Execute your main function
		
		reaper.UpdateArrange() -- Update the arrangement (often needed)
		
		reaper.PreventUIRefresh(-1)
	end

end

