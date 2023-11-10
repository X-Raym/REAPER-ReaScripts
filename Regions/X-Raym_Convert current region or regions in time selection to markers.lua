--[[
 * ReaScript Name: Convert current region or regions in time selection to markers
 * Screenshot: https://i.imgur.com/wb7yhVs.gif
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

------------------------------------------------------- END OF USER CONFIG AREA

regions = {}

-- UTILITIES -------------------------------------------------------------

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

function SaveRegions( start_pos, end_pos )
  local i=0
  repeat
    local iRetval = SaveRegion( i, start_pos, end_pos )
    i = i+1
  until iRetval == 0
end

function SaveRegion( i, start_pos, end_pos )
  local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
  if iRetval >= 1 then
    if bIsrgnOut and iPosOut >= start_pos and iRgnendOut <= end_pos then
      local region = {}
      region.pos_start = iPosOut
      region.pos_end = iRgnendOut
      region.color = iColorOur -- In case field is only $blank to clear
      region.name = sNameOut
      region.idx = iMarkrgnindexnumberOut
      table.insert( regions, region )
    end
  end
  return iRetval
end

-- Main function
function Main()

  for z, region in ipairs(regions) do
    reaper.DeleteProjectMarker( 0, region.idx, true )
    reaper.AddProjectMarker2(0, false, region.pos_start, 0, region.name, region.idx, region.color )
  end

end


-- INIT -------------------------------------------------------------
--
-- GET TIME SELECTION
start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

-- IF TIME SELECTION
if start_time ~= end_time then
  SaveRegions(start_time, end_time)
else
  cur_pos = reaper.GetCursorPosition()
  marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion( 0, cur_pos )
  local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,region_idx)
  if iRetval >= 1 then
    SaveRegion(region_idx, iPosOut, iRgnendOut)
  end
end


if #regions > 0 then

    reaper.PreventUIRefresh(1)

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    reaper.ClearConsole()

    Main()

    reaper.Undo_EndBlock("Convert current region or regions in time selection to markers", -1) -- End of the undo block. Leave it at the bottom of your main function.

    reaper.UpdateArrange()

    reaper.UpdateTimeline()

    reaper.PreventUIRefresh(-1)

end
