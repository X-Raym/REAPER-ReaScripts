--[[
 * ReaScript Name: Go to start of previous region (strict)
 * Description: Move edit or play cursor to previous region. Move view and seek play.
 * Instructions: Place edit cursor inside a region. Use it.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Screenshot: https://i.imgur.com/VFhTQ3F.gifv
 * Licence: GPL v3
 * Forum Thread: Scripts: Transport (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1601342
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2018-09-04)
	+ Initial Release
--]]

console = false

-- Display a message in the console for debugging
function Msg(value)
	if console then
		reaper.ShowConsoleMsg(tostring(value) .. "\n")
	end
end

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
				if not first and ( iPosOut < pos and pos < iRgnendOut ) then -- if cursor inside region and first region
					first = true
				else
					reaper.SetEditCurPos(iPosOut,true,true) -- moveview and seekplay
					break
				end
			end
			i = i+1
		end
	until iRetval == 0 
		
	reaper.Undo_EndBlock("Go to start of previous region (strict)", -1) -- End of the undo block. Leave it at the bottom of your main function.
end

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)
