--[[
 * ReaScript Name: Select track under mouse top level parent track
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Track Selection (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1569551
 * REAPER: 5.0
 * Version: 2.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2019-06-23)
	+ Initial Release
--]]

function main()
  track, pos = reaper.BR_TrackAtMouseCursor()
  if track then
   parent = reaper.GetParentTrack( track )
  if parent then
   reaper.SetOnlyTrackSelected( parent )
  else
  reaper.SetOnlyTrackSelected( track )
  end
  end
end
main()
