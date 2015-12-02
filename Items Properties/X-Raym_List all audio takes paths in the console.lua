--[[
 * ReaScript Name: List all audio takes paths in the console
 * Description: A simple code snippet
 * Instructions: Select an item. Use it.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts (LUA): Text Items Formatting Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156757
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.3 #0
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-07-14)
	+ Initial Release
 --]]

items = {}

count_items = reaper.CountMediaItems(0)
for i = 0, 250 do
item = reaper.GetMediaItem(0, i)
take = reaper.GetActiveTake(item)
if take ~= nil then
path = reaper.GetMediaSourceFileName(reaper.GetMediaItemTake_Source(take), "")
reaper.ShowConsoleMsg(path.."\n")
end
end
