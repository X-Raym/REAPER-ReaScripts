--[[
 * ReaScript Name: Copy selected items and paste at mouse cursor
 * Description: A quick way to duplicate items
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URI: http://forum.cockos.com/***.html
 * REAPER: 5.0 pre 27
 * Extensions: SWS/S&M 2.7.1 #0
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2015-05-08)
	+ Snap
 * v1.0 (2015-05-08)
	+ Initial Release
 --]]

--[[ ----- DEBUGGING ====>
local info = debug.getinfo(1,'S');

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
]]-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- YOUR CODE BELOW
	reaper.BR_ItemAtMouseCursor()
	
	track, context, position = reaper.BR_TrackAtMouseCursor()
	
	if context == 2 then
		
		reaper.Main_OnCommand(40297, 0) -- Unselect all tracks (so that it can copy items)
		reaper.Main_OnCommand(40698, 0) -- COpy selected items
		
		-- GET SNAP
		if reaper.GetToggleCommandState(1157) == 1 then 
			position = reaper.SnapToGrid(0, position)
		end
		
		reaper.SetEditCurPos2(0, position, false, false)
		reaper.SetOnlyTrackSelected(track)
		reaper.Main_OnCommand(40914,0) -- Set first sleected track as last touched
		reaper.Main_OnCommand(40058,0) -- Paste
		
	end

	reaper.Undo_EndBlock("Copy selected items and paste at mouse cursor", 0) -- End of the undo block. Leave it at the bottom of your main function.

end


-- The following functions may be passed as global if needed
--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

-- ITEMS
-- SAVE INITIAL SELECTED ITEMS
init_sel_items = {}
local function SaveSelectedItems (table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end

-- RESTORE INITIAL SELECTED ITEMS
local function RestoreSelectedItems (table)
	reaper.Main_OnCommand(40289, 0) -- Unselect all items
	for _, item in ipairs(table) do
		reaper.SetMediaItemSelected(item, true)
	end
end

-- TRACKS
-- SAVE INITIAL TRACKS SELECTION
init_sel_tracks = {}
local function SaveSelectedTracks (table)
	for i = 0, reaper.CountSelectedTracks(0)-1 do
		table[i+1] = reaper.GetSelectedTrack(0, i)
	end
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
	reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
	for _, track in ipairs(table) do
		reaper.SetTrackSelected(track, true)
	end
end

-- LOOP AND TIME SELECTION
--[[ SAVE INITIAL LOOP AND TIME SELECTION
function SaveLoopTimesel()
	init_start_timesel, init_end_timesel = reaper.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
	init_start_loop, init_end_loop = reaper.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
end

-- RESTORE INITIAL LOOP AND TIME SELECTION
function RestoreLoopTimesel()
	reaper.GetSet_LoopTimeRange(1, 0, init_start_timesel, init_end_timesel, 0)
	reaper.GetSet_LoopTimeRange(1, 1, init_start_loop, init_end_loop, 0)
end]]

-- CURSOR
-- SAVE INITIAL CURSOR POS
function SaveCursorPos()
	init_cursor_pos = reaper.GetCursorPosition()
end

-- RESTORE INITIAL CURSOR POS
function RestoreCursorPos()
	reaper.SetEditCurPos(init_cursor_pos, false, false)
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

--[[ <==== INITIAL SAVE AND RESTORE ----- ]]




--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

SaveView()
SaveCursorPos()
--SaveLoopTimesel()
SaveSelectedItems(init_sel_items)
SaveSelectedTracks(init_sel_tracks)

main() -- Execute your main function

RestoreCursorPos()
--RestoreLoopTimesel()
RestoreSelectedItems(init_sel_items)
RestoreSelectedTracks(init_sel_tracks)
RestoreView()

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
