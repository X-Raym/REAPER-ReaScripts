--[[
 * ReaScript Name: Import UltraStar txt
 * Instructions: Select atrack. Run. Supports both UltraStar Creator and YASS syntax.
 * Screenshot: https://youtu.be/z1K98a7AWNA
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Creating Karaoke Songs for UltraStar and Vocaluxe
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=202430
 * REAPER: 5.0
 * Version: 1.0.10
--]]

--[[
 * Changelog:
 * v1.0.9 (2023-02-09)
  # Prevent snapping of inserted text event
 * v1.0.8 (2023-02-08)
  # Insert as last track on the project
  # Be sure it is good timebase
  + Save last input path
 * v1.0.7 (2020-03-15)
  + Correction of lyrics format in project notes
 * v1.0.6 (2020-03-14)
  + Override project notes with lyrics
 * v1.0.5 (2019-05-11)
  # Fix Marker beat error if invalid line
 * v1.0.4 (2019-05-11)
  # More flexible page pattern
 * v1.0.3 (2019-01-03)
  # video and audio track to Time timebase
 * v1.0.2 (2019-01-02)
  # All notes off fix
 * v1.0.1 (2018-02-08)
  # Split name with MacOS separator
 * v1.0 (2018-01-25)
  + Initial Release
--]]

function Msg(variable)
  reaper.ShowConsoleMsg(tostring(variable).."\n")
end

-- https://www.fhug.org.uk/wiki/wiki/doku.php?id=plugins:code_snippets:split_filename_in_to_path_filename_and_extension
function SplitFilename(strFilename)
  -- Returns the Path, Filename, and Extension as 3 values
  return string.match(strFilename, "(.-)([^\\|/]-([^\\|/%.]+))$")
end

function InsertFile( file, folder, tag )
  local count_track = reaper.CountTracks( 0 )
  local track = reaper.GetTrack( 0 , count_track - 1 )
  reaper.SetOnlyTrackSelected( track )
  reaper.InsertMedia( folder .. file, 1 )
  local count_track = reaper.CountTracks( 0 )
  local track = reaper.GetTrack( 0 , count_track - 1 )
  local retval, stringNeedBig = reaper.GetSetMediaTrackInfo_String( track, "P_NAME", tag, true )
  if tag == "Video" then reaper.SetMediaTrackInfo_Value( track, "D_VOL", 0 ) end
  reaper.SetMediaTrackInfo_Value( track, "C_BEATATTACHMODE", 0 )
end

function SetUltraStarMetadata( key, value )
  reaper.SetProjExtState( 0, "UltraStar", key, value)
end

