--[[
 * ReaScript Name: Add take markers from project markers to selected takes
 * Screenshot: https://i.imgur.com/aaRSHRs.gifv
 * Author: X-Raym
 * Author URI: https://extremraym.com
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
 * v1.0 (2020-04-29)
  + Initial Release
--]]

-- NOTE: not compatible with stretch marker. Maybe better add markers with native action and then loop in markers with native action and compare position with markers ?

function IsInTime( s, start_time, end_time )
  if s >= start_time and s <= end_time then return true end
  return false
end

function SaveMarkers( start_pos, end_pos )
  local i=0
  repeat
    local iRetval = SaveMarker( i, start_pos, end_pos )
    i = i+1
  until iRetval == 0
end

function SaveMarker( i, start_pos, end_pos )
  local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
  if iRetval >= 1 then
    if not bIsrgnOut and iPosOut >= start_pos and iPosOut <= end_pos then
      local marker = {}
      marker.pos_start = iPosOut
      marker.pos_end = iPosOut
      marker.name = sNameOut
      marker.color = iColorOur -- In case field is only $blank to clear
      marker.idx = iMarkrgnindexnumberOut
      table.insert( markers, marker )
    end
  end
  return iRetval
end

function main()

  -- GET TIME SELECTION
  start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

  if start_time == end_time then
    start_time = 0
    end_time = math.huge
    end

  markers = {}
  SaveMarkers(start_time,end_time)

  count_sel_items = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  for i = 0, count_sel_items  - 1 do

    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    take = reaper.GetActiveTake(item)
    if take then
      item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      item_end = item_pos + item_len
      take_rate = reaper.GetMediaItemTakeInfo_Value( take, "D_PLAYRATE" )
      take_marker_count = reaper.GetNumTakeMarkers(take)
      take_offset = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
      for j, marker in ipairs( markers ) do
        if IsInTime( marker.pos_start, item_pos, item_end ) then
           reaper.SetTakeMarker(take, -1, marker.name, (marker.pos_start- item_pos) * take_rate + take_offset, marker.color)
        end
      end
    end

  end -- ENDLOOP through selected items

end

if reaper.GetNumTakeMarkers then

  reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  main() -- Execute your main function

  reaper.Undo_EndBlock("Add take markers from project markers to selected takes", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

  reaper.UpdateArrange() -- Update the arrangement (often needed)

end
