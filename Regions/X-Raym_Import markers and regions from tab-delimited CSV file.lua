--[[
 * ReaScript Name: Import markers and regions from tab-delimited CSV file
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
 * Version: 1.2.1
--]]

--[[
 * Changelog:
 * v1.2.1 (2020-06-03)
  # color fix
 * v1.2 (2020-06-03)
  + Support for Markers and Regions subtitles notes
 * v1.1 (2020-01-15)
  + Import at cursor position option
 * v1.0 (2019-01-26)
  + Initial Release
--]]

-- USER CONFIG AREA -----------------------------------------------------------
-- Duplicate and Rename the script if you want to modify this.
-- Else, a script update will erase your mods.

console = true -- true/false: display debug messages in the console
sep = "\t" -- default sep
popup = true

col_pos = 3 -- Position column index in the CSV
col_pos_end = 4 -- Length column index in the CS
col_len = 5 -- Length column index in the CSV
col_name = 2 -- Name column index in the CSV
col_color = 6
col_sub = 7

------------------------------------------------------- END OF USER CONFIG AREA

function ColorHexToInt(hex)
  hex = hex:gsub("#", "")
  local R = tonumber("0x"..hex:sub(1,2))
  local G = tonumber("0x"..hex:sub(3,4))
  local B = tonumber("0x"..hex:sub(5,6))
  return reaper.ColorToNative(R, G, B)
end

-- Optimization
local reaper = reaper

-- CSV to Table
-- http://lua-users.org/wiki/LuaCsv
function ParseCSVLine (line,sep)
  local res = {}
  local pos = 1
  sep = sep or ','
  while true do
    local c = string.sub(line,pos,pos)
    if (c == "") then break end
    if (c == '"') then
      -- quoted value (ignore separator within)
      local txt = ""
      repeat
        local startp,endp = string.find(line,'^%b""',pos)
        txt = txt..string.sub(line,startp+1,endp-1)
        pos = endp + 1
        c = string.sub(line,pos,pos)
        if (c == '"') then txt = txt..'"' end
        -- check first char AFTER quoted string, if it is another
        -- quoted string without separator, then append it
        -- this is the way to "escape" the quote char in a quote. example:
        --   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
      until (c ~= '"')
      table.insert(res,txt)
      assert(c == sep or c == "")
      pos = pos + 1
    else
      -- no quotes used, just look for the first separator
      local startp,endp = string.find(line,sep,pos)
      if (startp) then
        table.insert(res,string.sub(line,pos,startp-1))
        pos = endp + 1
      else
        -- no separator found -> use rest of string and terminate
        table.insert(res,string.sub(line,pos))
        break
      end
    end
  end
  return res
end


-- UTILITIES -------------------------------------------------------------

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

--------------------------------------------------------- END OF UTILITIES

function read_lines(filepath)

  lines = {}

  local f = io.input(filepath)
  repeat

    s = f:read ("*l") -- read one line

    if s then  -- if not end of file (EOF)
      table.insert(lines, ParseCSVLine (s,sep))
    end

  until not s  -- until end of file

  f:close()

end

-- Main function
function main()

  folder = filetxt:match[[^@?(.*[\/])[^\/]-$]]
  
  subs = {}
  subs_count = 0

  for i, line in ipairs( lines ) do
    if i > 1 then

      -- Name Variables
      local pos = tonumber(line[col_pos])
      local pos_end = tonumber(line[col_pos_end])
      local len =  tonumber( line[col_len] )
      local name = line[col_name]
      local color = 0
      if line[col_color] and line[col_color] ~= "0" then
        color = ColorHexToInt(line[col_color])|0x1000000
      end
      sub = line[col_sub]
      if sub then sub = sub:gsub("<br>", "\n") end
      
      local is_region = true
      
      if pos_end == pos then
        is_region = false
      end
      
      if pos and pos_end and name and color then
        idx = reaper.AddProjectMarker2( 0, is_region, pos + cur_pos, pos_end + cur_pos, name, -1, color )
        if sub and reaper.NF_SetSWSMarkerRegionSub then
          subs[idx] = sub
          subs_count = subs_count + 1
        end
      end
      
    end
  end
  
  -- This is because there is no Get marker by IDX...
  if subs_count > 0 then
    i=0
    repeat
      iRetval, bIsrgnOut, iPosOut, iRgnendOut, name, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
      if iRetval >= 1 and subs[iMarkrgnindexnumberOut] then
        reaper.NF_SetSWSMarkerRegionSub( subs[iMarkrgnindexnumberOut], i )
      end
      i = i+1
    until iRetval == 0
    reaper.NF_UpdateSWSMarkerRegionSubWindow()
  end

end

-- INIT

retval, filetxt = reaper.GetUserFileNameForRead("", "Import markers and regions", "csv")

if retval then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  reaper.ClearConsole()

  read_lines(filetxt)
  
  cur_pos = 0
  
  if popup and reaper.GetCursorPosition() > 0 then
    from_cur_pos = reaper.MB("Import from Edit Cursor position?", "Option", 1)
    if from_cur_pos == 1 then
      cur_pos = reaper.GetCursorPosition()
    end
  end
  
  -- reaper.Main_OnCommand( reaper.NamedCommandLookup( "_SWSMARKERLIST10" ), -1) -- SWS: Delete all regions

  main()

  reaper.Undo_EndBlock("Import markers and regions from tab-delimited CSV", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end
