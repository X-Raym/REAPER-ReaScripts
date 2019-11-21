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
 * Version: 2.0
 * Provides:
 *   [nomain] ../Functions/utf8.lua
 *   [nomain] ../Functions/utf8data.lua
]]
 
 
--[[
 * Changelog:
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
  

  -- LOOP IN REGIONS
        i=0
        repeat
        
          retval, isrgn, pos, rgnend, name, markrgnindex, color = reaper.EnumProjectMarkers3(0, i)
          

            name = utf8upper( utf8.sub(name, 0, 1) ) .. utf8.sub(name, 2, utf8.len(name) )
            reaper.SetProjectMarker3( 0,markrgnindex, isrgn, pos, rgnend, name, color )


        i = i+1
        
      until retval == 0 -- end loop regions and markers
  
  reaper.Undo_EndBlock("Set parents tracks names to uppercase and childs ones to camelcase", -1) -- End undo group

end

-- RUN

  
  reaper.PreventUIRefresh(1)
  
  main()
  
  reaper.TrackList_AdjustWindows(false)
  
  reaper.PreventUIRefresh(-1)


