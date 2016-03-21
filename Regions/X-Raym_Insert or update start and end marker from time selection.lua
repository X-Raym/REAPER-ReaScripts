--[[
 * ReaScript Name: Insert or update start and end marker from time selection
 * Description: Use this action for setting subproject in and out points or render section.
 * Instructions: Run
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: 
 * Licence: GPL v3
 * Forum Thread: 
 * Forum Thread URI: 
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-03-21)
	+ Initial Release
--]]


-- Main function
function main()

	-- LOOP THROUGH REGIONS
	i=0
	repeat
		iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
		if iRetval >= 1 then
			if sNameOut == '=START' then
				start_delete = iMarkrgnindexnumberOut
			end
			if sNameOut == '=END' then
				end_delete = iMarkrgnindexnumberOut
			end
			if start_delete and end_delete then
				break
			end
			i = i+1
		end
	until iRetval == 0

	if start_delete then
		reaper.DeleteProjectMarker(0, start_delete, false)
	end

	if end_delete then
		reaper.DeleteProjectMarker(0, end_delete, false)
	end

	timeselstart, timeselend = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
	if timeselstart < timeselend then 
		reaper.AddProjectMarker2(0, false, timeselstart, 0, "=START", -1, 0)
		reaper.AddProjectMarker2(0, false, timeselend, 0, "=END", -1, 0)
	end
	
end


-- INIT ---------------------------------------------------------------------

-- Here: your conditions to avoid triggering main without reason.

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

main()

reaper.Undo_EndBlock("Insert or update start and end marker from time selection", -1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateTimeline()

reaper.PreventUIRefresh(-1)
