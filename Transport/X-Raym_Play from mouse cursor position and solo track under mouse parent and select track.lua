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
   parent = reaper.GetParentTrack( track )
   if reaper.GetPlayState() > 0 then
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_TOGGLE_PLAY_MOUSE"),-1)
   end
   if not parent then parent = track end
   count_tracks = reaper.CountTracks()
   for i = 0, count_tracks - 1 do
	reaper.SetMediaTrackInfo_Value( reaper.GetTrack(0,i), "I_SOLO", 0) 
   end

   reaper.SetMediaTrackInfo_Value( parent, "I_SOLO", 1)
   reaper.SetOnlyTrackSelected( parent )
   reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_TOGGLE_PLAY_MOUSE"),-1) -- SWS/BR: Toggle play from mouse cursor position
  end
  reaper.PreventUIRefresh(-1)
end

if not reaper.BR_TrackAtMouseCursor then
	reaper.ShowMessageBox("Please install SWS extension", "Warning", 1)
else
	reaper.defer(main)
end

