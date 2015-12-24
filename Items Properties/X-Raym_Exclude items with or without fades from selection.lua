--[[
 * ReaScript Exclude: Exclude items with or without fades from selection
 * Description: A way to exclude items from a selection.
 * Instructions: Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items selection (Various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163321
 * REAPER: 5.0 pre 36
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-07-04)
  + Initial Release
 --]]

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

local function UnselectdItems (table)
  for i = 1, #items_to_unsel do
    reaper.SetMediaItemSelected(items_to_unsel[i], false)
  end
end

function Msg(variable)
 reaper.ShowConsoleMsg(tostring(variable).."\n")
end

--Msg("")

function main(input1, input2, input3, input4) -- local (i, j, item, take, track)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  items_to_unsel = {}
  
  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count - 1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
    
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    item_end = item_pos + item_len
    
    fadein_len = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")
    fadeout_len = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN")
    
    fadein_auto_len = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO")
    fadeout_auto_len = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO")
    
    if (fadein_auto_len > 0 and input3 == "with") or (fadein_auto_len == 0 and input3 == "without") or (fadeout_auto_len > 0 and input4 == "with") or (fadeout_auto_len == 0 and input4 == "without") or (fadein_len > 0 and input1 == "with") or (fadein_len == 0 and input1 == "without") or (fadeout_len > 0 and input2 == "with") or (fadeout_len == 0 and input2 == "without") then
       table.insert(items_to_unsel, item)
       --Msg(fadein_len)
    end
    
  end -- ENDLOOP through selected items
  
  UnselectdItems(items_to_unsel)
    
  reaper.Undo_EndBlock("Exclude items with or without fades from selection", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

selected_items_count = reaper.CountSelectedMediaItems(0)

if selected_items_count > 0 then

  reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.
  
  retval, retvals_csv = reaper.GetUserInputs("Exclude selected items...", 4, "Fade-in (ignore/with/without),Auto Fade-in,Fade-out (ignore/with/without),Auto Fade-out", "ignore,ignore,ignore,ignore") 
  
  if retval == true then
      
    -- PARSE THE STRING
    answer1, answer2, answer3, answer4 = retvals_csv:match("([^,]+),([^,]+),([^,]+),([^,]+)")
    
    if answer1 ~= nil then -- if match
    
      main(answer1, answer2, answer3, answer4) -- Execute your main function
  
      reaper.UpdateArrange() -- Update the arrangement (often needed)
    
    end

  end
  
  reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.
  
  reaper.UpdateArrange() -- Update the arrangement (often needed)
  
end

--msg_end() -- Display characters in the console to show you the end of the script execution.
