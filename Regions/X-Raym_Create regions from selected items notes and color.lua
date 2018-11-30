--[[
 * ReaScript Name: Create regions from selected items notes and color
 * Description: Like the SWS action but with color
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Links
    Forum Thread https://forum.cockos.com/showthread.php?p=1670961
 * Licence: GPL v3
 * REAPER: 5.90
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2018-11-30)
	+ Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems ()
	for i = 0, count_sel_items - 1 do
		local entry = {}
		entry.item = reaper.GetSelectedMediaItem(0,i)
		entry.pos_start = reaper.GetMediaItemInfo_Value(entry.item, "D_POSITION")
		entry.pos_end = entry.pos_start + reaper.GetMediaItemInfo_Value(entry.item, "D_LENGTH")
		local take = reaper.GetActiveTake( entry.item )
		retval, entry.name = reaper.GetSetMediaItemInfo_String( entry.item, 'P_NOTES', '', false )
		if take then
			entry.color = reaper.GetDisplayedMediaItemColor2( entry.item, take )
		else
			entry.color = reaper.GetDisplayedMediaItemColor( entry.item )
		end
		table.insert(init_sel_items, entry)
	end
end


-- Display a message in the console for debugging
function Msg(value)
	if console then
		reaper.ShowConsoleMsg(tostring(value) .. "\n")
	end
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function Main()

	for j, item in ipairs( init_sel_items ) do

		reaper.AddProjectMarker2( 0, true, item.pos_start, item.pos_end, item.name, 0, item.color )

	end

end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

	reaper.PreventUIRefresh(1)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	reaper.ClearConsole()

	init_sel_items =  {}
	SaveSelectedItems(init_sel_items)

	Main()

	reaper.Undo_EndBlock("Create regions from selected items notes and color", -1) -- End of the undo block. Leave it at the bottom of your main function.

	reaper.UpdateArrange()

	reaper.PreventUIRefresh(-1)

end
