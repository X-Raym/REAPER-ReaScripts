--[[
 * ReaScript Name: Save all tracks visibility
 * Description: A script to save tracks visibility. Use the restore version of this script after.
 * Instructions: Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Track Selection (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1569551
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-01-28)
	+ Initial Release
--]]

function main()

	-- Delete Previous Save
	reaper.SetProjExtState(0, "Track_Visibility", "", "", "")
	
	-- Loop in Tracks
	for i = 0, count_tracks - 1 do
	
		local track = reaper.GetTrack(0, i)
		
		local tcp_visibility = reaper.GetMediaTrackInfo_Value(track, "B_SHOWINTCP")
		local mcp_visibility = reaper.GetMediaTrackInfo_Value(track, "B_SHOWINMIXER")
		
		tcp_visibility = math.floor(tcp_visibility)
		mcp_visibility = math.floor(mcp_visibility)
		
		reaper.SetProjExtState(0, "Track_Visibility", i, tcp_visibility .. "," .. mcp_visibility)
	
	end
	
end

count_tracks = reaper.CountTracks(0)

if count_tracks > 0 then
	reaper.defer(main)
end
