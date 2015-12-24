--[[
 * ReaScript Name: Unlock selected items for 5 seconds
 * Description: A way to temporary unlock an item.
 * Instructions: Select item. Run. Wait.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: unlock for a given time
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=162188
 * REAPER: 5.0 pre 15
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-06-15)
	+ Initial Release
 --]]

time = 5 -- time in seconds you need for pause
time1 = reaper.time_precise()

function timer()  
 time2 = reaper.time_precise() 
 if time2 - time1 < time then 
 
 reaper.defer(timer) 
 else 
  reaper.atexit(unlock) -- stop running script and run unlock   
 end   
end

function unlock()
  reaper.Main_OnCommand(40579, 0)
  reaper.Main_OnCommand(40582, 0)
end 

-- PERFORM:

-- 1. Toggle locking
reaper.Main_OnCommand(40579, 0) 
reaper.Main_OnCommand(40582, 0)
reaper.UpdateArrange()

-- 2. Run
timer()  
