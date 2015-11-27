--[[
 * ReaScript Name: Go to start of next region (smooth seek)
 * Description: Move edit or play cursor to next region.
 * Instructions: Place edit cursor inside a region. Use it.
 * Author: X-Raym
 * Author URl: http:--extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https:--github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https:--github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URl: http:--forum.cockos.com/***.html
 * REAPER: 4.77
 * Extensions: None
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-11-27)
	+ Initial Release
--]]



function main()

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	edit_pos = reaper.GetCursorPosition()
	
	play = reaper.GetPlayState()
	if play > 0 then
		pos = reaper.GetPlayPosition()
	else
		pos = edit_pos
	end
	
	retval, regionidxOut = reaper.GetLastMarkerAndCurRegion(0, pos)
	
	index = regionidxOut
	
	if index == -1 then index = retval end
	
	reaper.GoToRegion(0, index + 1, false) -- no timeline order
		
	reaper.Undo_EndBlock("Go to start of next region", -1) -- End of the undo block. Leave it at the bottom of your main function.
end

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)