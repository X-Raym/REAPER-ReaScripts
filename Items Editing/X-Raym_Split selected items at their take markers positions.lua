--[[
 * ReaScript Name: Split selected items at their take markers positions
 * Screenshot: https://i.imgur.com/XZ3Gqa6.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 6.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2022-12-14)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

undo_text = "Split selected items at their take markers positions" 
------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems(t)
  local t = t or {}
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    t[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
  return t
end

function RestoreSelectedItems( items )
  reaper.SelectAllMediaItems(0, false)
  for i, item in ipairs( items ) do
    reaper.SetMediaItemSelected( item, true )
  end
end


-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

function IsInTime( s, start_time, end_time )
  if s >= start_time and s <= end_time then return true end
  return false
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

--------------------------------------------------------- END OF UTILITIES


-- Main function
function Main()

  for i, item in ipairs(init_sel_items) do
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
    take = reaper.GetActiveTake(item)
    if take then
      take_rate = reaper.GetMediaItemTakeInfo_Value( take, "D_PLAYRATE" )
      take_marker_count = reaper.GetNumTakeMarkers(take)
      take_offset = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
      times = {}
      for i = 0, take_marker_count - 1 do
        pos, name, color = reaper.GetTakeMarker(take, i)
        proj_pos = item_pos - take_offset + pos / take_rate
        if IsInTime( proj_pos, item_pos, item_pos + item_len ) then
         table.insert(times, proj_pos)
        end
      end
      MultiSplitMediaItem(item, times)
    end
  end

end


-- INIT
function Init()
  -- See if there is items selected
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items == 0 then return false end

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock()

  init_sel_items = SaveSelectedItems()

  Main()

  RestoreSelectedItems(init_sel_items)

  reaper.Undo_EndBlock(undo_text, -1)

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)
  
end

if not preset_file_init then
  Init() 
end


