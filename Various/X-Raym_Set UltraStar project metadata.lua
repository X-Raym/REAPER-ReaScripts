--[[
 * ReaScript Name: Set UltraStar project metadata
 * Instructions: Select a track. Run. Supports both UltraStar Creator and YASS syntax.
 * Screenshot: https://youtu.be/z1K98a7AWNA
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Creating Karaoke Songs for UltraStar and Vocaluxe with REAPER
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=202430
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2023-08-09)
  # Escpae quotes and apostrophe
  + More fields compatibility
 * v1.0 (2018-01-25)
  + Initial Release
--]]

console = true

sep = "\n"

reaper.ClearConsole()

reaper.Undo_BeginBlock() -- Begining of the undo block.

-- Display Messages in the Console
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value).."\n")
  end
end

function GetTracksByName()
  local tracks = {}
  local count_tracks = reaper.CountTracks( 0 )
  for i = 0, count_tracks - 1 do
    local track = reaper.GetTrack( 0, i )
    local retval, track_name = reaper.GetTrackName( track )
    if not tracks[track_name:upper()] then tracks[track_name:upper()] = track end
  end
  return tracks
end

function GetInfoFromFirstItemOnTrack( name )
  if (not meta[name] or meta[name] == "") and tracks_by_name[name] then
    local first_item = reaper.GetTrackMediaItem( tracks_by_name[name], 0 )
    if first_item then
      local first_take = reaper.GetActiveTake( first_item )
      if first_take then
        local first_take_name = reaper.GetTakeName( first_take )
        meta[name] = first_take_name
      end
    end
  end
end

function GetUltraStartExtState()
  meta = {}
  keys = {}
  local i = 0
  repeat
    local retval, key, val = reaper.EnumProjExtState( proj, "UltraStar", i )
    if retval then
      meta[key] = val
      table.insert( keys, key )
    end
    i = i + 1
  until not retval
end

GetUltraStartExtState()

header_fields = {"TITLE", "ARTIST", "LANGUAGE", "YEAR", "GENRE", "CREATOR", "EDITION", "VIDEO", "MP3"}
check_header_fields = {}
for i, v in ipairs( header_fields ) do
  check_header_fields[v] = true
end
for i, key in ipairs( keys ) do
  if not check_header_fields[key] then
    table.insert( header_fields, key )
  end
end
header_csv = table.concat(header_fields, sep)

tracks_by_name = GetTracksByName()
GetInfoFromFirstItemOnTrack( "VIDEO" )
GetInfoFromFirstItemOnTrack( "AUDIO" )
meta["MP3"] = meta["AUDIO"]
meta["AUDIO"] = nil

meta_csv = {}
for i, field in ipairs( header_fields )do
  str = meta[field] or ""
  str = str:gsub("'", "’") -- Escape apostrophe
  str = str:gsub( '"', "ʺ") -- Escape double quote
  table.insert( meta_csv, str)
end
meta_csv = table.concat(meta_csv, sep)

local retval, retvals_csv = reaper.GetUserInputs( "UltraStar Metadata", #header_fields, header_csv .. '\nseparator=\n\nextrawidth=200', meta_csv )

if retval then
  retvals_csv = retvals_csv:gsub("’", "'") -- Escape apostrophe
  retvals_csv = retvals_csv:gsub("ʺ", '"') -- Escape double quote
  input = {}
  local i = 0
  for line in retvals_csv:gmatch("[^" .. sep .. "]*") do
    i = i + 1
    input[header_fields[i]] = line
  end

  for i, v in ipairs( header_fields ) do
    reaper.SetProjExtState( 0, "UltraStar", v, input[v])
  end
end

reaper.Undo_EndBlock("Set UltraStar project metadata", -1) -- End of the undo block.