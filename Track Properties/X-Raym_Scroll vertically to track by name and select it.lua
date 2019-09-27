--[[
 * ReaScript Name: Scroll vertically to track by name and select it
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Track Selection (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1569551
 * REAPER: 5.0
 * Version: 1.2
 * Screenshot: https://i.imgur.com/6qMLP2s.gifv
--]]
 
--[[
 * Changelog:
 * v1.2 (2019-09-27)
  + User Config Area
 * v1.1 (2019-06-23)
  + Also set as last touched
 * v1.0 (2019-06-23)
  + Initial Release
--]]

-- USER CONFIG AREA -----------

popup = true -- true/false

str = "" -- choosen track name if popup is false

------------------------------

function Main()
  reaper.Main_OnCommand(40297,0)-- Unselect all tracks
  if popup then
    retval, str = reaper.GetUserInputs("Search Track Name", 1, "Track Name ?extrawidth=150", "")
  end
  if (popup and retval) or not popup then
    str = str:lower()
    count_tracks = reaper.CountTracks(0)
    for i = 0, count_tracks - 1 do
      track = reaper.GetTrack( 0, i )
      r, track_name = reaper.GetTrackName( track )
      -- if track_name:lower() == str then
      if track_name:lower():match("^(" .. str .. ")") then
        reaper.SetTrackSelected(track, true)
        reaper.Main_OnCommand(40913,0) -- Track: Vertical scroll selected tracks into view
        reaper.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
        break
      end
    end
  end
end

reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("Scroll vertically to track by name and select it", -1)
