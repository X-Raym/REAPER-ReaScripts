--[[
 * ReaScript Name: Toggle play from mouse cursor position and solo track under mouse for the duration - and select track
 * About: Just like the SWS action (which it runs), but with no undo and select track under mouse.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
  * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.1.0
--]]

--[[
 * Changelog:
 * v1.1.0 (2026-06-25)
  # remove SWS action Call
  + user preset variables
 * v1.0.2 (2019-07-14)
  # no SWS dependency
--]]

-- USER CONFIG AREA ------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

stop_at_exit = true
restore_solos = true

-------------------------------------------------- END OF USER CONFIG AREA

function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Msg(a)
  reaper.ShowConsoleMsg( tostring(a) )
end

function Exit()
  SetButtonState()
  if stop_at_exit then
    reaper.Main_OnCommand( 1016, 0 ) -- Transport: Stop
  end
  if not restore_solos or not tracks or #tracks == 0 then return end
  reaper.PreventUIRefresh(1)
  for i, entry in ipairs( tracks ) do
    if reaper.ValidatePtr( entry.track, "MediaTrack*" ) then
      reaper.SetMediaTrackInfo_Value( entry.track , "I_SOLO", entry.solo)
    end
  end
  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)
end

function PlayFromMouse()
  local pos_init = reaper.GetCursorPosition()
  reaper.SetEditCurPos( pos, false, false )
  reaper.OnPlayButton()
  reaper.SetEditCurPos( pos_init, false, false )
end

function Process()
  reaper.PreventUIRefresh(1)

  if reaper.GetThingFromPoint then
    mouse_x, mouse_y = reaper.GetMousePosition()
    track, info = reaper.GetThingFromPoint( mouse_x, mouse_y )
    pos = reaper.BR_PositionAtMouseCursor( false )
  else
    track, pos = reaper.BR_TrackAtMouseCursor()
  end

  if reaper.GetToggleCommandState( 1157 ) then
    pos = reaper.SnapToGrid( 0, pos )
  end
  if track and reaper.ValidatePtr(track, "MediaTrack*") then
   count_tracks = reaper.CountTracks()
   tracks = {}
   for i = 0, count_tracks - 1 do
    local track = reaper.GetTrack(0,i)
    table.insert( tracks, {track = track, solo = reaper.GetMediaTrackInfo_Value( track, "I_SOLO") } )
    reaper.SetMediaTrackInfo_Value( track , "I_SOLO", 0)
   end
   reaper.SetMediaTrackInfo_Value( track , "I_SOLO", 1)
   reaper.SetOnlyTrackSelected( track )
   PlayFromMouse()
  end
  reaper.PreventUIRefresh(-1)

  -- Old Format
  --if track then
    --reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_TOGGLE_PLAY_MOUSE_SOLO_TRACK"),-1)
    --reaper.SetOnlyTrackSelected( track )
  --end
end

function Main()
  if not first_run then
    Process()
    first_run = true
    SetButtonState(1)
  end

  if reaper.GetPlayState() > 0 then
    reaper.defer(Main)
  end

end

if not reaper.BR_TrackAtMouseCursor and not GetThingFromPoint then
  return reaper.ShowMessageBox("Please install SWS extension", "Warning", 1)
end

function Init()
  reaper.set_action_options( 1 )
  reaper.defer(Main)
  reaper.atexit(Exit)
end

if not preset_file_init then
  Init()
end

