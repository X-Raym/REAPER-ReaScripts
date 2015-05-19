--[[
 * ReaScript Name: Template Title (match file name without extension and author)
 * Description: A template script for REAPER ReaScript.
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URl: http://forum.cockos.com/***.html
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.1 (optional)
 --]]
 
--[[
 * Changelog:
 * v1.8 (2015-05-11)
 	# No more call to standards actions (better for undos).
 * v1.7 (2015-05-08)
 	+ Save/Restore view without calling the SWS "slot" functions.
 * v1.6 (2015-04-15)
 	+ Save/Restore functions without calling the SWS "slot" functions.
 	# thanks to heda for the edit cursor restore
 * v1.5 (2015-03-03)
 	+ Call Functions file from relative parent subfolder
 * v1.4.1 (2015-03-03)
 	# EnumProjectMarkers3 for regions loop
 * v1.4 (2015-03-02)
 	+ Infos for track, take and items values
 	+ Restore view, loop, edit cursor and UI
 * v1.3.1 (2015-02-27)
 	# loops takes bug fix
 	# thanks benf and heda for help with looping through regions!
 	# thanks to Heda for the function that embed external lua files!
 * v1.0 (2015-02-27)
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

msg_clean()]]
-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

	markeridx, regionidx = reaper.GetLastMarkerAndCurRegion(0, reaper.GetCursorPosition())

	if regionidx ~= nil then

		reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
		
		iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,regionidx)
		reaper.BR_SetArrangeView(0, iPosOut, iRgnendOut)

		reaper.Undo_EndBlock("Zoom to region at edit cursor", -1) -- End of the undo block. Leave it at the bottom of your main function.

	end

end

--[[ reaper.PreventUIRefresh(1) ]]-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

--[[ reaper.PreventUIRefresh(-1) ]] -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
