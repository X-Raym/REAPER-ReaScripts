--[[
 * ReaScript Name: Convert Lyrics track items notes for the dedicated web browser interface
 * About: Have a track named lyrics and text items on it. Run the web interface.
 * Screenshot: https://monosnap.com/file/kmpXyGbYgvYwUbrDe4ZsbbeNmSUR13
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Link: Forum https://forum.cockos.com/showthread.php?p=2127630#post2127630
 * Version: 1.2
--]]

--[[
 * Changelog:
 * v1.2 (2022-06-07)
  + Next item preliminary support (false by default)
  # encode in one single line
 * v1.1.1 (2022-05-24)
  # works at pos <=
 * v1.1 (2021-02-11)
  + Send dummy text if notes == "", for having instructions on web interface is script is not running.
 * v1.0 (2019-08-26)
  + Initial Release
--]]


-- GLOBALS -------------------------------------------------

str_no_text = "--XR-NO-TEXT--"

ext_name = "XR_Lyrics"
ext_keys = { "text", "next" }

next = false

-- DEBUG

function Msg( val )
  reaper.ShowConsoleMsg( tostring( val ) .. "\n" )
end

-- DEFER

 -- Set ToolBar Button State
function SetButtonState( set )
  if not set then set = 0 end
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  for i, k in ipairs( ext_keys ) do
    reaper.SetProjExtState( 0, ext_name, k, "" )
  end
  SetButtonState()
end

-- FUNCTIONS

function GetLyricsTrack()
  local lyrics_track = nil
  local count_tracks = reaper.CountTracks()
  for i = 0, count_tracks - 1 do
    local track = reaper.GetTrack(0,i)
    local retval, track_name = reaper.GetTrackName( track )
    if track_name:lower() == "lyrics" then
      lyrics_track = track
      break
    end
  end
  return lyrics_track
end

function GetTrackItemAtPos( track, pos )
  local count_track_items = reaper.GetTrackNumMediaItems( track )
  local current_item
  for i = 0, count_track_items - 1 do
    local item = reaper.GetTrackMediaItem( track, i )
    local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
    if item_pos <= pos then -- if item is after cursor then ignore
      local item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
      if item_pos + item_len > pos then -- if item end is after cursor, then item is under cusor
        current_item = item
        break
      end
    end
  end
  return current_item
end

function GetNextTrackItem( track, pos, start_item )
  local id_start = start_item and reaper.GetMediaItemInfo_Value( item, "IP_ITEMNUMBER" ) or 0
  local count_track_items = reaper.GetTrackNumMediaItems( track )
  local next_item
  for i = id_start, count_track_items - 1 do
    local item = reaper.GetTrackMediaItem( track, i )
    local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
    if item_pos > pos then
      next_item = item
      break
    end
  end
  return next_item
end

function ProcessItemNotes( item, ext_key, text )
  if not item then
    reaper.SetProjExtState( 0, ext_name, ext_key, str_no_text )
    return nil
  end
  local item_notes = reaper.ULT_GetMediaItemNote( item ):gsub("\r?\n", "<br>")
  if item_notes ~= text then
    text = item_notes == "" and str_no_text or item_notes
    reaper.SetProjExtState( 0, ext_name, ext_key, text )
  end
  return text
end


-- Main Function (which loop in background)
function Main()

  -- Get play or edit cursor
  cur_pos = reaper.GetPlayState() > 0 and reaper.GetPlayPosition() or reaper.GetCursorPosition()

  if reaper.ValidatePtr(lyrics_track, 'MediaTrack*') then
  
    item = GetTrackItemAtPos( lyrics_track, cur_pos )
    notes = ProcessItemNotes( item, "text", notes )

    if next then
    
      next_item = GetNextTrackItem( lyrics_track, cur_pos, item )
      next_notes = ProcessItemNotes( next_item, "next", next_notes )

    end

  else

    lyrics_track = GetLyricsTrack()

  end

  reaper.defer( Main )

end

-- RUN -----------------------------------------------------

reaper.ClearConsole()

lyrics_track = GetLyricsTrack()

if lyrics_track then
  SetButtonState( 1 )
  Main()
  reaper.atexit( Exit )
else
  reaper.MB('No tracks named "Lyrics".', "Error", 0)
end
