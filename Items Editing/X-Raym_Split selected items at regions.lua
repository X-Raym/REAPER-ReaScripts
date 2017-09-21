--[[
 * ReaScript Name: Split selected items at regions
 * Description: See title
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Request, split selected item(s) to regions.
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=169127
 * REAPER: 5.0
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2017-09-21)
  + Bug fix if similar pos points
 * v1.0 (2017-09-20)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = false -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA

pos = {}

-- UTILITIES -------------------------------------------------------------

-- Count the number of times a value occurs in a table 
function table_count(tt, item)
  local count
  count = 0
  for ii,xx in pairs(tt) do
    if item == xx then count = count + 1 end
  end
  return count
end

-- Remove duplicates from a table array
function table_unique(tt)
  local newtable
  newtable = {}
  for ii,xx in ipairs(tt) do
    if(table_count(newtable, xx) == 0) then
      newtable[#newtable+1] = xx
    end
  end
  return newtable
end

function MultiSplitMediaItem(item, times)

  local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  local item_end = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") + item_pos
  
  -- create array then reserve some space in array
  local items = {}
  
  -- add 'item' to 'items' array
  table.insert(items, item)
  
  -- for each time in times array do...
  for i, time in ipairs(times) do
  
    if time > item_end then break end
    
    if time > item_pos and time < item_end then
  
      -- store item so we can split it next time around
      item = reaper.SplitMediaItem(item, time)
      
      -- add resulting item to array
      table.insert(items, item)
      
    end

  end

  -- return 'items' array
  return items

end

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

function GetRegionsPoints()
  local i=0
  repeat
    local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
    if iRetval >= 1 then
      if bIsrgnOut == true then
        table.insert(pos, iPosOut)
        table.insert(pos, iRgnendOut)
      end
      i = i+1
    end
  until iRetval == 0
  pos = table_unique(pos)
  table.sort(pos)
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function main()
  
  GetRegionsPoints()
  for idx, item in ipairs(init_sel_items) do
      MultiSplitMediaItem(item, pos)
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

  reaper.Undo_EndBlock("Split selected items at regions", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)
  
end
