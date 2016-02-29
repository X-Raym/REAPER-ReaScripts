--[[
 * ReaScript Name: Stutter edit selected media items
 * Description: Divide selected items length and duplicate
 * Instructions: Run
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2016-02-29)
	+ Initial Release
--]]

-- Notes : it doesn't work with groups items

-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console
divider = 2

------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems (table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end

function RestoreSelectedItems (table)
	for i, item in ipairs(table) do
		reaper.SetMediaItemSelected(item, true)
	end
end


-- Display a message in the console for debugging
function Msg(value)
	if console then
		reaper.ShowConsoleMsg(tostring(value) .. "\n")
	end
end


-- Copy selected media items
function CopySelectedMediaItems(track, pos)

	local cursor_pos = reaper.GetCursorPosition()

	reaper.SetOnlyTrackSelected(track)

	reaper.Main_OnCommand(40914, 0) -- Select first track as last touched

	reaper.SetEditCurPos(pos, false, false)

	reaper.Main_OnCommand(40698, 0) -- Copy Items

	reaper.Main_OnCommand(40058, 0) -- Paste Items

	new_item = reaper.GetSelectedMediaItem(0, 0) -- Get First Selected Item

	reaper.SetEditCurPos(cursor_pos, false, false)

	return new_item

end


-- VIEW
-- SAVE INITIAL VIEW
function SaveView()
	start_time_view, end_time_view = reaper.BR_GetArrangeView(0)
end

-- RESTORE INITIAL VIEW
function RestoreView()
	reaper.BR_SetArrangeView(0, start_time_view, end_time_view)
end
--------------------------------------------------------- END OF UTILITIES


-- Main function
function main()

	new_items = {}

	for i, item in ipairs(init_sel_items) do

		reaper.SelectAllMediaItems(0, false) -- Unselect all media items

		reaper.SetMediaItemSelected(item, true) -- Select only desired item

		new_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") / divider

		reaper.SetMediaItemInfo_Value(item, "D_LENGTH", new_len) -- Set item to its new length

		pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

		track = reaper.GetMediaItemTrack(item) -- Get destination track (in this case, item parent track)

		for j = 1, divider - 1 do

			new_pos = pos + new_len * j

			new_item = CopySelectedMediaItems(track, new_pos)

			table.insert(new_items, new_item)

		end

	end

end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

	reaper.PreventUIRefresh(1)

	SaveView()

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	init_sel_items =  {}
	SaveSelectedItems(init_sel_items)

	main()

	RestoreSelectedItems(init_sel_items)
	RestoreSelectedItems(new_items)

	reaper.Undo_EndBlock("Stutter edit selected media items", -1) -- End of the undo block. Leave it at the bottom of your main function.

	reaper.UpdateArrange()

	RestoreView()

	reaper.PreventUIRefresh(-1)

end
