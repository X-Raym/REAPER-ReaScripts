--[[
 * ReaScript Name: Create project markers from selected takes markers
 * Screenshot: https://i.imgur.com/AAcThVd.gifv
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Regions and Markers (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?p=1670961
 * REAPER: 6.09
 * Version: 1.0.1
--]]
 
--[[
 * Changelog:
 * v1.0.1 (2020-04-28)
  # Prevent marker generation if markers is outside item boundaries
 * v1.0 (2020-04-28)
  + Initial Release
--]]
function IsInTime( s, start_time, end_time )
  if s >= start_time and s <= end_time then return true end
  return false
end

function main()

  -- INITIALIZE loop through selected items
  for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
  
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
    
    take = reaper.GetActiveTake(item)
    if take then
      item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
      take_rate = reaper.GetMediaItemTakeInfo_Value( take, "D_PLAYRATE" )
      take_marker_count = reaper.GetNumTakeMarkers(take)
      take_offset = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
      for i = 0, take_marker_count - 1 do
        pos, name, color = reaper.GetTakeMarker(take, i)
        proj_pos = item_pos - take_offset + pos / take_rate
        if IsInTime( proj_pos, item_pos, item_pos + item_len ) then
          reaper.AddProjectMarker2(0, false, proj_pos, 0, name, -1, color)
        end
      end
      
    end
    
  end -- ENDLOOP through selected items

end

if  reaper.GetNumTakeMarkers then
  
  reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.
  
  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  main() -- Execute your main function
  
  reaper.Undo_EndBlock("Create project markers from selected takes markers", -1) -- End of the undo block. Leave it at the bottom of your main function.
  
  reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.
  
  reaper.UpdateArrange() -- Update the arrangement (often needed)
  
end
