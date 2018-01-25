--[[
 * ReaScript Name: Set UltraStar project metadata
 * Description: See title.
 * Instructions: Select a track. Run. Supports both UltraStar Creator and YASS syntax.
 * Screenshot: https://youtu.be/z1K98a7AWNA
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Creating Karaoke Songs for UltraStar and Vocaluxe with REAPER
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=202430
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2018-01-25)
  + Initial Release
--]]

console = false

reaper.ClearConsole()

reaper.Undo_BeginBlock() -- Begining of the undo block.

-- Display Messages in the Console
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value).."\n")
  end
end

meta = {}
i = 0
repeat
  local retval, key, val = reaper.EnumProjExtState( proj, "UltraStar", i )
  meta[key] = val
  i = i + 1
until not retval

header_fields = {"TITLE", "ARTIST", "LANGUAGE", "YEAR", "GENRE", "CREATOR", "EDITION"}
header_csv = table.concat(header_fields, ",")

meta_csv = ""
for i, field in ipairs( header_fields )do
  local suffix = meta[field] or "/blank"
  meta_csv = meta_csv .. suffix .. ","
end

local retval, retvals_csv = reaper.GetUserInputs( "UltraStar Metadata", #header_fields, header_csv .. ',extrawidth=150', meta_csv )

if retval then
  local input = {}
  input.TITLE, input.ARTIST, input.LANGUAGE, input.YEAR, input.GENRE, input.CREATOR, input.EDITION = retvals_csv:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
  for i, v in ipairs( header_fields ) do
    if input[v] ~= "/blank" then
      reaper.SetProjExtState( 0, "UltraStar", v, input[v])
    else
      reaper.SetProjExtState( 0, "UltraStar", v, "")
    end
  end
end

reaper.Undo_EndBlock("Set UltraStar project metadata", 0) -- End of the undo block.
