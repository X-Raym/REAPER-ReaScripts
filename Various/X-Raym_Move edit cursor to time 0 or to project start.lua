--[[
 * ReaScript Name: Move edit cursor to time 0 or to project start
 * Description: Move edit cursor to time 0 if project start is negative or null. Move edit cursor to project start if project start is > 0.
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URl: http://forum.cockos.com/***.html
 * Version: 1.0
 * Version Date: 2015-02-28
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.6.0 (optional)
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-02-28)
	+ Initial Release
	+ Thanks to benf for the help on format_timestr_pos
	+ Thanks to spk77 for his Clock.eel script
 --]]

--[[ ----- DEBUGGING ====>
function get_script_path()
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    return debug.getinfo(1,'S').source:match("(.*".."\\"..")"):sub(2) -- remove "@"
  end
    return debug.getinfo(1,'S').source:match("(.*".."/"..")"):sub(2)
end

package.path = package.path .. ";" .. get_script_path() .. "?.lua"
require("X-Raym_Functions - console debug messages")

debug = 0 -- 0 => No console. 1 => Display console messages for debugging.
clean = 0 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	if reaper.GetPlayState() == 0 or reaper.GetPlayState == 2 then
		cursor_pos = reaper.GetCursorPosition()
		--msg_stl("proj time decimal", cursor_pos, 1)

		buf = reaper.format_timestr_pos(cursor_pos, "", 3)
		--msg_stl("proj time string", buf, 1)
		
		time = tonumber(buf)
		--msg_ftl("proj time decimal", time, 1)
		
		offset = cursor_pos - time
		--msg_ftl("offset", time, 1)
		
		reaper.SetEditCurPos(offset, 1, 0)
	end

	

	reaper.Undo_EndBlock("Move edit cursor to time 0 or to project start", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
