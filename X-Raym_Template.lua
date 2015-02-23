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
 * Forum Thread URl: http://forum.cockos.com//***.html
 * Version: 1.2.1
 * Version Date: YYYY-MM-DD
 * REAPER: 5.0 pre 14
 * Extensions: SWS/S&M 2.6.0 (optional)
 ]]--
 
--[[
 * Changelog:
 * v1.3.1 (2015-02-20)
 	# loops takes bug fix
 * v1.3 (2015-02-19)
	+ Instructions header field
	+ Get and Set parameters for items
	+ Get and Set parameters for takes
 * v1.2.1 (2015-02-17)
	# loops indentation
 * v1.2 (2015-02-13)
	+ Items, Takes, Tracks, Regions and FX loops
	# Underscore variables
 * v1.1 (2015-02-15)
	+ Basic scripts actions template
 * v1.0 (2015-01-09)
	+ Initial Release
	+ New functions
	- Deleted functions
	# Updated functions
 ]]--

-- ----- DEBUGGING ====>
@import X-Raym_Functions - console debug messages.lua

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
	
	i = 0 -- INITIALIZE loop through selected items
	loop(selected_items_count, (item = reaper.GetSelectedMediaItem(0, i)) ? (
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
		) -- ENDIF inside loop selected items
		i += 1 -- INCREMENT loop through selected items
	) -- ENDLOOP through selected items
	]]--

	-- LOOP THROUGH SELECTED TAKES
	--[[
	selected_items_count = reaper.CountSelectedMediaItems(0)

	i = 0 -- INITIALIZE loop through selected items
	loop(selected_items_count, (item = reaper.GetSelectedMediaItem(0, i)) ? (
			(take = reaper.GetActiveTake(item)) ? (
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
			) -- ENDIF active take
		) -- ENDIF inside loop selected items
		i += 1 -- INCREMENT loop through selected items
	) -- ENDLOOP through selected items
	]]--

	-- LOOP TRHOUGH SELECTED TRACKS
	--[[
	selected_tracks_count = reaper.CountSelectedTracks(0)

	i = 0 -- INITIALIZE loop through selected tracks
	loop(selected_tracks_count, (track = reaper.GetSelectedTrack(0, i)) ? (
			-- ACTIONS
		) -- ENDIF inside loop
		i += 1 -- INCREMENT loop through selected tracks
	) -- ENDLOOP through selected tracks


	-- LOOP THROUGH REGIONS
	--[[
	i = 0 -- INITIALIZE loop through regions

	while (reaper.EnumProjectMarkers(i, is_region, region_start, region_end, #name, region_id)) (    
		is_region === 1 ? (
			-- ACTIONS	
		)
		i += 1 -- INCREMENT loop through regions
	) -- ENDWHILE loop through regions
	]]--


	-- LOOP TRHOUGH FX - by HeDa
	--[[
	tracks_count = reaper.CountTracks(0)

	i=0 -- INITIALIZE track loop
	loop (tracks_count, -- loop for all tracks
			
		track = reaper.GetTrack(0, i)	-- which track
		track_FX_count = reaper.TrackFX_GetCount(tracki) -- count number of FX instances on the track
		
		i=0 -- INITIALIZE FX loop
		loop (track_FX_count,	-- loop for all FX instances on each track
			-- ACTIONS
			i+=1 -- INCREMENT FX loop						
		) -- ENDLOOP FX loop
		
		i+=1 -- INCREMENT tracks loop
	) -- ENDLOOP tracks loop
	]]--

	-- YOUR CODE ABOVE

	reaper.Undo_EndBlock("My action", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

msg_start() -- Display characters in the console to show you the begining of the script execution.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

msg_end() -- Display characters in the console to show you the end of the script execution.
