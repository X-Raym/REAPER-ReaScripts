--[[
 * ReaScript Name: Insert one new child track for each selected tracks
 * Description: A way to quickly insert child tracks.
 * Instructions: Select tracks. Execute the script.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URI: http://forum.cockos.com/***.html
 * REAPER: 5.0 pre 15
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-04-02)
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

-- Refresh TCP by HeDa
function HedaRedrawHack()
	reaper.PreventUIRefresh(1)

	track=reaper.GetTrack(0,0)

	trackparam=reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT")	
	if trackparam==0 then
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 1)
	else
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
	end
	reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", trackparam)

	reaper.PreventUIRefresh(-1)
	
end

-- Adaptation of DoSpeadSelItemsOverNewTx in SWS Xenakios ItemTakeCommands.cpp, for the function Explode selected items to new tracks (keeping positions)
function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- GET THE TRACK
	for i = 0, reaper.CountTracks(0) do
		track = reaper.GetTrack(0, i)
		id = reaper.CSurf_TrackToID(track, false)
		depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
		
		found = reaper.IsTrackSelected(track)

		if found == true then
			reaper.InsertTrackAtIndex(id,true)
			next_track = reaper.GetTrack(0, id)
			retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
			reaper.GetSetMediaTrackInfo_String(next_track, "P_NAME", track_name .. " — Child", true)
			id = id +1
			i = i+1
			
		end

		if found == true and depth ~= 1 then -- make children out of newly created tracks
			depth = depth - 1
			reaper.SetMediaTrackInfo_Value(reaper.CSurf_TrackFromID(id, false),"I_FOLDERDEPTH",depth)
			depth = 1
			reaper.SetMediaTrackInfo_Value(track,"I_FOLDERDEPTH",depth)
		end
	end

	--reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELNEXTTRACK"), 0)

	reaper.Undo_EndBlock("Insert one child track for selected tracks", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.
HedaRedrawHack()
reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.

