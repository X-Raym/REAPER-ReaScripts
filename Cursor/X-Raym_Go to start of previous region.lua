--[[
 * ReaScript Name: Go to start of previous region
 * Description: Move edit or play cursor to previous region. Move view and seek play.
 * Instructions: Place edit cursor inside a region. Use it.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Transport (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1601342
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
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
	
	count_markers_regions, count_markersOut, count_regionsOut = reaper.CountProjectMarkers(0)
	
	i=1
	repeat
		iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,count_markers_regions-i)
		if iRetval >= 1 then
			if bIsrgnOut == true and iPosOut < pos then
				-- ACTION ON REGIONS HERE
				reaper.SetEditCurPos(iPosOut,true,true) -- moveview and seekplay
				break
			end
			i = i+1
		end
	until iRetval == 0
		
	reaper.Undo_EndBlock("Go to start of previous region", -1) -- End of the undo block. Leave it at the bottom of your main function.
end

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)