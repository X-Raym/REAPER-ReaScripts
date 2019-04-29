--[[
 * ReaScript Name: Convert Lyrics track items notes for the dedicated web browser interface
 * About: Have a track named lyrics and text items on it. Run the web interface.
 * Screenshot: https://monosnap.com/file/kmpXyGbYgvYwUbrDe4ZsbbeNmSUR13
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Link: Forum https://forum.cockos.com/showthread.php?p=2127630#post2127630
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2019-08-26)
  + Initial Release
 --]]
 
 -- Set ToolBar Button State
function SetButtonState( set )
  if not set then set = 0 end
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end


-- Main Function (which loop in background)
function main()
  
  -- Get play or edit cursor
  if reaper.GetPlayState() > 0 then
    cur_pos = reaper.GetPlayPosition()
  else
    cur_pos = reaper.GetCursorPosition()
  end
  
  if reaper.ValidatePtr(lyrics_track, 'MediaTrack*') then
    track_items = reaper.GetTrackNumMediaItems( lyrics_track )
    no_item = true
    for i = 0, track_items - 1 do
      item = reaper.GetTrackMediaItem( lyrics_track, i )
      item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
      if item_pos < cur_pos then -- if item is after cursor then ignore
        item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
        if item_pos + item_len > cur_pos then -- if item end is after cursor, then item is under cusor
          item_notes = reaper.ULT_GetMediaItemNote( item )
          no_item = false
          if item_notes ~= notes then
            notes = item_notes
            reaper.SetProjExtState( 0, "XR_Lyrics", "text", notes )
            break
          end
        end
      end
    end
    
    if no_item and notes then
      notes = nil
      reaper.SetProjExtState( 0, "XR_Lyrics", "text", "" )
    end
    
  else
    
    GetLyricsTrack()
    
  end
    
  reaper.defer( main )
  
end

function GetLyricsTrack()
  lyrics_track = nil
  count_tracks = reaper.CountTracks()
  for i = 0, count_tracks - 1 do
    track = reaper.GetTrack(0,i)
    retval, track_name = reaper.GetTrackName( track )
    if track_name:lower() == "lyrics" then
      lyrics_track = track
      break
    end
  end
end

lyrics_track = nil
notes = nil

GetLyricsTrack()

if lyrics_track then
  -- RUN
  SetButtonState( 1 )
  main()
  reaper.atexit( SetButtonState )
else
  reaper.MB('No tracks named "Lyrics".', "Error", 0)
end

