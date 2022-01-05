--[[
 * ReaScript Name: Set selected items take names by columns according to track under mouse or first track with selected items
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1574814
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 2.0.1
--]]

--[[
 * Changelog:
 * v2.0 (2021-02-14)
  # Renamed
 * v2.0 (2021-02-14)
  # New core
 * v1.0 (2016-04-18)
  + Initial Release
--]]

-- USER CONFIG AREA -------------------------------------

param = "P_NAME"

preset_file_init = false
console = true -- true/false: activate/deactivate console messages

--------------------------------- END OF USER CONFIG AREA

-- NOTE: V2.0 as initial release because based on the v2.0 of my column template

local reaper = reaper

-------------------------------------------------------------
function Main()
  -- Find Ref Track
  local ref_track, __, __ = reaper.BR_TrackAtMouseCursor() -- Mouse track
  if not ref_track then
    ref_track = reaper.GetMediaItem_Track(reaper.GetSelectedMediaItem(0,0)) -- or first track with selected items
  end
  ref_track_id = reaper.GetMediaTrackInfo_Value(ref_track, "IP_TRACKNUMBER")
  ref_values = {}

  tracks = {}

  -- Store items by track
  for i = 0, count_sel_tems - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local take = reaper.GetActiveTake( item )
    if take then
      local track = reaper.GetMediaItem_Track( item )
      local track_id = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
      if track_id == ref_track_id then
        local retval, value = reaper.GetSetMediaItemTakeInfo_String(take, param, "", false)
        table.insert(ref_values, value)
      else -- insert items
        if not tracks[track_id] then tracks[track_id] = {} end
        table.insert( tracks[track_id], take)
      end
    end
  end

  for item_index, v in ipairs( ref_values ) do
    for track_id, track in pairs( tracks ) do
      if track[item_index] then -- if there is a selected item at index i in track
        reaper.GetSetMediaItemTakeInfo_String(track[item_index], param, v, true)
      end
    end
  end

end

-- INIT
function Init()
  count_sel_tems = reaper.CountSelectedMediaItems(0)

  if count_sel_tems > 1 then

    reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

    reaper.ClearConsole()

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    Main() -- Execute your main function

    reaper.Undo_EndBlock("Set selected items take names by columns according to track under mouse or first track with selected items", -1) -- End of the undo block. Leave it at the bottom of your main function.

    reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

    reaper.UpdateArrange() -- Update the arrangement (often needed)

  end
end

if not preset_file_init then
  Init()
end
