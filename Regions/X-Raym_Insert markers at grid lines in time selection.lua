--[[
 * ReaScript Insert markers at grid lines in time selection
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2019-11-02)
  + Initial Release
--]]

-- USER CONFIG AREA --------------

measure_color = 1
measure_r = 0
measure_g = 128
measure_b = 0

beat_color = 1
beat_r = 128
beat_g = 0
beat_b = 128

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

function main()

  last_time = ts_start

  if measure_color ~= 0 then
    measure_color = reaper.ColorToNative( measure_r, measure_g, measure_b )|0x1000000
  end
  if beat_color ~= 0 then
    beat_color = reaper.ColorToNative( beat_r, beat_g, beat_b )|0x1000000
  end

  time = reaper.BR_GetClosestGridDivision( last_time )
  if time == ts_start then
  local color = 0
  local retval, measures, cml, fullbeats, cdenom = reaper.TimeMap2_timeToBeats( proj, time )
  if beat_color ~=0 then
   color = beat_color
  end

  if measure_color ~= 0 and round(retval, 10) % cml == 0 then
   color = measure_color
  end
  reaper.AddProjectMarker2(0, false, time, 0, "", -1, color)
  end

  -- INITIALIZE loop through selected items
  repeat

    local time = reaper.BR_GetNextGridDivision( last_time )
    local color = 0
    local retval, measures, cml, fullbeats, cdenom = reaper.TimeMap2_timeToBeats( proj, time )

    if beat_color ~=0 then
  color = beat_color
    end

    if measure_color ~= 0 and round(retval, 10) % cml == 0 then
  color = measure_color
    end

    if time <= ts_end then
  reaper.AddProjectMarker2(0, false, time, 0, "", -1, color)
    end
    last_time = time

  until last_time > ts_end -- ENDLOOP through selected items

end

ts_start, ts_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

if ts_start ~= ts_end then

  reaper.ClearConsole()

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock()

  main()

  reaper.Undo_EndBlock("Insert markers at grid lines in time selection", -1)

  reaper.PreventUIRefresh(-1)

  reaper.UpdateArrange()

end
