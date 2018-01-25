--[[
 * ReaScript Name: Quantize selected items edges at grid unit inside them if possible
 * Description: See title
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Extensions: SWS 2.9.1
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2017-21-12)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

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
  
    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local item_end = item_pos + item_len
    
    local new_pos = reaper.BR_GetClosestGridDivision(item_pos)
    if new_pos < item_pos then new_pos = reaper.BR_GetNextGridDivision(item_pos) end
    local new_end = reaper.BR_GetClosestGridDivision(item_end)
    if new_end > item_end then new_end = reaper.BR_GetPrevGridDivision(item_end) end
    
    if new_end > new_pos then
      reaper.BR_SetItemEdges(item, new_pos, new_end)
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

  main()

  reaper.Undo_EndBlock("Quantize selected items edges at grid unit inside them if possible", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)
  
end
