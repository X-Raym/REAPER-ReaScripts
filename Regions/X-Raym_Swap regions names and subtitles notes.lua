--[[
 * ReaScript Name: Swap regions names and subtitles notes
 * Screenshot: https://i.imgur.com/GDv9OtL.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Extensions: SWS/S&M 2.12.1
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-02-09)
  + Initial Release
--]]

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
      region.id = i
      region.idx = iMarkrgnindexnumberOut
      region.note = reaper.NF_GetSWSMarkerRegionSub( i )
      table.insert( regions, region )
    end
  end
  return iRetval
end

function Main()

  for z, region in ipairs(regions) do

    -- GET NOTES
    local note = region.note:gsub("\n", "<br/>")
    local name = region.name:gsub("<br/>", "\n")

    -- SET
    reaper.NF_SetSWSMarkerRegionSub(name, region.id)
    reaper.SetProjectMarkerByIndex2( 0, region.id, true, region.pos_start, region.pos_end, region.idx, note, region.color,0 )
  end

  reaper.NF_UpdateSWSMarkerRegionSubWindow()

end

regions = {}

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


reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

Main() -- Execute your main function

reaper.Undo_EndBlock("Swap regions names and subtitles notes", 0) -- End of the undo block. Leave it at the bottom of your main function.

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.UpdateTimeline()
