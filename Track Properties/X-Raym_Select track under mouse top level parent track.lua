--[[
 * ReaScript Name: Select track under mouse top level parent track
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
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

function GetTopLevelParentTrack( track )
  local parent = reaper.GetParentTrack( track )
  if parent then
   track = GetTopLevelParentTrack( parent )
   end
    return track
end

function main()
  track, pos = reaper.BR_TrackAtMouseCursor()
  if track then
    top_parent = GetTopLevelParentTrack( track )
    reaper.SetOnlyTrackSelected( top_parent )
  end
end

main()
