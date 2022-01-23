--[[
 * ReaScript: Create text items on first selected track from grid lines division in time selection (named and colored with regions)
 * Screenshot: https://i.imgur.com/Kb2hAQR.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2022-01-23)
  + Measure+ Beats instead of full beats
 * v1.0 (2022-01-13)
  + Initial Release
--]]

-- USER CONFIG AREA --------------

measure_color = 1
measure_r = 0
measure_g = 128
measure_b = 0

beat_color = 0
beat_r = 128
beat_g = 0
beat_b = 128

if not reaper.BR_GetClosestGridDivision then
  reaper.ShowMessageBox( 'Please Install last SWS extension.\nhttps://www.sws-extension.org', 'Migissing Dependency', 0 )
  return false
end

------- END OF USER CONFIG AREA --

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val) .."\n")
end

-- Round at two decimal
-- By Igor Skoric
function round( val, num )
  local mult = 10^(num or 0)
  if val >= 0 then return math.floor(val * mult + 0.5) / mult
  else return math.ceil(val*mult-0.5) / mult end
end

-- CREATE TEXT ITEMS
-- text and color are optional
function CreateTextItem(track, position, length, text, color)

  local item = reaper.AddMediaItemToTrack(track)

  reaper.SetMediaItemInfo_Value(item, "D_POSITION", position)
  reaper.SetMediaItemInfo_Value(item, "D_LENGTH", length)

  if text ~= nil then
    reaper.ULT_SetMediaItemNote(item, text)
  end

  if color ~= nil then
    reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)
  end

  return item

end

function main()

  last_time = ts_start

  if measure_color ~= 0 then
    measure_color = reaper.ColorToNative( measure_r, measure_g, measure_b )|0x1000000
  end
  if beat_color ~= 0 then
    beat_color = reaper.ColorToNative( beat_r, beat_g, beat_b )|0x1000000
  end

  time = reaper.BR_GetClosestGridDivision( last_time )
  time_next = reaper.BR_GetNextGridDivision( time )
  if tostring(time) == tostring(ts_start) then
    local color = 0
    local retval, measures, cml, fullbeats, cdenom = reaper.TimeMap2_timeToBeats( proj, time )
    local pos_str = reaper.format_timestr_pos( time, "", 2 ):gsub(".00$", "")
    local name = pos_str
    
    if beat_color ~=0 then
     color = beat_color
    end

    if measure_color ~= 0 and round(retval, 10) % cml == 0 then
     color = measure_color
    end
    markeridx, regionidx = reaper.GetLastMarkerAndCurRegion( 0, time )
    if regionidx >= 0 then
      retval_region, _, region_pos, region_end, region_name, region_index, region_color = reaper.EnumProjectMarkers3(0, regionidx)
      if region_name == "" then region_name = region_index end
      name = region_name .. " - " .. name
      if color == beat_color then color = region_color end
    end
    CreateTextItem(track, time, time_next - time, name, color)
  end

  -- INITIALIZE loop through selected items
  repeat

    local time = reaper.BR_GetNextGridDivision( last_time )
    
    if time >= ts_end then break end
    
    local time_next = reaper.BR_GetNextGridDivision( time )
    local color = 0
    local retval, measures, cml, fullbeats, cdenom = reaper.TimeMap2_timeToBeats( proj, time )
    local pos_str = reaper.format_timestr_pos( time, "", 2 ):gsub(".00$", "")
    local name = pos_str

    if beat_color ~=0 then
      color = beat_color
    end

    if measure_color ~= 0 and round(retval, 10) % cml == 0 then
      color = measure_color
    end

    if time <= ts_end then
      markeridx, regionidx = reaper.GetLastMarkerAndCurRegion( 0, time )
      if regionidx >= 0 then
        retval_region, _, region_pos, region_end, region_name, region_index, region_color = reaper.EnumProjectMarkers3(0, regionidx)
        if region_name == "" then region_name = region_index end
        name = region_name .. " - " .. name
        if color == beat_color then color = region_color end
      end
      CreateTextItem(track, time, time_next - time, name, color)
    end
    last_time = time

  until last_time >= ts_end -- ENDLOOP through selected items

end

ts_start, ts_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
track = reaper.GetSelectedTrack(0,0)

if ts_start ~= ts_end and track then

  reaper.ClearConsole()

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock()

  main()

  reaper.Undo_EndBlock("Create text items on first selected track from grid lines division in time selection (named and colored with regions)", -1)

  reaper.PreventUIRefresh(-1)

  reaper.UpdateArrange()

end

