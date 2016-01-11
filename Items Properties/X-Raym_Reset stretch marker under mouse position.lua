--[[
 * ReaScript Name: Reset stretch marker under mouse position
 * Description:
 * Instructions: Put this on a keyboard shortcut. Run.
 * Notes : Only work if take rate is 1. SWS issue.
 * Screenshot:
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: REQ: Reset stretch markers value
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=165774
 * REAPER: 5.0
 * Extensions: SWS 2.8.3
 * Version: 1.0.1
--]]
 
--[[
 * Changelog:
 * v1.0.1 (2016-01-11)
	+ Initial Release
 * v1.0 (2015-09-01)
	+ Initial Release
 --]]

function main() -- local (i, j, item, take, track)
	
	window, segment, details = reaper.BR_GetMouseCursorContext()
	--reaper.ShowConsoleMsg(details.."\n")
	if details == "item_stretch_marker" then
		
		take, mouse_pos = reaper.BR_TakeAtMouseCursor()
		
		if take ~= nil then
				
			idx = reaper.BR_GetMouseCursorContext_StretchMarker()
			--reaper.ShowConsoleMsg(idx.."\n")
			if idx ~= nil then
			
				reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
				idx, strech_pos, srcpos = reaper.GetTakeStretchMarker(take, idx)
				
				reaper.SetTakeStretchMarker(take, idx, srcpos)
				
				reaper.Undo_EndBlock("Reset stretch marker under mouse position", -1) -- End of the undo block. Leave it at the bottom of your main function.
			
			end
			
		end
				
	end

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.
