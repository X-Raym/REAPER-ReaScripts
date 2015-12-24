--[[
 * ReaScript Name: Expand first selected item to next item end
 * Description: A template script for REAPER ReaScript.
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0 RC 10
 * Extensions: SWS/S&M 2.7.3
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-31-07)
	+ Initial Release
 --]]

--[[ ----- DEBUGGING ====>
local info = debug.getinfo(1,'S');

local full_script_path = info.source

local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name

if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "..\\Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "../Functions/?.lua"
end

require("X-Raym_Functions - console debug messages")


debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

time_os = reaper.time_precise()

msg_clean()
]]-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	item = reaper.GetSelectedMediaItem(0,0)
	
	if item ~= nil then
	
		UnselectAllItems()
		
		track = reaper.GetMediaItem_Track(item)
		
		item_id = reaper.GetMediaItemInfo_Value(item, "IP_ITEMNUMBER")
		
		next_item = reaper.GetTrackMediaItem(track, item_id + 1)
		
		if next_item ~= nil then
		
			item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
			item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
			item_end = item_pos + item_length
			
			next_item_pos = reaper.GetMediaItemInfo_Value(next_item, "D_POSITION")
			next_item_length = reaper.GetMediaItemInfo_Value(next_item, "D_LENGTH")
			next_item_end = next_item_pos + next_item_length
			
			if next_item_end > item_end then
				
				reaper.BR_SetItemEdges(item, item_pos, next_item_end)
				
			end
			
			reaper.DeleteTrackMediaItem(track, next_item)
		
		end
		
		reaper.SetMediaItemSelected(item, true)
		
	end
	
	reaper.Undo_EndBlock("Expand first selected item to next item end", -1) -- End of the undo block. Leave it at the bottom of your main function.

end


-- ITEMS
-- UNSELECT ALL ITEMS
function UnselectAllItems()
	for  i = 0, reaper.CountMediaItems(0) - 1 do
		reaper.SetMediaItemSelected(reaper.GetMediaItem(0, i), false)
	end
end

reaper.PreventUIRefresh(1)

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)