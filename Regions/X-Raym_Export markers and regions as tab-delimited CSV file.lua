--[[
 * ReaScript Name: Export markers and regions from tab-delimited CSV file
 * Description: See title.
 * Instructions: Select a track. Run.
 * Author: X-Raym
 * Author URI: http://www.extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Links
    Forum Thread https://forum.cockos.com/showthread.php?p=1670961
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.3
--]]

--[[
 * Changelog:
 * v1.0.3 (2019-12-20)
  # Msg
 * v1.0.2 (2019-11-20)
  # Header tab
 * v1.0.1 (2019-01-26)
  # Extension
 * v1.0 (2019-01-26)
  + Initial Release
--]]

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

function export(f, variable)
  f:write(variable)
  f:write("\n")
end

function rgbToHex(r, g, b)
    return string.format("#%0.2X%0.2X%0.2X", r, g, b)
end

function Main()

  local f = io.open(file, "w")
  
  export(f, "#\tName\tStart\tEnd\tLength\tColor")
  
  i=0
  repeat
    iRetval, bIsrgnOut, iPosOut, iRgnendOut, name, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
    if iRetval >= 1 then
      local t, duration
      if bIsrgnOut then
        t = "R"
        duration = iRgnendOut - iPosOut
      else 
        t = "M"
        duration = 0
        iRgnendOut = iPosOut
      end
      
      local color = 0
      if iColorOur > 0 then
        r,g,b = reaper.ColorFromNative(iColorOur)
        color = rgbToHex(r, g, b)
      end
        -- [start time HH:MM:SS.F] [end time HH:MM:SS.F] [name]
        line = t .. iMarkrgnindexnumberOut .. "\t\"" .. name .. "\"\t" .. iPosOut .. "\t" .. iRgnendOut .. "\t" .. duration .. "\t" .. color
        export(f, line)
      end
      i = i+1
  until iRetval == 0

  -- CLOSE FILE
  f:close() -- never forget to close the file
end


if not reaper.JS_Dialog_BrowseForSaveFile then
  Msg("Please install JS_ReaScript REAPER extension, available in Reapack extension, under ReaTeam Extensions repository.")
else

 retval, file = reaper.JS_Dialog_BrowseForSaveFile( "Save Markers and Regions", '', "", 'csv files (.csv)\0*.csv\0All Files (*.*)\0*.*\0' )

 if retval and file ~= '' then
  reaper.defer(Main)
 end
  
end
