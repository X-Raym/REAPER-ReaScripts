--[[
 * ReaScript Name: Export markers as YouTube timecode for video description
 * Description: See title.
 * Instructions: Run
 * Screenshot: http://i.imgur.com/KFoTA3a.gif
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Regions and Markers (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=175819
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
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
        pos = reaper.format_timestr_pos( math.floor( iPosOut ), "", 5 )
        pos = pos:sub(0, -4)
        Msg("- " .. pos ..": " .. sNameOut)
      end
      i = i+1
    end
  until iRetval == 0
  
end


-- INIT ---------------------------------------------------------------------

-- Here: your conditions to avoid triggering main without reason.

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

reaper.ClearConsole()

main()

reaper.Undo_EndBlock("Export markers as YouTube timecode for video description", -1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)

