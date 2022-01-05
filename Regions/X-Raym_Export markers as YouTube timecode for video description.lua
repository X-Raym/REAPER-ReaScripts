--[[
 * ReaScript Name: Export markers as YouTube timecode for video description
 * Screenshot: http://i.imgur.com/KFoTA3a.gif
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Regions and Markers (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=175819
 * REAPER: 5.0
 * Version: 1.1.2
--]]

--[[
 * Changelog:
 * v1.1.2 (2021-31-12)
  # Remove leading ":"
 * v1.1.1 (2020-12-09)
  + Output marker at timecode 0
 * v1.1 (2017-01-03)
  # New format
  + Don't consider marker before project time 0
  + Don't output hour if no markers is over one hour
 * v1.0 (2016-11-10)
  + Initial Release
--]]


-- USER CONFIG AREA ---------------------------------------------------------

console = true -- true/false: display debug messages in the console

----------------------------------------------------- END OF USER CONFIG AREA


-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end


-- Main function
function main()

  -- LOOP THROUGH REGIONS
  i=0
  repeat
    iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
    if iRetval >= 1 then
      if bIsrgnOut == false then
        -- ACTION ON MARKERS HERE
        abs_pos = tonumber( reaper.format_timestr_pos( math.floor( iPosOut ), "", 3 ) )
        if abs_pos and abs_pos >= 0 then
          pos = reaper.format_timestr_pos( math.floor( iPosOut ), "", 5 )
          pos = pos:sub(2, -4)
          marker = {}
          marker.name = sNameOut
          marker.pos = pos
          table.insert( markers, marker )
          if abs_pos >= 3600 then
            hour = true
          end
        end
      end
      i = i+1
    end
  until iRetval == 0

  for i, marker in ipairs( markers ) do

    local pos = ""
    if hour then
      pos = marker.pos
    else
      pos = marker.pos:sub(3)
    end

    Msg(pos .. " - " .. marker.name)

  end

end

-- INIT ---------------------------------------------------------------------

total, num_markers, num_regions = reaper.CountProjectMarkers( -1 )

if num_markers > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  reaper.ClearConsole()

  markers = {}

  main()

  reaper.Undo_EndBlock("Export markers as YouTube timecode for video description", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end

