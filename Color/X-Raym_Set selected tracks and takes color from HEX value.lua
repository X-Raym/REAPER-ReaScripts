--[[
 * ReaScript Name: Set selected tracks and takes color from HEX value
 * Description: Set selected tracks and takes color from HEX value. Use # or not.
 * Instructions: Select tracks or items. Execute the script.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts (LUA): Create Text Items Actions (various)
 * Forum Thread URl: http://forum.cockos.com/showthread.php?t=156763
 * Version: 1.0
 * Version Date: 2015-03-12
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.6.2
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-03-12)
	+ Initial Release
 --]]

function main()

	reaper.Undo_BeginBlock()

	-- YOUR CODE BELOW

	color_int = (R + 256 * G + 65536 * B)|16777216

	countItems = reaper.CountSelectedMediaItems(0)

	-- SELECTED ITEMS LOOP
	if countItems > 0 then
		for i = 0, countItems-1 do
			item = reaper.GetSelectedMediaItem(0, i)
			take = reaper.GetActiveTake(item)
			if take ~= nil then
				reaper.SetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR", color_int)
			else
				reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color_int)
			end
		end
	end

	countTracks = reaper.CountSelectedTracks(0)

	-- SELECTED TRACKS LOOP
	if countTracks > 0 then
		for j = 0, countTracks-1 do
			track = reaper.GetSelectedTrack(0, j)
			reaper.SetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR", color_int)
		end
	end

	reaper.Undo_EndBlock("Set color hex value for selected tracks and takes", 0)
end


defaultvals_csv = "123456"
--msg_start() -- Display characters in the console to show you the begining of the script execution.
retval, retvals_csv = reaper.GetUserInputs("Color selected Track and Items", 1, "HEX Value", defaultvals_csv) 
			
if retval then -- if user complete the fields

	if retvals_csv ~= nil then
		hex = retvals_csv:gsub("#","")
		R = tonumber("0x"..hex:sub(1,2))
		G = tonumber("0x"..hex:sub(3,4))
		B = tonumber("0x"..hex:sub(5,6))

		main() -- Execute your main function

		reaper.UpdateArrange() -- Update the arrangement (often needed)

	end

end