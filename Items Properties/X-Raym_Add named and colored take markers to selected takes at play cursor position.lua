--[[
 * ReaScript Name: Add named and colored take markers to selected takes at play cursor position
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Regions and Markers (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?p=1670961
 * REAPER: 6.09
 * Version: 1.0.2
--]]

--[[
 * Changelog:
 * v1.0.2 (2023-10-26)
  + Preset file support
 * v1.0.1 (2020-04-28)
  # Start offset
 * v1.0 (2020-04-28)
  + Initial Release
--]]

-- NOTE: not compatible with stretch marker. Maybe better add markers with native action and then loop in markers with native action and compare position with markers ?

-- USER CONFIG AREA ------------------

-- User Preset file to mod this: https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

name = "Duplicate and Edit the Script to Customize" -- Custom name
color = "#FF0000" -- Hex value

--------------------------------------

if not reaper.GetNumTakeMarkers then
  return reaper.MB( "REAPER version is too old and doesn't have take markers.\n", "Error", 0 )
end

function HexToInt( hex )
  local hex = hex:gsub("#","")
  local R = tonumber("0x"..hex:sub(1,2))
  local G = tonumber("0x"..hex:sub(3,4))
  local B = tonumber("0x"..hex:sub(5,6))
  return reaper.ColorToNative( R, G, B )
end

function IsInTime( s, start_time, end_time )
  if s >= start_time and s <= end_time then return true end
  return false
end

function main()

  color = HexToInt( color )

  pos = 0
  if reaper.GetPlayState() == 1 then
    pos = reaper.GetPlayPosition()
  else
    pos = reaper.GetCursorPosition()
  end

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
      take_pos = (pos - item_pos) * take_rate + take_offset
      if IsInTime( pos, item_pos, item_end ) then
         reaper.SetTakeMarker(take, -1, name, take_pos, color|16777216)
      end
    end

  end -- ENDLOOP through selected items

end

function Init()
  
  reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  main() -- Execute your main function

  reaper.Undo_EndBlock("Add named and colored take markers to selected takes at play cursor position", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

  reaper.UpdateArrange() -- Update the arrangement (often needed)

end

if not preset_file_init then
  Init()
end
