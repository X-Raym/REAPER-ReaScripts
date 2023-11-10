--[[
 * ReaScript Name: Convert last marker or marker in time selection to regions
 * Screenshot: https://i.imgur.com/zK1vkhd.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Forum Thread: Scripts: Regions and Markers (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?p=1670961
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2023-11-08)
  + Initial Release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console
default_length = 1 -- seconds

------------------------------------------------------- END OF USER CONFIG AREA

markers = {}

-- UTILITIES -------------------------------------------------------------

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
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
      marker.pos_end = iRgnendOut
      marker.color = iColorOur -- In case field is only $blank to clear
      marker.name = sNameOut
      marker.idx = iMarkrgnindexnumberOut
      table.insert( markers, marker )
    end
  end
  return iRetval
end

-- Main function
function Main()

  for z, marker in ipairs(markers) do
    reaper.DeleteProjectMarker( 0, marker.idx, false )
    reaper.AddProjectMarker2(0, true, marker.pos_start, markers[z+1] and markers[z+1].pos_start or marker.pos_start + default_length, marker.name, marker.idx, marker.color )
  end

end


-- INIT -------------------------------------------------------------
--
-- GET TIME SELECTION
start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

-- IF TIME SELECTION
if start_time ~= end_time then
  SaveMarkers(start_time, end_time)
else
  cur_pos = reaper.GetCursorPosition()
  marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion( 0, cur_pos )
  local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,marker_idx)
  if iRetval >= 1 then
    SaveMarker(marker_idx, iPosOut, iPosOut)
  end
end


if #markers > 0 then

    reaper.PreventUIRefresh(1)

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    reaper.ClearConsole()

    Main()

    reaper.Undo_EndBlock("Convert last marker or marker in time selection to regions", -1) -- End of the undo block. Leave it at the bottom of your main function.

    reaper.UpdateArrange()

    reaper.UpdateTimeline()

    reaper.PreventUIRefresh(-1)

end