-- https://stackoverflow.com/questions/10386672/reading-whole-files-in-lua
function readAll(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block.

reaper.ClearConsole()

folder = reaper.GetExtState( "XR_UltrastarImport", "Folder" ) or ""

retval, path = reaper.GetUserFileNameForRead(folder, "Open", ".txt" )
if not retval then return end

folder, filename, ext = SplitFilename(path)
reaper.SetExtState( "XR_UltrastarImport", "Folder", folder, true )

content = readAll(path)

-- content = reaper.GetSetProjectNotes(0, false, '') -- NOTE: For dev only

-- Split Lines
lines = {}
for s in content:gmatch("[^\r\n]+") do
    table.insert(lines, s)
end

-- Create a Lyrics Track and a MIDI Lyrics Items
reaper.InsertTrackAtIndex( -1, true )
local count_track = reaper.CountTracks( 0 )
track_midi = reaper.GetTrack( 0 , count_track - 1 )
local retval, track_name = reaper.GetSetMediaTrackInfo_String( track_midi, "P_NAME", "Lyrics", true )
reaper.SetEditCurPos(0, true, false)
item = reaper.CreateNewMIDIItemInProj( track_midi, 0, 100, false ) -- 100 is arbitrary but length is adjusted in the end
take = reaper.GetActiveTake( item )
local retval, take_name = reaper.GetSetMediaItemTakeInfo_String( take, "P_NAME", "Lyrics", true )

last_beat = 0
lyrics = {}
lyric_line = ""
for i, line in ipairs( lines ) do -- redundant but useful
  local line = line:gsub(string.char(0), "")
  line = line:gsub("\n", "")
  if not bpm and line:find('#BPM:' ) then
    bpm = string.gsub(line:match('#BPM:(.+)' ), ",", ".")
    bpm = tonumber( bpm )
    reaper.SetTempoTimeSigMarker( 0, -1, 0, 0, 0, bpm, 4, 4, true )
  elseif not video and line:find('#VIDEO:' ) then
    video = line:match('#VIDEO:(.+)')
    InsertFile( video, folder, 'Video')
  elseif not audio and line:find('#MP3:' ) then
    audio = line:match('#MP3:(.+)')
    InsertFile( audio, folder, 'Audio' )
  elseif not gap and line:find('#GAP:' ) then
    gap = string.gsub(line:match('#GAP:(.+)' ), ",", ".")
    gap = tonumber( gap ) / 1000
    gap_beat = reaper.TimeMap2_timeToQN( 0, gap ) / 4
  elseif string.sub(line, 1, 1) == "#" then
    local key, value = line:match('#(.+)%:(.+)')
    if key and value then SetUltraStarMetadata( key, value ) end
  else
    local char = string.sub(line, 1, 1)
    if char == ":" or char == "*" or char == "F" then -- Add Notes and Lyrics
      local chan
      if char == "*" then chan = 1 elseif char == "F" then chan = 2 else chan = 0 end
      local prefix, beat, length, pitch, lyric = line:match('(%S) (%S+) (%S+) (%S+)%s?(.+)')
      lyric_line = lyric_line .. "+" .. lyric
      pitch = tonumber(pitch) + 60
      beat = reaper.TimeMap2_QNToTime( 0, tonumber( beat ) ) / 4 -- / 4 because UltraStar needs it
      length = reaper.TimeMap2_QNToTime( 0, tonumber(length) ) / 4 -- / 4 because UltraStar needs it
      local startppqpos = reaper.MIDI_GetPPQPosFromProjTime( take, beat )
      local endppqpos = reaper.MIDI_GetPPQPosFromProjTime( take, beat + length )
      reaper.MIDI_InsertNote( take, false, false, startppqpos, endppqpos, chan, pitch, 100, true )
      reaper.MIDI_InsertTextSysexEvt( take, false, false, startppqpos, 5, lyric )
    elseif char == "-" then -- Add page
      table.insert( lyrics, lyric_line)
      lyric_line = ""
      local beat = line:match(" ?-?(%d+)") -- Note: this support [- XX] but not [- XX YY] where
      beat = tonumber(beat)
      if beat then
        local beat_pos = reaper.TimeMap2_QNToTime( 0, beat ) / 4 -- / 4 because UltraStar needs it
        reaper.AddProjectMarker( 0, 0, beat_pos + gap, 0, "", -1 )
        last_beat = beat_pos
      else
        Msg("Error in line :" .. i)
      end
    else
    end
  end
end

for i, lyric in ipairs( lyrics ) do
  lyrics[i] = lyric:sub(2, -1)
end
retval = reaper.GetSetProjectNotes( 0, true, string.gsub(table.concat(lyrics, "\r\n"), "+ ", " " ) )

reaper.SetMediaItemInfo_Value( item, "D_POSITION", gap )
reaper.SetMediaItemInfo_Value( item, "D_LENGTH", last_beat )

-- Remove all notes off events added by the fact the item is created with arbitrary length and extended after
retval, notecnt, ccs, textsyxevtcnt = reaper.MIDI_CountEvts( take )
for i = 0, ccs - 1 do
  reaper.MIDI_DeleteCC( take, ccs - i - 1 )
end
reaper.MIDI_Sort( take )

reaper.Main_OnCommand( 40297, 0 ) -- Track: Unselect (clear selection of) all tracks

reaper.Undo_EndBlock("Export first selected track MIDI as UltraStar txt file", 0) -- End of the undo block.

reaper.PreventUIRefresh(-1)
