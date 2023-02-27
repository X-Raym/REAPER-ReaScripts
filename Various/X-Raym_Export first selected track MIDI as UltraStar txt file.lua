--[[
 * ReaScript Name: Export first selected track MIDI as UltraStar txt file
 * About: Export MIDI items content, using MIDI Notes Lyrics events. One MIDI Lyric per notes. Markers are page break.
 * Instructions: Select tracks. Use it.
 * Screenshot: https://youtu.be/z1K98a7AWNA
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Creating Karaoke Songs for UltraStar and Vocaluxe with REAPER
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=202430
 * REAPER: 5.0
 * Version: 1.0.13
--]]

--[[
 * Changelog:
 * v1.0.13 (2023-02-27)
  + Ignore out of items boundaries events
 * v1.0.12 (2023-02-21)
  + Ignore muted MIDI events
 * v1.0.11 (2023-02-20)
  + Consider project offset for GAP
  # Better GAP rounding and calculation
  # Copy to clipboard false by default
 * v1.0.10 (2023-02-09)
  + Fallback to Lyrics tracks is no tracks selected
  + Preset file init
  + save file popup with JS_ReaScript API
 * v1.0.9 (2023-02-09)
  # A bit of refactoring
 * v1.0.8 (2021-01-12)
  # remove strip spaces and tilds
 * v1.0.7 (2021-01-01)
  # lyrics pos dirty fix
 * v1.0.6 (2020-04-06)
  # Fix project suffix removal with uppercase extension
  # Tighten lyric alignment based on note start/end
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
strip_spaces_and_tilds = false
save_file_popup = true -- requires JS_ReaScriptAPI

clipboard = false

-- bpm = reaper.Master_GetTempo()
bpm = 400 -- We use dummy Tempo cause it is more a precision indicator than a real musical correspondance

-- GLOBALS

beat_duration = 1 / (bpm / 60 )
gap = 0

project_offset = reaper.GetProjectTimeOffset( 0, false )

prefix = {": ", "* ", "F "}

ext_state = "XR_ExportUltrastarLyrics"

-- https://www.fhug.org.uk/wiki/wiki/doku.php?id=plugins:code_snippets:split_filename_in_to_path_filename_and_extension
function SplitFilename(strFilename)
  -- Returns the Path, Filename, and Extension as 3 values
  return string.match(strFilename, "(.-)([^\\|/]-([^\\|/%.]+))$")
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

function GetArtistAndTitle()
  proj, project_path = reaper.EnumProjects( -1, 0 )
  proj_folder, proj_name, proj_ext = SplitFilename(project_path)
  if not proj_folder then
    proj_folder = reaper.GetProjectPath('') .. "\\"
    proj_name = "Unsaved"
  end

  artist = meta.ARTIST
  title = meta.TITLE
  if ( not artist or artist == "" ) and ( not title or title == "" )then
    artist, title = proj_name:match('(.+) %- (.+)')
    if not artist then artist = "Artist" end
    if not title or title == "" then title = "Title" else title = title:sub(0,-5)  end
    reaper.SetProjExtState( 0, "UltraStar", "TITLE", title)
    reaper.SetProjExtState( 0, "UltraStar", "ARTIST", artist)
    meta.TITLE = artist
    meta.ARTIST = title
  end
  if not proj_name then proj_name = artist .. " - " .. title end
  proj_name = proj_name:sub(0,-5)
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

function IsInTime( s, start_time, end_time )
  if s >= start_time and s <= end_time then return true end
  return false
end

function ProcessTakeMIDI( take, j, item )

  local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
  local item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
  local item_end = item_pos + item_len
  
  syllables = {}

  local retval, count_notes, count_ccs, count_textsyx = reaper.MIDI_CountEvts( take )

  if count_notes == 0 or count_textsys == 0 then return end

  -- First Filter Text Event by Lyrics
  local lyrics = {} -- Note: these are stored in reverse pos order
  for i = 0, count_textsyx - 1 do
    local retval, selected, muted, ppqpos, evt_type, msg = reaper.MIDI_GetTextSysexEvt( take, i, true, true, 0, 0, "" )
    local evt_pos = reaper.MIDI_GetProjTimeFromPPQPos( take, ppqpos )
    if evt_type == 5 and not muted and IsInTime( evt_pos, item_pos, item_end ) then
      msg = msg:gsub("\r", "")  -- remove carriage return
      msg = msg:gsub("^%-", "") -- remove hyphen at the begining
      if strip_spaces_and_tilds then
        msg = msg:gsub("%s+", "") -- remove space characters
        msg = msg:gsub("~", "")   -- remove tildes
      end
      if msg:len()==0 then msg = "~" end
      table.insert(lyrics,1,{pos=ppqpos+5,msg=msg}) -- + 1 is for unexplained rounding error
    end
  end
  
  -- Check if there is non-muted lyrics
  if #lyrics == 0 then return end

  count = count_notes
  if #lyrics < count_notes then count = #lyrics end
  logging = nil
  
  if j == 0 then -- First take and first lyrics -- NOT: should be first synced lyrics for extra precision
    gap = reaper.MIDI_GetProjTimeFromPPQPos( take, lyrics[#lyrics].pos-5 ) -- -5, see above
  end

  local lyric = nil

  for i = 0, count - 1 do
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
    local note_start_pos = reaper.MIDI_GetProjTimeFromPPQPos( take, startppqpos )
    
    if not muted and IsInTime( note_start_pos, item_pos, item_end ) then

      local start_sec = reaper.MIDI_GetProjTimeFromPPQPos( take, startppqpos ) - gap
      local end_sec = reaper.MIDI_GetProjTimeFromPPQPos( take, endppqpos ) - gap
      local len_sec = end_sec - start_sec
      local len_beats = SecondToBeat(len_sec)
      if len_beats < 1 then len_beats = 1 end
      if chan + 1 > #prefix then chan = 0 end
  
      local entry = {}
      entry.pos = start_sec
      entry.str = prefix[chan+1] .. SecondToBeat(start_sec) .. " " .. len_beats .. " " .. ( pitch - 60 )
  
      -- find all lyrics aligned with this MIDI note
      local lyric = table.remove(lyrics)
      while lyric do
  
        -- if lyric timing is later than this note
        if lyric.pos >= endppqpos then
          -- put lyric back and skip scanning for more lyrics
          table.insert(lyrics,lyric)
          break
        end
  
        if lyric.pos < startppqpos then
          -- do nothing
        else
          -- lyric is for this note
          entry.str = entry.str .. " " .. lyric.msg
        end
  
        -- get next lyric
        lyric = table.remove(lyrics)
      end
  
      if logging and (i < 10 or i > count-10) then
        b = reaper.MIDI_GetProjQNFromPPQPos(take, startppqpos) + 4
        b = string.format("%03d.%5.3f", b // 4, (b % 4)+1)
        entry.str = string.format("%s %06.3f %s",entry.str,start_sec+gap,b)
        --start_sec = start_sec + gap
        --.. string.format(" gap=%03.3f t=%02d:%06.3f,%07.3f b=%s c=%02d p=%02d %s\n",gap,math.floor(start_sec/60),start_sec % 60,start_sec,b,chan,pitch-60,lyrics[i+1])
      end
  
      table.insert(syllables,entry)
    end
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
        if logging then
          proj, project_path = reaper.EnumProjects( -1, 0 )
           -- b = reaper.MIDI_GetProjQNFromProjTime(take, iPosOut) + 4
           -- b = string.format("%03d.%5.3f", b // 4, (b % 4)+1)
           marker.str = string.format("%s %06.3f s=%s", marker.str,iPosOut,iMarkrgnindexnumberOut)
        end
        table.insert(markers, marker)
      end
      i = i+1
    end
  end

  return markers
end


function ExportData( elms )
  
  -- Lyrics lines
  local lines = {}
  for i, line in ipairs(elms) do
    local l = line.str:gsub(string.char(0), "")
    l = l:gsub("\n", "")
    table.insert(lines, l)
  end

  txt_str = table.concat(lines, "\n")
  
  -- Header Lines
  meta.GAP = string.gsub( tostring(math.floor((gap+project_offset) * 1000 + 0.5 )), "%.", ",")
  meta.BPM = tostring( bpm )
  
  -- Do header with predetermined list of keys
  keys_already_done = {}
  header_fields = {"TITLE", "ARTIST", "LANGUAGE", "YEAR", "GENRE", "CREATOR", "EDITION", "MP3", "COVER", "VIDEO", "BPM", "GAP"} -- Not "TITLE", "ARTIST" here
  local file_header_t = {}
  for i, v in ipairs( header_fields ) do
    if meta[v] then
      table.insert( file_header_t, "#" .. v .. ":" .. meta[v] )
    end
    keys_already_done[v] = true
  end
  
  -- Do meta which are not on the list above
  for k, v in pairs( meta ) do
    if not keys_already_done then
      table.insert( file_header_t, "#" .. k .. ":" .. v )
    end
  end
  
  -- Concat File Header
  file_header_str = table.concat( file_header_t, "\n" )

  txt_str = file_header_str .. "\n" .. txt_str .. "\nE\n"
  
  file = proj_name .. '.txt'
  file_path = ""
  if save_file_popup and reaper.JS_Dialog_BrowseForSaveFile then
    
    ext_retval, file_path = reaper.GetProjExtState( 0, ext_state, "file_path" )
    ext_file_folder, ext_file_name = SplitFilename( file_path )
    
    retval, file_name = reaper.JS_Dialog_BrowseForSaveFile( "Save Take Sources CSV", ext_file_folder, ext_file_name, 'txt files (.txt)\0*.txt\0All Files (*.*)\0*.*\0' )
    if not retval or retval == 0 then return false end
    if file_name ~= '' then
      if not file_name:find('.txt') then file_name = file_name .. ".txt" end
      file_path = file_name
      reaper.SetProjExtState( 0, ext_state, "file_path", file_path )
    end
  else
    file_path = proj_folder .. file
  end
  
  local f = io.open(file_path, "w")
  io.output(file_path)
  io.write(txt_str)
  io.close(f)

  console = true
  Msg(txt_str)
  Msg("Success! File:")
  Msg(file_path)
  
  if reaper.CF_SetClipboard and clipboard then
    reaper.CF_SetClipboard(txt_str)
    Msg("Copied to clipboard")
  end

end

function Main( track )

  GetUltraStartExtState()

  GetArtistAndTitle()

  elms = {}

  local item_num = reaper.CountTrackMediaItems(track)

  -- ACTIONS
  for j = 0, item_num-1 do
    local item = reaper.GetTrackMediaItem(track, j)
    local take = reaper.GetActiveTake(item)
    if take and reaper.TakeIsMIDI( take ) then
      local take_midi = ProcessTakeMIDI( take, j, item )
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

function GetSelectLyricsTrack()
  local count_tracks = reaper.CountTracks( 0 )
  for i = 0, count_tracks - 1 do
    local track = reaper.GetTrack( 0, i )
    local r, track_name = reaper.GetTrackName( track )
    if track_name:lower() == "lyrics" then
      reaper.SetOnlyTrackSelected( track )
      return track
    end
  end
end

function Init()
  track = reaper.GetSelectedTrack(0,0)
  
  if not track then
    track = GetSelectLyricsTrack()
  end
  
  if track then
  
    reaper.PreventUIRefresh(1)
  
    reaper.Undo_BeginBlock() -- Begining of the undo block.
  
    reaper.ClearConsole()
  
    Main( track ) -- Execute your main function
  
    reaper.Undo_EndBlock("Export first selected track MIDI as UltraStar txt file", 0) -- End of the undo block.
  
    reaper.PreventUIRefresh(-1)
  
  end
  
end

if not preset_file_init then
  Init()
end
