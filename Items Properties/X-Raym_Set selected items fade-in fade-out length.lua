--[[
 * ReaScript Name: Set selected items fade-in fade-out length (seconds)
 * Description: A pop up will let you enter value of selected items fade-in and fade-out. -1 is for leaving as it is, 0 is for reset. Express value in seconds. Priority is to let you choose what fades will be set first if they overlaps (items too short). If fades are longer than items, they are adjusted accordingly.
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts (LUA): Scripts: Item Fades (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156757
 * REAPER: 5.0 pre 36
 * Extensions: None
 * Version: 1.3.2
--]]
 
--[[
 * Changelog:
 * v1.3.2 (2015-07-07)
  # translations/typos fixes thanks to daxliniere
 * v1.3 (2015-07-07)
  + adding User Area customization option
  # Rename
 * v1.2 (2015-07-06)
  + Option to create new fades only. Already present fades length are overriden by priority.
 * v1.1 (2015-26-06)
  + Now with relative to initial fade with + prefix
 * v1.0 (2015-25-06)
  + Initial Release
 --]]
 
-- >-----> USER AREA >=====>
  
  prompt = true -- false -> No prompt, true -> prompt window
  
  units = "seconds" -- "Available Value => seconds, milliseconds"
  
  -- Default Values
  answer1 = "0" -- fade in value
  answer2 = "0" -- fade out value
  answer3 = "i" -- priority on fade out "o", priority on fade in "i"
  answer4 = "n" -- only Create new fades "y", treat already existing fades as well "n"

-- <=====< USER AREA <-----< 



--[[ ----- DEBUGGING ====>
function get_script_path()
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    return debug.getinfo(1,'S').source:match("(.*".."\\"..")"):sub(2) -- remove "@"
  end
    return debug.getinfo(1,'S').source:match("(.*".."/"..")"):sub(2)
end

package.path = package.path .. ";" .. get_script_path() .. "?.lua"
require("X-Raym_Functions - console debug messages")

debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]-- <==== DEBUGGING -----

function IfRelative(str)
  x, y = string.find(str, "+")
  str = str:gsub("+", "")
  if x ~= nil then -- set
    return str, true
  else -- offset
    return str, false 
  end
end

function main(input1, input2, input3, input4) -- local (i, j, item, take, track)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  input1, input1_relative = IfRelative(input1)
  input2, input2_relative = IfRelative(input2)
  
  if units == "milliseconds" then
    input1 = input1/1000
    input2 = input2/1000
  end
  
  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
    
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    item_end = item_pos + item_len
    
    fadein_len_init = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")
    fadeout_len_init = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN")
    
    -- GET FADES
    if input1 == "/initial" or (input4 == "y" and fadein_len_init ~= 0) then
      fadein_len = fadein_len_init
    else
      fadein_len = tonumber(input1)
      if input1_relative then fadein_len = fadein_len + fadein_len_init end
      if fadein_len ~= nil then
        if fadein_len > item_len then fadein_len = item_len end
      end
    end
    
    if input2 == "/initial" or (input4 == "y" and fadeout_len_init ~= 0) then
      fadeout_len =  fadeout_len_init
    else
      fadeout_len = tonumber(input2)
      if input2_relative then fadeout_len = fadeout_len +  fadeout_len_init end
      if fadeout_len ~= nil then 
        if item_end - fadeout_len < item_pos then fadeout_len = item_len end
      end
    end
    
    -- SET
    if fadeout_len ~= nil and fadein_len ~= nil then
      if (item_pos + fadein_len) > (item_end - fadeout_len) then -- if overlaping
        if input3 == "o" then
          reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", 0)
          reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", fadeout_len)
          reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", item_len - fadeout_len)
        else
          reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", fadein_len)
          reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN",  item_len - fadein_len)
        end
      else
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", fadein_len)
        reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", fadeout_len)
      end
    end

  end -- ENDLOOP through selected items
    
  reaper.Undo_EndBlock("Set selected items fade-in fade-out length (seconds)", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

selected_items_count = reaper.CountSelectedMediaItems(0)

if selected_items_count > 0 then

  reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.
  
  if prompt == true then
  
    retval, retvals_csv = reaper.GetUserInputs("Set fades length in "..units, 4, "Fade-in (no change = /initial),Fade-out (+ for relative),Priority (i = in, o = out),Create new fades only? (y/n)", answer1..","..answer2..","..answer3..","..answer4)  
    
    if retval == true then
      
      -- PARSE THE STRING
      answer1, answer2, answer3, answer4 = retvals_csv:match("([^,]+),([^,]+),([^,]+),([^,]+)")
    
      main(answer1, answer2, answer3, answer4) -- Execute your main function
  
      reaper.UpdateArrange() -- Update the arrangement (often needed)
  
    end
    
  else -- no prompt
  
    main(answer1, answer2, answer3, answer4)
  
  end
  reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.
  
  reaper.UpdateArrange() -- Update the arrangement (often needed)
  
end

--msg_end() -- Display characters in the console to show you the end of the script execution.
