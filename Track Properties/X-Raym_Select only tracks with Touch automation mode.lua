--[[
 * ReaScript Name: Select only tracks with Touch automation mode
 * Description: A template script for REAPER ReaScript.
 * Instructions: Here is how to use it. (optional)
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
 * v1.0 (2015-09-07)
	+ Initial Release
 --]]

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	count_tracks = reaper.CountTracks(0)
	
	for i = 0, count_tracks - 1  do
		-- GET ITEMS
		track = reaper.GetTrack(0, i)
		
		track_mode = reaper.GetMediaTrackInfo_Value(track, "I_AUTOMODE")
		--(0=trim/off, 1=read, 2=touch, 3=write, 4=latch
		
		if track_mode == 2 then

			reaper.SetTrackSelected(track, true)
		
		else
		
			reaper.SetTrackSelected(track, false)
		
		end
				
	end -- ENDLOOP through selected tracks

	reaper.Undo_EndBlock("Select only tracks with Touch automation mode", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.