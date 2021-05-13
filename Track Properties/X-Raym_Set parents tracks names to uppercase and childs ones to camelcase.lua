--[[
 * ReaScript Name: Set parents tracks names to uppercase and childs ones to camelcase
 * Description: A way to reveal Parents and Childs tracks by their name
 * Instructions: Run
 * Screenshot: http://i.giphy.com/l41lMgnQVFZp2qfjW.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Tracks Names (various) 
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1581214
 * REAPER: 5.0
 * Version: 2.0.1
 * Provides:
 *   [nomain] ../Functions/utf8.lua
 *   [nomain] ../Functions/utf8data.lua
]]
 
 
--[[
 * Changelog:
 * v2.0.1 (2021-05-13)
  + Camel Case each words
 * v2.0 (2019-03-01)
  + UTF-8 support
 * v1.0 (2015-10-07)
  + Initial Release
]]

local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "../Functions/utf8.lua")
dofile(script_path .. "../Functions/utf8data.lua")

function main()
  
  reaper.Undo_BeginBlock() -- Begin undo group
  
  for i = 0, count_tracks - 1 do
  
    track = reaper.GetTrack(0, i)
    
    track_depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    
    retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    
    if track_depth == 1 then
      
      track_name = utf8upper(track_name)
  
    else
      t = {}
      for word in track_name:gmatch("[^ ]*") do
          table.insert(t, utf8upper( utf8.sub(word, 0, 1) ) .. utf8lower( utf8.sub(word, 2, utf8.len(word) ) ) )
      end
      track_name = table.concat( t, " " )
    
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