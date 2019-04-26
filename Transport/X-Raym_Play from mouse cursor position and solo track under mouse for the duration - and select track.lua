--[[
 * ReaScript Name: Play from mouse cursor position and solo track under mouse for the duration - and select track
 * About: Just like the SWS action (which it runs), but with no undo and select track under mouse.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > ReaScripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]

function main()
  reaper.PreventUIRefresh(1)
  track, pos = reaper.BR_TrackAtMouseCursor()
  if track then
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

