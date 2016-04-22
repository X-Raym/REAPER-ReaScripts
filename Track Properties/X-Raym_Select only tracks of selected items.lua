--[[
 * ReaScript Name: Select only tracks of selected items
 * Description: A template script for REAPER ReaScript.
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URI: http://forum.cockos.com/***.html
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.1 (optional)
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-07-28)
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

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	--reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
	UnselectAllTracks()

	-- LOOP THROUGH SELECTED ITEMS
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	-- INITIALIZE loop through selected items
	-- Select tracks with selected items
	for i = 0, selected_items_count - 1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		-- GET ITEM PARENT TRACK AND SELECT IT
		track = reaper.GetMediaItem_Track(item)
		reaper.SetTrackSelected(track, true)
				
	end -- ENDLOOP through selected tracks

	reaper.Undo_EndBlock("Select only tracks of selected items", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

-- UNSELECT ALL TRACKS
function UnselectAllTracks()
	first_track = reaper.GetTrack(0, 0)
	reaper.SetOnlyTrackSelected(first_track)
	reaper.SetTrackSelected(first_track, false)
end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
