--[[
 * ReaScript Name: Export first selected track MIDI as UltraStar txt file
 * Description: Export MIDI items content, using MIDI Notes Lyrics events. One MIDI Lyric per notes. Markers are page break.
 * Instructions: Select tracks. Use it.
 * Screenshot: https://youtu.be/z1K98a7AWNA
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Creating Karaoke Songs for UltraStar and Vocaluxe with REAPER
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=202430
 * Version: 1.0.5
 * REAPER: 5.0
--]]

--[[
 * Changelog:
 * v1.0.5 (2019-01-08)
  # Force BPM to 400
 * v1.0.4 (2018-12-02)
  # Unsaved project named fix
  # No SWS dependency required
 * v1.0.3 (2018-12-02)
  # MIDI Notes chan fix
 * v1.0.2 (2018-02-08)
  # Split name with MacOS separator
 * v1.0.1 (2018-02-04)
  # Prevent return lines in lyrics export
  # Artist and Title field fix
  # No dash seperator
 * v1.0 (2018-25-01)
  + Initial Release
--]]

console = false
offset_pages_by_one_beat = false

-- bpm = reaper.Master_GetTempo()
bpm = 400

-- GLOBALS

beat_duration = 1 / (bpm / 60 )
gap = 0

prefix = {": ", "* ", "F "}

-- https://www.fhug.org.uk/wiki/wiki/doku.php?id=plugins:code_snippets:split_filename_in_to_path_filename_and_extension
function SplitFilename(strFilename)
  -- Returns the Path, Filename, and Extension as 3 values
  return string.match(strFilename, "(.-)([^\\|/]-([^\\|/%.]+))$")
end

function GetArtistAndTitle()
  proj, project_path = reaper.EnumProjects( -1, 0 )
  proj_folder, proj_name, proj_ext = SplitFilename(project_path)
  if not proj_folder then
    proj_folder = reaper.GetProjectPath('') .. "\\"
    proj_name = "Unsaved"
  end

  retval, artist = reaper.GetProjExtState( proj, "UltraStar", "ARTIST" )
  retval, title = reaper.GetProjExtState( proj, "UltraStar", "TITLE" )
  if ( not artist or artist == "" ) and ( not title or title == "" )then
    artist, title = proj_name:match('(.+) %- (.+)')
    if not artist then artist = "Artist" end
    if not title or title == "" then title = "Title" else title = title:gsub('.rpp', '') end
    reaper.SetProjExtState( 0, "UltraStar", "TITLE", title)
    reaper.SetProjExtState( 0, "UltraStar", "ARTIST", artist)
  end
  if not proj_name then proj_name = artist .. " - " .. title end
  proj_name = proj_name:gsub('.rpp', '')
end

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

function table.merge(t1, t2)
   for k,v in ipairs(t2) do
      table.insert(t1, v)
   end

   return t1
end

function SecondToBeat(second)
  local resolution = 4 -- Default is quarternote / UltraStar spec format
  local beat_pos = second / beat_duration * resolution
  return math.floor( ( beat_pos + (beat_duration / 2) ) )
end

function ProcessTakeMIDI( take, j )
  local syllables = {}

  local retval, count_notes, count_ccs, count_textsyx = reaper.MIDI_CountEvts( take )

  if count_notes == 0 or count_textsys == 0 then return end

  if j == 0 then
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, 0 )
    gap = reaper.MIDI_GetProjTimeFromPPQPos( take, startppqpos )
  end

  -- First Filter Text Event by Lyrics
  local lyrics = {}
  for i = 0, count_textsyx - 1 do
    local retval, selected, muted, ppqpos, evt_type, msg = reaper.MIDI_GetTextSysexEvt( take, i, true, true, 0, 0, "" )
    if evt_type == 5 then
      msg = msg:gsub("\r", "")
      msg = msg:gsub("^%-", "")
      table.insert(lyrics, msg)
    end
  end

  count = count_notes
  if #lyrics < count_notes then count = #lyrics end

  for i = 0, count - 1 do
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
    local start_sec = reaper.MIDI_GetProjTimeFromPPQPos( take, startppqpos ) - gap
    local end_sec = reaper.MIDI_GetProjTimeFromPPQPos( take, endppqpos ) - gap
    local len_sec = end_sec - start_sec
    local len_beats = SecondToBeat(len_sec)
    if len_beats < 1 then len_beats = 1 end
    if chan + 1 > #prefix then chan = 0 end
    local entry = {}
    entry.pos = start_sec
    entry.str = prefix[chan+1] .. SecondToBeat(start_sec) .. " " .. len_beats .. " " .. ( pitch -60 ) .. " " .. lyrics[i+1]
    table.insert(syllables, entry)
  end

  return syllables
