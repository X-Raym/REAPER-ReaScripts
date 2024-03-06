--[[
 * ReaScript Name: Set take or item or track or region or marker color (functions)
 * Screenshot: https://cloud.extremraym.com/sharex/reaper_Lhy3kX7SKg.gif
 * About: Set color based on context.
1. Selected Items Active Take
2. Selected Items
3. Selected Tracks
4. Markers in Time Selection
5. Regions in Time Selection
6. Current Marker
7. Current Region
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: X-Raym Premium Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
 * MetaPackage: true
 * Provides:
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 1.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 2.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 3.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 4.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 5.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 6.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 7.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 8.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 9.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 10.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 11.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 12.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 13.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 14.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 15.lua
 *   [main] . > X-Raym_Set take or item or track or region or marker color to custom slot 16.lua
--]]

--[[
 * Changelog:
 * v1.0 (2024-03-06)
  + Initial release
--]]

-- USER CONFIG AREA -----------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

force_color = false
console = true

-------------------------------------------------

if not force_color and not reaper.CF_GetCustomColor then
  reaper.MB("SWS extension is required by this script.\nPlease download it on https://www.sws-extension.org/ or via reapack on https://www.reapack.com", "Warning", 0)
  return
end

--script_name = "X-Raym_Set take or item or track or region or marker color to custom slot 1.lua"
script_name = ({reaper.get_action_context()})[2]:match("([^/\\_]+)%.lua$")
color_slot = math.floor(tonumber( script_name:match("(%d+)") ) or 1 ) - 1

new_color = force_color or reaper.CF_GetCustomColor( color_slot )|16777216

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

function SaveMarkersAndRegions( start_pos, end_pos )
  local markers, regions = {}, {}
  local retval, num_markers, num_regions = reaper.CountProjectMarkers( proj )
  for i = 0, retval - 1 do
    local retval, is_region, pos_start, pos_end, name, idx, color = reaper.EnumProjectMarkers3(0,i)
    pos_end = is_region and pos_end or pos_start
    if pos_start >= start_pos and pos_end <= end_pos then
      local entry = {
        pos_start = pos_start,
        pos_end = is_region and pos_end or 0,
        color = color,
        name = name,
        idx = idx,
        is_region = is_region
      }
      table.insert( is_region and regions or markers, entry )
    end
  end
  return markers, regions
end

function Main()

  -- 1. Selected Items Active Take
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items > 0 then
    for i = 0, count_sel_items - 1 do
      local item = reaper.GetSelectedMediaItem(0, i)
      local take = reaper.GetActiveTake(item)
      if take then
        reaper.SetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR", new_color)
      -- 2. Selected Items
      else
        reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", new_color)
      end
    end
    return
  end

  -- 3. Selected Tracks
  count_sel_tracks = reaper.CountSelectedTracks(0)
  if count_sel_tracks > 0 then
    for i = 0, count_sel_tracks - 1 do
      local track = reaper.GetSelectedTrack(0, i)
      reaper.SetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR", new_color)
    end
    return
  end

  -- 4. Markers in Time Selection
  time_start, time_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  if time_start ~= time_end then
    markers, regions = SaveMarkersAndRegions( time_start, time_end )
    if #markers > 0 then
      for z, entry in ipairs(markers) do
        reaper.SetProjectMarker3( 0, entry.idx, entry.is_region, entry.pos_start, entry.pos_end, entry.name, new_color )
      end
      return
    -- 5. Regions in Time Selection
    elseif #regions > 0 then
      for z, entry in ipairs(regions) do
        reaper.SetProjectMarker3( 0, entry.idx, entry.is_region, entry.pos_start, entry.pos_end, entry.name, new_color )
      end
      return
    end
  end

  -- 6. Current Marker
  cur_pos = reaper.GetCursorPosition()
  markeridx, regionidx = reaper.GetLastMarkerAndCurRegion( 0, cur_pos )
  local retval, is_regn, pos_start, pos_end, name, index, color = reaper.EnumProjectMarkers3(0, markeridx)
  if markeridx >= 0 and pos_start == cur_pos then
    retval, is_region, pos_start, pos_end, name, idx, color = reaper.EnumProjectMarkers3(0, markeridx)
    reaper.SetProjectMarker3( 0, idx, is_region, pos_start, pos_end, name, new_color )
  -- 7. Current Region
  elseif regionidx >= 0 then
    retval, is_region, pos_start, pos_end, name, idx, color = reaper.EnumProjectMarkers3(0, regionidx)
    reaper.SetProjectMarker3( 0, idx, is_region, pos_start, pos_end, name, new_color )
  end
end

function Init()
  reaper.PreventUIRefresh( 1 )
  
  reaper.Undo_BeginBlock()
  
  Main()
  
  reaper.UpdateArrange()
  
  reaper.Undo_EndBlock( script_name, 0 )
  
  reaper.PreventUIRefresh( - 1 )
end

if not preset_file_init then
  Init()
end
