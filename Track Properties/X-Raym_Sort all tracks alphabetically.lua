--[[
 * ReaScript Name: Sort all tracks alphabetically
 * Description: See title
 * Instructions: Run.
 * Screenshot: http://i.giphy.com/3oEdv7ULuP7JOEeHUQ.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script Request Sticky? - Page 27
 * Forum Thread URI: http://forum.cockos.com/showpost.php?p=1574912&postcount=1078
 * REAPER: 5.0
 * Extensions: SWS 2.8.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-09-22)
	+ Initial Release
 --]]
 
--[[ TO DO
-make it works with track level, preserving parent/chils relationship
-make it preserve send
]]

-- DEBUG
debug_flag = false
function Msg(variable)
	if debug_flag == true then
		reaper.ShowConsoleMsg(tostring(variable).."\n")
	end
end

-- MAIN
function main()

	reaper.Undo_BeginBlock()

	-- LOOP TRACKS
	tracks = {}
	tracks_init = {}
	names = {}
	for i = 1, count_track do

		track = reaper.GetTrack(0, i-1)
		retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
		
		reaper.SetOnlyTrackSelected(track)
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_CUTSNDRCV3"),0)
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERDEPTH", 0)
		
		tracks[i] = {}
		tracks[i].track = track
		tracks_init[i] = track
		tracks[i].name = track_name
		retval, tracks[i].state = reaper.GetTrackStateChunk(track, "", false)
	
	end -- loop tracks
	
	Msg("ORIGINAL")
	for i = 1, #tracks do
		Msg(tracks[i].name)
	end
	
	table.sort(tracks, function( a,b )
		if (a.name < b.name) then
			-- primary sort on position -> a before b
			return true
		elseif (a.name > b.name) then
			-- primary sort on position -> b before a
			return false
		else
			-- primary sort tied, resolve w secondary sort on rank
			return a.name < b.name
		end
	end)
	
	Msg("ORDER")
	for i = 1, #tracks do
		Msg(tracks[i].name)
		retval = reaper.SetTrackStateChunk(reaper.GetTrack(0,i-1), tracks[i].state, false)
	end
	
	reaper.Undo_BeginBlock("Sort all tracks alphabetically", -1)

end


-- INIT
count_track = reaper.CountTracks(0)

if count_track > 0 then

	retval = reaper.ShowMessageBox("All your track routing (Parents/Childs, Sends/returns) will be lost.\nI strongly advice you to make a backup.\nReady to process?", "Warning", 1)

	reaper.PreventUIRefresh(1)

	main()
	
	reaper.TrackList_AdjustWindows(false)
	reaper.UpdateTimeline()
	reaper.UpdateArrange()
	
	reaper.PreventUIRefresh(-1)

end