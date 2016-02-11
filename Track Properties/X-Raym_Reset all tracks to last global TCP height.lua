--[[
 * ReaScript Name: Reset all tracks to last global TCP height
 * Description: 
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
 * v1.0 (2016-02-11)
	+ Initial Release
--]]


function main()

	-- LOOP TRHOUGH SELECTED TRACKS
	for i = 0, tracks_count - 1  do
		-- GET THE TRACK
		local track = reaper.GetTrack(0, i) -- Get selected track i
		
		reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", 0)

	end -- ENDLOOP through selected tracks

end


-- INIT

tracks_count = reaper.CountTracks(0)

if tracks_count > 0 then

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	reaper.PreventUIRefresh(1)

	main() -- Execute your main function

	reaper.TrackList_AdjustWindows(true) -- Update the arrangement (often needed)
	
	reaper.UpdateArrange()

	reaper.PreventUIRefresh(-1)
	
	reaper.Undo_EndBlock("Reset all tracks to last global TCP height", -1) -- End of the undo block. Leave it at the bottom of your main function.
	
end
