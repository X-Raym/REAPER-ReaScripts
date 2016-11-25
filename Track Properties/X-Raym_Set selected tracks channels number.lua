--[[
 * ReaScript Name: Set selected tracks channel number
 * Description: Select tracks. Run.
 * Author: X-Raym
 * Author URl: https://www.extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Version: 1.1
 * REAPER: 5.0 pre 15
 * Extensions: None
 --]]
 
--[[
 * Changelog:
 * v1.1 (2016-11-25)
	+ User config area
 * v1.0 (2015-06-12)
	+ Initial Release
--]]

-- USER CONFIG AREA

number = 4

prompt = true -- true/false

-- END OF USER CONFIG AREA

function main(number) -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	for i = 0, selected_tracks_count-1  do
		-- GET THE TRACK
		track = reaper.GetSelectedTrack(0, i) -- Get selected track i

		--SET INFOS
		reaper.SetMediaTrackInfo_Value(track, "I_NCHAN", number)
		
	end -- ENDLOOP through selected tracks

	reaper.Undo_EndBlock("Set selected tracks channel number", -1) -- End of the undo block. Leave it at the bottom of your main function.

end


selected_tracks_count = reaper.CountSelectedTracks(0)

if prompt then
	retval, number = reaper.GetUserInputs("Set Tracks Channel number", 1, "Number of channels (2-64, even)", tostring(number) )
end

if ( retval or prompt == false ) and selected_tracks_count > 0 then

	reaper.PreventUIRefresh(1)
	
	output = tonumber(number)
	if not output then return end

	if (output % 2 ~= 0) then output = output + 1 end
	if output > 64 then output = 64 end
	if output < 2 then output = 2 end
	main(output) -- Execute your main function

	reaper.UpdateArrange() -- Update the arrangement (often needed)

	reaper.PreventUIRefresh(-1)
	
	reaper.UpdateArrange() -- Update the arrangement (often needed)
	
end