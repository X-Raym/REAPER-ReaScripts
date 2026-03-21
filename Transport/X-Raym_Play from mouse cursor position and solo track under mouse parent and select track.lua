--[[
 * ReaScript Name: Play from mouse cursor position and solo track under mouse parent and select track
 * About: Just like the SWS action (which it runs), but with no undo and select track under mouse.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
  * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.2.1
--]]

--[[
 * Changelog:
 * v1.2.1 (2026-03-21)
  # Use GetThingFromPoiunt to get track
 * v1.2 (2019-07-14)
  + Snap to grid
  # no SWS dependency
--]]

function PlayFromMouse()
  local pos_init = reaper.GetCursorPosition()
  reaper.SetEditCurPos( pos, false, false )
  reaper.OnPlayButton()
  reaper.SetEditCurPos( pos_init, false, false )
  reaper.PreventUIRefresh(-1)
end

function main()
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
   for i = 0, count_tracks - 1 do
  reaper.SetMediaTrackInfo_Value( reaper.GetTrack(0,i), "I_SOLO", 0)
   end

   reaper.SetMediaTrackInfo_Value( parent, "I_SOLO", 1)
   reaper.SetOnlyTrackSelected( parent )
   PlayFromMouse()
  end
  reaper.PreventUIRefresh(-1)
end

if not reaper.BR_TrackAtMouseCursor then
  reaper.ShowMessageBox("Please install SWS extension", "Warning", 1)
else
  reaper.defer(main)
end

