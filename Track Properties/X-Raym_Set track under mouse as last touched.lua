--[[
 * ReaScript Name: Set track under mouse as last touched
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
 * v1.0 (2021-03-10)
  + Initial Release
--]]

-- SAVE INITIAL TRACKS SELECTION
init_sel_tracks = {}
local function SaveSelectedTracks (table)
  for i = 0, reaper.CountSelectedTracks(0)-1 do
    table[i+1] = reaper.GetSelectedTrack(0, i)
  end
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
  reaper.Main_OnCommand( 40297 , 0) -- Track: Unselect all tracks
  for _, track in ipairs(table) do
    reaper.SetTrackSelected(track, true)
  end
end

function main()
  track, pos = reaper.BR_TrackAtMouseCursor()
  if track then
    reaper.SetOnlyTrackSelected( track ) -- this set last touched
  end
end

reaper.PreventUIRefresh(1)
SaveSelectedTracks(init_sel_tracks)

main() -- Execute your main function

RestoreSelectedTracks(init_sel_tracks)
reaper.UpdateArrange() -- Update the arrangement (often needed)
reaper.PreventUIRefresh(-1)