end

function ProcessMarkers()

  local markers = {}

  -- LOOP THROUGH REGIONS
  local count_markers_regions, num_markers, num_regions = reaper.CountProjectMarkers( 0 )
  for i = 0, count_markers_regions - 1 do
    local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
    if iRetval >= 1 then
      if bIsrgnOut == false and sNameOut == "" then
        local marker = {}
        if offset_pages_by_one_beat then
          marker.pos = iPosOut - gap  - ( beat_duration / 4 ) -- Useful is problem of MIDI quantizing at import.
        else
          marker.pos = iPosOut - gap
        end
        marker.str = "- " .. SecondToBeat(marker.pos)
        table.insert(markers, marker)
      end
      i = i+1
    end
  end

  return markers
end

function GetUltraStarMetadata()
  local metadata = ""
  header_fields = {"LANGUAGE", "YEAR", "GENRE", "CREATOR", "EDITION"} -- Not "TITLE", "ARTIST" here
  local sharp = '#'
  for i, v in ipairs( header_fields ) do
    if i > 1 then sharp = "\n#" end
    local retval, val = reaper.GetProjExtState( proj, "UltraStar", v )
    metadata = metadata .. sharp .. v .. ":" .. val
  end

  return metadata
end

function ExportData( elms )

  local lines = {}
  for i, line in ipairs(elms) do
    local l = line.str:gsub(string.char(0), "")
    l = l:gsub("\n", "")
    table.insert(lines, l)
  end

  txt_str = table.concat(lines, "\n")

  Msg(text_str)

  metadata_str = GetUltraStarMetadata() .. "\n"
  gap_str = string.gsub( tostring(math.floor(gap * 100000) / 100), "%.", ",")
  gap_str = "#GAP:" .. gap_str .. "\n"
  bpm_str = "#BPM:" .. bpm .. "\n"
  artist_str = "#ARTIST:" .. artist .. "\n"
  title_str = "#TITLE:" .. title .. "\n"
  mp3_str = "#MP3:" .. proj_name .. ".mp3\n"
  cover_str = "#COVER:" .. proj_name .. ".jpg\n"
  video_str = "#VIDEO:" .. proj_name .. ".mp4\n"

  txt_str = artist_str .. title_str .. metadata_str .. mp3_str .. cover_str .. video_str .. bpm_str .. gap_str .. txt_str .. "\nE\n"
  
  if reaper.CF_SetClipboard then
    reaper.CF_SetClipboard(txt_str)
  end

  file = proj_name .. '.txt'
  file_path = proj_folder .. file

  local f = io.open(file_path, "w")
  io.output(file_path)
  io.write(txt_str)
  io.close(f)

  Msg(txt_str)
  console = true
  Msg(txt_str)
  Msg("Success! File:")
  Msg(file_path)

end

function Main( track ) -- local (i, j, item, take, track)

  elms = {}

  local item_num = reaper.CountTrackMediaItems(track)

  -- ACTIONS
  for j = 0, item_num-1 do
    local item = reaper.GetTrackMediaItem(track, j)
    local take = reaper.GetActiveTake(item)
    if take and reaper.TakeIsMIDI( take ) then
      local take_midi = ProcessTakeMIDI( take, j )
      if take_midi then
        table.merge( elms, take_midi )
      end
    end
  end

  local markers = ProcessMarkers()

  table.merge(elms, markers)

  -- SORT TABLE
  -- thanks to https://forums.coronalabs.com/topic/37595-nested-sorting-on-multi-dimensional-array/
  table.sort(elms, function( a,b )
    if (a.pos < b.pos) then
      -- primary sort on position -> a before b
      return true
    elseif (a.pos > b.pos) then
      -- primary sort on position -> b before a
      return false
    else
      -- primary sort tied, resolve w secondary sort on rank
      return a.str < b.str
    end
  end)

  -- Conc
  ExportData(elms)
end

track = reaper.GetSelectedTrack(0,0)

if track then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block.

  reaper.ClearConsole()

  GetArtistAndTitle()

  Main( track ) -- Execute your main function

  reaper.Undo_EndBlock("Export first selected track MIDI as UltraStar txt file", 0) -- End of the undo block.

  reaper.PreventUIRefresh(-1)

end
