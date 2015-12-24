--[[
 * ReaScript Name: Set or offset selected takes pan
 * Description: Set selected takes pan
 * Instructions: Select items. Run.
 * Screenshot:
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1574814
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-12-07)
  + Initial Release
 --]]
 
-- ------ USER AREA =====>
mod1 = "absolute" -- Set the primary mod that will be defined if no prefix character. Values are "absolute" or "relative".
mod2 = "relative"
mod2_prefix = "+" -- Prefix to enter the secondary mod
input_default = "" -- "" means no character aka relative per default.
-- <===== USER AREA ------
 

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  
  pan_value = user_input_num / 100
  
  -- INITIALIZE loop through selected items
  for i = 0, sel_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
	
	take = reaper.GetActiveTake(item)
	
	if take ~= nil then
		
		if set == true then
			reaper.SetMediaItemTakeInfo_Value(take, "D_PAN", pan_value)
		else
			offset = reaper.GetMediaItemTakeInfo_Value(take, "D_PAN")
			reaper.SetMediaItemTakeInfo_Value(take, "D_PAN", pan_value + offset)
		end
	end

  end -- ENDLOOP through selected items
  
  reaper.Undo_EndBlock("Set or offset selected takes pan", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

-- START
sel_items_count = reaper.CountSelectedMediaItems(0)

if sel_items_count > 0 then

	retval, user_input_str = reaper.GetUserInputs("Set/Offset Take Pan Value", 1, "Value (" .. mod2_prefix .." for " .. mod2 .. ")", "") 
		  
	if retval then -- if user complete the fields
	  
	  x, y = string.find(user_input_str, mod2_prefix)
		    
	  if mod1 == "absolute" then
	    if x ~= nil then -- set
		 set = false
	    else -- offset
		 set = true 
	    end
	  end
	  
	  if mod1 == "relative" then
	    if x ~= nil then -- set
		 set = true
	    else -- offset
		 set = false 
	    end
	  end
	  
	  user_input_str = user_input_str:gsub(mod2_prefix, "")
	  
	  user_input_num = tonumber(user_input_str)

	  if user_input_num ~= nil then
		
		reaper.PreventUIRefresh(1)

		main() -- Execute your main function

		reaper.PreventUIRefresh(-1)

		reaper.UpdateArrange() -- Update the arrangement (often needed)
	  end

	end
	
end
