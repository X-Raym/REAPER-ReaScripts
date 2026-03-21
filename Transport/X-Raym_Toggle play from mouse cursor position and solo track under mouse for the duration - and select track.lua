--[[
 * ReaScript Name: Toggle play from mouse cursor position and solo track under mouse for the duration - and select track
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
 * v1.0.2 (2019-07-14)
  # no SWS dependency
--]]

function main()


  if reaper.GetThingFromPoint then
    mouse_x, mouse_y = reaper.GetMousePosition()
    track, info = reaper.GetThingFromPoint( mouse_x, mouse_y )
  else
    track, pos = reaper.BR_TrackAtMouseCursor()
  end

  if track and reaper.ValidatePtr(track, "MediaTrack*") then
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_TOGGLE_PLAY_MOUSE_SOLO_TRACK"),-1)
    reaper.SetOnlyTrackSelected( track )
  end

end

if not reaper.BR_TrackAtMouseCursor then
  reaper.ShowMessageBox("Please install SWS extension", "Warning", 1)
else
  reaper.defer(main)
end

