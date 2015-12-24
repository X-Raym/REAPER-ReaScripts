--[[
 * ReaScript Name: Keep selected items with X channels only
 * Description: See title.
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items selection (Various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163321
 * REAPER: 5.0 pre 15
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-06-25)
	+ Initial Release
 --]]

-- ----- DEBUGGING ====>
--[[local info = debug.getinfo(1,'S');

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

msg_clean()]]
-- <==== DEBUGGING -----

function main(output) -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.


	-- GET SELECTED NOTES (from 0 index)
	for i = 0, count_sel_items-1 do
				
		item = reaper.GetSelectedMediaItem(0, count_sel_items-1-i)
		take = reaper.GetActiveTake(item)
		
		if take ~= nil then
		
			if reaper.TakeIsMIDI(take) == false then
		
				take_pcm = reaper.GetMediaItemTake_Source(take)
			
				take_pcm_chan = reaper.GetMediaSourceNumChannels(take_pcm)
				take_chan_mod = reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE")
				
				select = 0
				
				if output == 1 and ((take_chan_mod > 1 and take_chan_mod < 67) or take_pcm_chan == 1) then
					select = 1
				end
				
				if output == 2 and (take_chan_mod > 66 or (take_chan_mod <= 1 and take_pcm_chan == output)) then
					select = 1
				end
				
				if output > 1 and take_chan_mod <= 1 and take_pcm_chan == output then
					select = 1
				end
				
				if select == 0 then reaper.SetMediaItemSelected(item, false) end
			
			else
				reaper.SetMediaItemSelected(item, false)
			end
			
		else
			reaper.SetMediaItemSelected(item, false)
		end
			
	end

	reaper.Undo_EndBlock("Keep selected items with X channels only", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

count_sel_items = reaper.CountSelectedMediaItems(0)

retval, output = reaper.GetUserInputs("Keep selected items with X channels only", 1, "Number of channel", "2")

if retval and count_sel_items > 0 and output ~= "" then

	reaper.PreventUIRefresh(1)
	
	output = tonumber(output)
	
	if output ~= nil then
		main(output) -- Execute your main function
	end
	
	reaper.UpdateArrange() -- Update the arrangement (often needed)

	reaper.PreventUIRefresh(-1)
	
end