--[[
 * ReaScript Name: Set parents tracks names to uppercase and childs ones to camelcase
 * Description: A way to reveal Parents and Childs tracks by their name
 * Instructions: Run
 * Screenshot: http://i.giphy.com/l41lMgnQVFZp2qfjW.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Scripts: Tracks Names (various) 
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1581214
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
]]
 
 
--[[
 * Changelog:
 * v1.0 (2015-10-07)
  + Initial Release
]]

function main()
  
  reaper.Undo_BeginBlock() -- Begin undo group
  
  for i = 0, count_tracks - 1 do
  
    track = reaper.GetTrack(0, i)
    
    track_depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    
    retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    
    if track_depth == 1 then
      
      track_name = track_name:upper()
  
    else
      
      track_name = track_name:lower()
      track_name = track_name:gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
    
    end
    
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", track_name, true)
  
  end
  
  reaper.Undo_EndBlock("Set parents tracks names to uppercase and childs ones to camelcase", -1) -- End undo group

end

-- RUN
count_tracks = reaper.CountTracks()

if count_tracks > 0 then
  
  reaper.PreventUIRefresh(1)
  
  main()
  
  reaper.TrackList_AdjustWindows(false)
  
  reaper.PreventUIRefresh(-1)

end
