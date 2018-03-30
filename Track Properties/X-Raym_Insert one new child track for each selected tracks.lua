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
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2018-03-30)
	# Works with all selected tracks
	# Optimization
	# User Config Area
 * v1.0 (2015-04-02)
	+ Initial Release
--]]

-- USER CONFIG AREA -----------------

preserve_track_name = true
suffix = " — Child" -- suffix or new name if preserve_track_name is false

------------- END OF USER CONFIG AREA

-- Adaptation of DoSpeadSelItemsOverNewTx in SWS Xenakios ItemTakeCommands.cpp, for the function Explode selected items to new tracks (keeping positions)
function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- GET THE TRACK
	for i = reaper.CountTracks(0)- 1, 0, -1 do
		track = reaper.GetTrack(0, i)
		id = reaper.CSurf_TrackToID(track, false)
		depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
		
		found = reaper.IsTrackSelected(track)

		if found == true then
		reaper.SetMediaTrackInfo_Value(track, 'I_FOLDERDEPTH', 1)
			reaper.InsertTrackAtIndex(id,true)
			next_track = reaper.GetTrack(0, id)
			retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
			if preserve_track_name then
				new_name = track_name .. suffix
			else
				new_name = suffix
			end
			reaper.GetSetMediaTrackInfo_String(next_track, "P_NAME", new_name, true)
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

	reaper.Undo_EndBlock("Insert one new child track for each selected tracks", 0) -- End of the undo block. Leave it at the bottom of your main function.

end


reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.
reaper.TrackList_AdjustWindows( false )
reaper.UpdateArrange() -- Update the arrangement (often needed)
