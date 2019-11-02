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
 * Version: 1.1.1
]]
 
 
--[[
 * Changelog:
 * v1.1.1 (2019-11-02)
  # No provides
 * v1.1 (2019-10-04)
  + Suffix support for parent track
 * v1.0 (2019-08-27)
  + Initial Release
]]

popup = true
suffix = "S"

local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]

--[[
 * Old Provides Rules:
 *   [nomain] ../Functions/utf8.lua
 *   [nomain] ../Functions/utf8data.lua
-- ]]

dofile(script_path .. "../Functions/utf8.lua")
dofile(script_path .. "../Functions/utf8data.lua")

function main()
  
  reaper.Undo_BeginBlock() -- Begin undo group
  
  counter = 0
  
  for i = 0, count__sel_tracks - 1 do
  
    track = reaper.GetSelectedTrack(0, i)
    
    track_depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    
    retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    
    if track_depth == 1 then
    
      counter = 0
      
      track_name = utf8upper(retvals_csv) .. suffix
  
    else
    
      counter = counter + 1
  
      track_name = utf8upper( utf8.sub(retvals_csv, 0, 1) ) .. utf8lower( utf8.sub(retvals_csv, 2, utf8.len(retvals_csv) ) ) .. " " .. counter
    
    end
    
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", track_name, true)
  
  end
  
  reaper.Undo_EndBlock("Set parents tracks names to uppercase and childs ones to camelcase", -1) -- End undo group

end

-- RUN
count__sel_tracks = reaper.CountSelectedTracks()

if count__sel_tracks > 0 then

  if popup then
    retval, retvals_csv = reaper.GetUserInputs("Rename Tracks", 1, "Name:,Separator,extrawidth=200", "" )
  end
  
  if not popup or (retval and retvals_csv ~= "") then
  
    reaper.PreventUIRefresh(1)
    
    main()
    
    reaper.TrackList_AdjustWindows(false)
    
    reaper.PreventUIRefresh(-1)
    
  end

end
