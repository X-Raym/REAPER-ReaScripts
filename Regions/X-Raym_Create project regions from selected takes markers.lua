--[[
 * ReaScript Name: Create project regions  from selected takes markers
 * Screenshot: https://i.imgur.com/pqqfaPX.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Regions and Markers (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?p=1670961
 * REAPER: 6.09
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2024-01-01)
  + Initial Release
--]]

console = true
add_region_from_start = true

function IsInTime( s, start_time, end_time )
  if s >= start_time and s <= end_time then return true end
  return false
end

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

function main()

  -- INITIALIZE loop through selected items
  for i = 0, reaper.CountSelectedMediaItems(0) - 1 do

    -- GET ITEMS
    local item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    local take = reaper.GetActiveTake(item)
    if take then
      local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      local item_end = item_pos + item_len
      local item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
      local take_rate = reaper.GetMediaItemTakeInfo_Value( take, "D_PLAYRATE" )
      local take_marker_count = reaper.GetNumTakeMarkers(take)
      local take_offset = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
      local first_region = false
      for i = 0, take_marker_count - 1 do
        local pos, name, color = reaper.GetTakeMarker(take, i)
        local proj_pos = item_pos - take_offset/ take_rate + pos / take_rate
      
        local region_end_proj_pos = 0
        if i + 1 < take_marker_count then
          nxt_pos, _, _ = reaper.GetTakeMarker(take, i + 1)
          region_end_proj_pos = math.min( item_end, item_pos - take_offset/ take_rate + nxt_pos / take_rate )
        else
          region_end_proj_pos = item_end
        end
      
        if IsInTime(proj_pos, item_pos, item_pos + item_len) then
          if not first_region and add_region_from_start and proj_pos > item_pos then
            reaper.AddProjectMarker(0, true, item_pos, proj_pos, "", -1, color)
          end
          first_region = true
          reaper.AddProjectMarker(0, true, proj_pos, region_end_proj_pos, name, -1, color)
        end

      end

    end

  end -- ENDLOOP through selected items

end

if reaper.GetNumTakeMarkers then

  reaper.ClearConsole()

  reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  main() -- Execute your main function

  reaper.Undo_EndBlock("Create project regions from selected takes markers", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

  reaper.UpdateArrange() -- Update the arrangement (often needed)

end
