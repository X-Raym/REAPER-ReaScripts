--[[
 * ReaScript Name: Set item under mouse snap offset at mouse cursor position
 * Description: See title
 * Instructions: Select items with take. Run.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl:
 * Licence: GPL v3
 * Forum Thread: Script (Lua): Shuffle Items
 * Forum Thread URl: http://forum.cockos.com/showthread.php?p=1524014
 * REAPER: 5.0 pre 31
 * Extensions: SWS 2.7.1 #0
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-05-20)
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

	-- MOUSE CONTEXT
	mouse_item, mouse_pos =  reaper.BR_ItemAtMouseCursor()
	mouse_pos = reaper.BR_PositionAtMouseCursor(-1)
	
	-- IF ITEM UNDER MOUSE
	if tostring(mouse_item) ~= "userdata: 0000000000000000" then
		
		item_pos =  reaper.GetMediaItemInfo_Value(mouse_item, "D_POSITION")
		item_end =  item_pos + reaper.GetMediaItemInfo_Value(mouse_item, "D_LENGTH")
		
		-- CHECK SNAP
		if reaper.GetToggleCommandState(1157) == 1 then
		
			mouse_pos =  reaper.SnapToGrid(0, mouse_pos)
			
			if mouse_pos < item_pos then mouse_pos = item_pos end
			
			if mouse_pos > item_end then mouse_pos = item_end end
			
		end
		
		-- SET INFOS
		reaper.SetMediaItemInfo_Value(mouse_item, "D_SNAPOFFSET", mouse_pos - item_pos) -- Set the value to the parameter
		
	end -- ENDLOOP through selected items

	reaper.Undo_EndBlock("Set item under mouse snap offset at mouse cursor position", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

--reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

--reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
