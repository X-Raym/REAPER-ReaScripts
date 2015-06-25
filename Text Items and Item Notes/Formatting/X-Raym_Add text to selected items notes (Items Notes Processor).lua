--[[
 * ReaScript Name: Add text to selected items notes (Items Notes Processor)
 * Description: Equivalent to SWS label processor, but for items notes
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URl: http://forum.cockos.com/***.html
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.1 (optional)
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-05-06)
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

function main(csv) -- local (i, j, item, take, track)
	
	csv = csv:gsub(", ", "¤¤¤")
	
	-- PARSE THE STRING
	before_after, text = csv:match("([^,]+),([^,]+)")
	
	if text ~= nil then
	
		text = text:gsub("¤¤¤", ", ")
		
		before_after = tonumber(before_after)
		
		if (before_after == 1 or before_after == 0) and text ~= nil then
		
			reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the 
		
			-- INITIALIZE loop through selected items
			for i = 0, selected_items_count-1  do
				-- GET ITEMS
				item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
				
				track = reaper.GetMediaItemTrack(item)
				track_id = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
				track_name_retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
				
				-- /D -- Duration
				-- /E[digits, first] -- enumerate in selection
				-- /e[digits, first] -- enumerate in selection on track
				-- /I[digits, first] -- inverse enumerate in selection
				-- /i[digits, first] -- inverse enumerate in selection on track
				-- /T[offset, length] -- Track name
				-- /t[digits] -- Track number
				input = text:gsub("/E", tostring(i + 1))
				input = input:gsub("/I", tostring(selected_items_count - i))
				input = input:gsub("/T", track_name)
				input = input:gsub("/t", tostring(track_id))
				
				notes = reaper.ULT_GetMediaItemNote(item)
				
				if notes == nil then
					reaper.ULT_SetMediaItemNote(item, notes)
				else
					
					if before_after == 0 then -- before
						notes = input .. "\n" .. notes
						reaper.ULT_SetMediaItemNote(item, notes)
					end
					
					if before_after == 1 then -- after
						notes = input .. "\n" .. text
						reaper.ULT_SetMediaItemNote(item, notes)
					end
					
				end
			
			end -- end of items loop
		
		reaper.Undo_EndBlock("Add text to selected items notes (Items Notes Processor)", -1) -- End of the undo block. Leave it at the bottom of your main function.
		
		end -- end of it there is before after
	
	end -- end of if there is text

end -- end of function

reaper.PreventUIRefresh(1)

selected_items_count = reaper.CountSelectedMediaItems(0)

if selected_items_count > 0 then
	retval, output_csv = reaper.GetUserInputs("Item Notes Processor", 2, "Before (0)/After (1):,Text", "0,") 

	if retval then
	
		main(output_csv) -- Execute your main function
	
	end

end
reaper.PreventUIRefresh(-1)

reaper.UpdateArrange() -- Update the arrangement (often needed)