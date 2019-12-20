--[[
 * ReaScript Name: Script: Export selected items as tab-delimited regions CSV
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
 * Version: 1.1.1
--]]

--[[
 * Changelog:
 * v1.1.1 (2019-12-20)
  # Break lines for notes
 * v1.1 (2019-12-20)
  + Notes and Names
 * v1.0 (2019-11-20)
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
  
  export(f, "#\tName\tStart\tEnd\tLength\tColor\tNotes")
  
  for i = 0, count_sel_items - 1 do
    item = reaper.GetSelectedMediaItem(0, i)
    iPosOut = reaper.GetMediaItemInfo_Value(item, "D_POSITION") --get itemstart
    duration = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") --get length
    iRgnendOut = iPosOut + duration
    iColorOur = reaper.GetDisplayedMediaItemColor(item)
    name = ''
    take = reaper.GetActiveTake(item)
    if take then
      name = reaper.GetTakeName(take)
    end
    notes = reaper.ULT_GetMediaItemNote( item )
    bIsrgnOut = true
    
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
    notes = notes:gsub('\r\n', '<br>')
    notes = notes:gsub('\n', '<br>')
    line = t .. i .. "\t\"" .. name .. "\"\t" .. iPosOut .. "\t" .. iRgnendOut .. "\t" .. duration .. "\t" .. color .. "\t\"" .. notes .. "\""
    export(f, line)
  end

  -- CLOSE FILE
  f:close() -- never forget to close the file
end


if not reaper.JS_Dialog_BrowseForSaveFile then
  Msg("Please install JS_ReaScript REAPER extension, available in Reapack extension, under ReaTeam Extensions repository.")
else
 
 count_sel_items = reaper.CountSelectedMediaItems(0)
 if count_sel_items then
   retval, file = reaper.JS_Dialog_BrowseForSaveFile( "Export items to CSV", '', "", 'csv files (.csv)\0*.csv\0All Files (*.*)\0*.*\0' )
  
   if retval and file ~= '' then
    if not file:find('.csv') then file = file .. ".csv" end
    reaper.defer(Main)
   end

  end

end
