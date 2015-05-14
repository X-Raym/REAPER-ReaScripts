--[[
 * ReaScript Name: Template Title (match file name without extension and author)
 * Description: A template script for REAPER ReaScript.
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
 * v1.0 (2015-02-27)
	+ Initial Release
 --]]

-- ----- DEBUGGING ====>
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
-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- LOOP TRHOUGH SELECTED TRACKS
	-
	selected_tracks_count = reaper.CountSelectedTracks(0)

	for i = 0, selected_tracks_count-1  do
		-- GET THE TRACK
		track = reaper.GetSelectedTrack(0, i) -- Get selected track i

		-- ACTIONS
		if folder_compact = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT") == 0 then 
			reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 2) 
		else
			reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0) 
		end

	end -- ENDLOOP through selected tracks

	reaper.Undo_EndBlock("My action", 0) -- End of the undo block. Leave it at the bottom of your main function.

end


--reaper.PreventUIRefresh(-1)

main() -- Execute your main function

--[[ reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
