--[[
 * ReaScript Name: Trim selected items at first and last transient
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Screenshot: https://i.imgur.com/bavfu34.gifv
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2019-01-26)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console
fade = 0.1
------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end


-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function main()

  for i, item in ipairs(init_sel_items) do
    
    local take = reaper.GetActiveTake( item )
    if take and not reaper.TakeIsMIDI( take ) then
      local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      
      reaper.SetEditCurPos( item_pos, false, false)
      reaper.Main_OnCommand(40375,0) -- Item navigation: Move cursor to next transient in items
      local new_start_item = reaper.GetCursorPosition()
      
      reaper.SetEditCurPos( item_pos + item_len, false, false)
      reaper.Main_OnCommand(40376,0) -- Item navigation: Move cursor to previous transient in items
      local new_end_item = reaper.GetCursorPosition()
      
      reaper.BR_SetItemEdges( item, new_start_item -fade, new_end_item+fade )
      
      reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", fade)
      reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", fade)
      
    end

  end

end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  init_sel_items =  {}
  SaveSelectedItems(init_sel_items)

  group_state = reaper.GetToggleCommandState(1156)
  if group_state == 1 then
    reaper.Main_OnCommand(1156,0)
  end
  
  cur_pos = reaper.GetCursorPosition()  

  main()
  
  if group_state == 1 then
    reaper.Main_OnCommand(1156,0)
  end
  
  reaper.SetEditCurPos( cur_pos, false, false)

  reaper.Undo_EndBlock("Trim selected items at first and last transient", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)
  
end
