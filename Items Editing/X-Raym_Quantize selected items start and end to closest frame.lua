--[[
 * ReaScript Name: Quantize selected items start and end to closest frame
 * Description: Quantize to frame grid. Nice for subtitles.
 * Instructions: You may consider selecting your items and using SWS/FNG Clean selected overlapping items on same track after that
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URI: http://forum.cockos.com/***.html
 * REAPER: 5 pre 28
 * Extensions: SWS/S&M 2.7.1
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-05-28)
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

msg_clean()
]]-- <==== DEBUGGING -----

function RoundToX(number, interval)
	round = math.floor((number+(interval/2))/interval) * interval
	
	--msg_f(interval)
	--msg_f(number)
	--msg_f(round)
	
	return round
end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	frameRate, dropFrameOut = reaper.TimeMap_curFrameRate(0)
	
	frame_duration = 1/frameRate

	-- LOOP THROUGH SELECTED ITEMS
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	-- INITIALIZE loop through selected items
	for i = 0, selected_items_count-1  do
		
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		-- GET INFOS
		item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
		item_end = item_pos + item_len
		
		-- MODIFY INFOS
		new_item_pos = RoundToX(item_pos, frame_duration)
		new_item_end = RoundToX(item_end, frame_duration)
		
		--if new_item_pos < item_pos then new_item_pos = new_item_pos + frame_duration end
		--if new_item_end > item_end then new_item_end = new_item_end - frame_duration end
		
		-- SET INFOS
		reaper.BR_SetItemEdges(item, new_item_pos, new_item_end) -- Set the value to the parameter
	
	end -- ENDLOOP through selected items

	reaper.Undo_EndBlock("Quantize selected items start and end to closest frame", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1)

reaper.UpdateArrange() -- Update the arrangement (often needed)