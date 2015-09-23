--[[
 * ReaScript Name: Reset stretch marker under mouse position
 * Description:
 * Instructions: Put this on a keyboard shortcut. Run.
 * Notes : Only work if take rate is 1. SWS issue.
 * Screenshot:
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl:
 * Licence: GPL v3
 * Forum Thread: REQ: Reset stretch markers value
 * Forum Thread URl: http://forum.cockos.com/showthread.php?t=165774
 * REAPER: 5.0
 * Extensions: SWS 2.8.0
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-09-01)
	+ Initial Release
 --]]

-- ----- DEBUGGING ====>
--[[local info = debug.getinfo(1,'S');

local full_script_path = info.source

local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name

if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "..\\Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "../Functions/?.lua"
end

require("X-Raym_Functions - console debug messages")


debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]
-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	window, segment, details = reaper.BR_GetMouseCursorContext()
	--reaper.ShowConsoleMsg(details.."\n")
	if details == "item_stretch_marker" then
		
		take, mouse_pos = reaper.BR_TakeAtMouseCursor()
		
		if take ~= nil then
				
			idx = reaper.BR_GetMouseCursorContext_StretchMarker()
			--reaper.ShowConsoleMsg(idx.."\n")
			if idx ~= nil then
	
				idx, strech_pos, srcpos = reaper.GetTakeStretchMarker(take, idx)
				
				reaper.SetTakeStretchMarker(take, idx, srcpos)
			
			end
			
		end
				
	end
	
	reaper.Undo_EndBlock("Reset stretch marker under mouse position", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.
