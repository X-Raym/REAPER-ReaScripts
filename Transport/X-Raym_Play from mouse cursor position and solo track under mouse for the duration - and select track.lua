--[[
 * ReaScript Name: Play from mouse cursor position and solo track under mouse for the duration - and select track
 * About: Just like the SWS action (which it runs), but with no undo and select track under mouse.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
  * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.2
--]]

--[[
 * Changelog:
 * v1.0.2 (2026-03-21)
  # Use GetThingFromPoiunt to get track
--]]

function main()
  reaper.PreventUIRefresh(1)

  if reaper.GetThingFromPoint then
    mouse_x, mouse_y = reaper.GetMousePosition()
    track, info = reaper.GetThingFromPoint( mouse_x, mouse_y )
    pos = reaper.BR_PositionAtMouseCursor( false )
  else
    track, pos = reaper.BR_TrackAtMouseCursor()
  end

  if track and reaper.ValidatePtr(track, "MediaTrack*") then
   if reaper.GetPlayState() > 0 then
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_TOGGLE_PLAY_MOUSE_SOLO_TRACK"),-1)
   end
   reaper.Main_OnCommand(40340, 0)
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_TOGGLE_PLAY_MOUSE_SOLO_TRACK"),-1)
  reaper.SetOnlyTrackSelected( track )
  end
  reaper.PreventUIRefresh(-1)
end

if not reaper.BR_TrackAtMouseCursor then
  reaper.ShowMessageBox("Please install SWS extension", "Warning", 1)
else
  reaper.defer(main)
end

