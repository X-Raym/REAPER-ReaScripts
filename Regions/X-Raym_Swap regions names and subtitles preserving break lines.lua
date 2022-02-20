--[[
 * ReaScript Name: Swap regions names and subtitles preserving break lines
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
]]


--[[
 * Changelog:
 * v1.0 (2022-02-20)
  + Initial Release
]]

function main()

  -- LOOP IN REGIONS
  i=0
  repeat

    retval, isrgn, pos, rgnend, name, markrgnindex, color = reaper.EnumProjectMarkers3(0, i)
    notes = reaper.NF_GetSWSMarkerRegionSub( i )
    
    notes = notes:gsub("\n", "<br/>")
    name = name:gsub("<br/>", "\n")

    reaper.NF_SetSWSMarkerRegionSub( name,i )
    if notes and notes ~= "" then
      reaper.SetProjectMarker3( 0, markrgnindex, isrgn, pos, rgnend, notes, color )
    else
      reaper.SetProjectMarker4( 0, markrgnindex, isrgn, pos, rgnend, notes, color, 1 ) -- Clear region name: https://forums.cockos.com/showthread.php?p=1888945
    end


    i = i+1
  until retval == 0 -- end loop regions and markers

end

-- RUN
if not reaper.ULT_SetMediaItemNote then 
  reaper.ShowConsoleMsg("SWS extension is required by this script.\nHowever, it doesn't seem to be present for this REAPER installation.\n\nDownload it here:\nhttp://www.sws-extension.org/download/")
  return false
end

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begin undo group

main()

reaper.Undo_EndBlock("Swap regions names and subtitles preserving break lines", -1) -- End undo group

reaper.TrackList_AdjustWindows(false)

reaper.PreventUIRefresh(-1)


