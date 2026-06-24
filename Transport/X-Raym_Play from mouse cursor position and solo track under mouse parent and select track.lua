--[[
 * ReaScript Name: Play from mouse cursor position and solo track under mouse parent and select track
 * About: Just like the SWS action (which it runs), but with no undo and select track under mouse.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
  * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.3.1
--]]

--[[
 * Changelog:
 * v1.3.0 (2026-06-23)
  + Restore track solo after run
 * v1.2.1 (2026-03-21)
  # Use GetThingFromPoiunt to get track
 * v1.2 (2019-07-14)
  + Snap to grid
  # no SWS dependency
--]]

stop_at_exit = true

function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Msg(a)
  reaper.ShowConsoleMsg( tostring(a) )
end

function Exit()
  if not tracks or #tracks == 0 then return end
  reaper.PreventUIRefresh(1)
  for i, entry in ipairs( tracks ) do
    if reaper.ValidatePtr( entry.track, "MediaTrack*" ) then
      reaper.SetMediaTrackInfo_Value( entry.track , "I_SOLO", entry.solo)
    end
  end
  if stop_at_exit then
    reaper.Main_OnCommand( 1016, 0 ) -- Transport: Stop
  end
  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)
  SetButtonState()
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
   parent = reaper.GetParentTrack( track )
   if not parent then parent = track end
   count_tracks = reaper.CountTracks()
   tracks = {}
   for i = 0, count_tracks - 1 do
    local track = reaper.GetTrack(0,i)
    table.insert( tracks, {track = track, solo = reaper.GetMediaTrackInfo_Value( track, "I_SOLO") } )
    reaper.SetMediaTrackInfo_Value( track , "I_SOLO", 0)
   end

   reaper.SetMediaTrackInfo_Value( parent, "I_SOLO", 1)
   reaper.SetOnlyTrackSelected( parent )
   PlayFromMouse()
  end
  reaper.PreventUIRefresh(-1)
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

reaper.set_action_options( 1 )
reaper.defer(Main)
reaper.atexit(Exit)


