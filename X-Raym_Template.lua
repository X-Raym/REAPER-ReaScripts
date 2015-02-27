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
 * Version: 1.3.1
 * Version Date: YYYY-MM-DD
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.6.0 (optional)
 --]]
 
--[[
 * Changelog:
 * v1.3.1 (2015-02-27)
 	# loops takes bug fix
 	# thanks benf and heda for help with looping through regions!
 	# thanks to Heda for the function that embed external lua files!
 * v1.0 (2015-02-27)
	+ Initial Release
 --]]

-- ----- DEBUGGING ====>
function get_script_path()
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    return debug.getinfo(1,'S').source:match("(.*".."\\"..")"):sub(2) -- remove "@"
  end
    return debug.getinfo(1,'S').source:match("(.*".."/"..")"):sub(2)
end

package.path = package.path .. ";" .. get_script_path() .. "?.lua"
require("X-Raym_Functions - console debug messages")

debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- YOUR CODE BELOW

	-- LOOP THROUGH SELECTED ITEMS
	--[[
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	-- INITIALIZE loop through selected items
	for i = 0, selected_items_count-1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		-- GET INFOS
		value_get = reaper.GetMediaItemInfo_Value(item, "D_VOL") -- Get the value of a the parameter
		-- "D_VOL"
		-- "B_MUTE"
		-- "C_LOCK"
		-- "B_LOOPSRC"
		-- "C_FADEINSHAPE"
		-- "C_FADEOUTSHAPE"
		-- "D_FADEINLEN"
		-- "D_FADEOUTLEN"
		-- "D_SNAPOFFSET"
		-- "D_POSITION"
		-- "D_LENGTH"
		
		-- MODIFY INFOS
		value_set = value_get -- Prepare value output
		
		-- SET INFOS
		reaper.SetMediaItemInfo_Value(item, "D_VOL", value_set) -- Set the value to the parameter
	end -- ENDLOOP through selected items
	--]]

	-- LOOP THROUGH SELECTED TAKES
	--[[
	selected_items_count = reaper.CountSelectedMediaItems(0)

	for i = 0, selected_items_count-1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		take = reaper.GetActiveTake(item) -- Get the active take

		if take == true then
			-- GET INFOS
			value_get = reaper.GetMediaItemTakeInfo_Value(take, "D_VOL") -- Get the value of a the parameter
			-- "D_VOL"
			-- "D_PAN"
			-- "D_PLAYRATE"
			-- "D_PITCH", Ge
			-- "I_CHANMODE"
			-- "D_STARTOFFS"
			-- "D_PANLAW"
			-- MODIFY INFOS
			value_set = value_get -- Prepare value output
			-- SET INFOS
			reaper.SetMediaItemTakeInfo_Value(take, "D_VOL", value_set) -- Set the value to the parameter
		end -- ENDIF active take
	end -- ENDLOOP through selected items
	--]]

	-- LOOP TRHOUGH SELECTED TRACKS
	--[[
	selected_tracks_count = reaper.CountSelectedTracks(0)

	for i = 0, selected_tracks_count-1  do
		-- GET THE TRACK
		track = reaper.GetSelectedTrack(0, i) -- Get selected track i
		-- ACTIONS
	end -- ENDLOOP through selected tracks
	--]]

	-- LOOP THROUGH REGIONS
	--

	i=0
	repeat
		iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut = reaper.EnumProjectMarkers(i)
		if iRetval >= 1 then
			if bIsrgnOut == true then
				-- ACTION ON REGIONS HERE
			end
			i = i+1
		end
	until iRetval == 0
	--]]


	-- LOOP TRHOUGH FX - by HeDa
	--[[
	tracks_count = reaper.CountTracks(0)

	for i = 0, tracks_count-1  do -- loop for all tracks
			
		track = reaper.GetTrack(0, i)	-- which track
		track_FX_count = reaper.TrackFX_GetCount(tracki) -- count number of FX instances on the track
		
		for i = 0, track_FX_count-1  do,	-- loop for all FX instances on each track
			-- ACTIONS
					
		end -- ENDLOOP FX loop
	end -- ENDLOOP tracks loop
	--]]

	-- YOUR CODE ABOVE

	reaper.Undo_EndBlock("My action", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

msg_start() -- Display characters in the console to show you the begining of the script execution.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

msg_end() -- Display characters in the console to show you the end of the script execution.
