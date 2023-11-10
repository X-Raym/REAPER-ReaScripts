--[[
 * ReaScript Name: Delete selected items and ripple edit adjacent items
 * Screenshot: https://i.imgur.com/LUyqVCT.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2023-11-10)
  + Initial Release
 * v1.0 (2015-12-02)
  + Initial Release
--]]

overlap_duration =  0.0000000000001

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

-- Save item selection
function SaveSelectedItems(t)
  local t = t or {}
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    t[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
  return t
end

function IsInTime( s, start_time, end_time )
  if s >= start_time and s <= end_time then return true end
  return false
end

function Main()

  delete_items = {}
  ripple_items = {}

  for i, item in ipairs( init_sel_items ) do
    
    local track = reaper.GetMediaItemTrack(item) -- Get the active take

    -- GET INFOS
    local item_idx = reaper.GetMediaItemInfo_Value(item, "IP_ITEMNUMBER")
    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_len =  reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local item_end = item_pos + item_len
    
    local first_offset
    local count_track_items = reaper.CountTrackMediaItems( track )
    for z = item_idx+1, count_track_items - 1 do
  
      local next_item = reaper.GetTrackMediaItem(track, z)
      local next_item_pos = reaper.GetMediaItemInfo_Value(next_item, "D_POSITION")
      local next_item_len =  reaper.GetMediaItemInfo_Value(next_item, "D_LENGTH")
      local next_item_end = next_item_pos + next_item_len
      
      if not first_offset then
        first_offset = (next_item_pos - item_pos )
      end
      
      if next_item_pos <= item_end + overlap_duration then
        reaper.SetMediaItemInfo_Value(next_item, "D_POSITION", next_item_pos - first_offset )
        item_end = math.max( item_end, next_item_end )
        table.insert(ripple_items, next_item)
      end
    end

  end -- ENDLOOP through selected items

  for i, item in ipairs( init_sel_items ) do
    local track = reaper.GetMediaItemTrack( item )
    reaper.DeleteTrackMediaItem( track, item )
  end
  
  reaper.Main_OnCommand(40289 ,0) -- Item: Unselect all items
    
  for i, item in ipairs( ripple_items ) do
    if reaper.ValidatePtr( item, "MediaItem*" ) then
      reaper.SetMediaItemSelected( item, true )
    end
  end

end

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

-- LOOP THROUGH SELECTED TAKES
count_sel_items = reaper.CountSelectedMediaItems(0)
if count_sel_items == 0 then return end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

init_sel_items = SaveSelectedItems(t)

Main() -- Execute your main function

reaper.Undo_EndBlock("Delete selected items and ripple edit adjacent items", -1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
