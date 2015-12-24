--[[
 * ReaScript Name: Group selected items according to their order in selection per track
 * Description: Select item. Run. It will group and colorize item based on their position in selection per track (firsts selected items on selected track together, seconds together etc...)
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (Lua): Shuffle Items
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=159961
 * REAPER: 5.0 pre 15
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-05-26)
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

-- INIT
count_sel_items_on_track = {}

-------------------------------------------------------------
function CountSelectedItems_OnTrack(track)
	
	count_items_on_track = reaper.CountTrackMediaItems(track)
	
	selected_item_on_track = 0
	
	for i = 0, count_items_on_track - 1  do

		item = reaper.GetTrackMediaItem(track, i)

		if reaper.IsMediaItemSelected(item) == true then
			selected_item_on_track = selected_item_on_track + 1
		end	

	end
	
	return selected_item_on_track

end

-------------------------------------------------------------
function GetSelectedItems_OnTrack(track_sel_id, idx)
	
	--track = reaper.GetSelectedTrack(0, track_sel_id)
	--msg("Track_sel_id = "..track_sel_id)
	--msg("idx = "..idx)
	--msg("sel_items_on_track = "..count_sel_items_on_track[ track_sel_id ])
	
	if idx < count_sel_items_on_track[ track_sel_id ] then
		offset = 0
		for m = 0, track_sel_id do
			----msg("m = "..m)
			previous_track_sel = count_sel_items_on_track[ m-1 ]
			if previous_track_sel == nil then previous_track_sel = 0 end
			offset =  offset + previous_track_sel
		end
		--msg("offset = "..offset)
		get_sel_item = init_sel_items[ offset + idx + 1]
	else
		get_sel_item = nil
	end
	
	return get_sel_item

end

-------------------------------------------------------------
function SelectTracksOfSelectedItems()

	-- LOOP THROUGH SELECTED ITEMS
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	-- INITIALIZE loop through selected items
	-- Select tracks with selected items
	for i = 0, selected_items_count - 1  do
		
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		-- GET ITEM PARENT TRACK AND SELECT IT
		track = reaper.GetMediaItem_Track(item)
		reaper.SetTrackSelected(track, true)
		
	end -- ENDLOOP through selected items

end

-------------------------------------------------------------
function MaxValTable(table)
	
	max_val = 0
	
	for i = 0, #table do
	
		val = table[i]
		if val > max_val then 
			max_val = val 
		end
	
	end
	
	return max_val

end
-------------------------------------------------------------
function debug(table)
	
	for i = 1, #table do

		msg("Val = " .. i .. "=>"..reaper.ULT_GetMediaItemNote(table[i]))
	
	end
	
	return max_val

end
-------
function msg(variable)		
		reaper.ShowConsoleMsg(tostring(variable).."\n")
end

-------------------------------------------------------------
function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	--reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
	UnselectAllTracks()

	SelectTracksOfSelectedItems()

	selected_tracks_count = reaper.CountSelectedTracks(0)

		-- LOOP TRHOUGH SELECTED TRACKS
	for i = 0, selected_tracks_count - 1  do
		
		-- GET THE TRACK
		track = reaper.GetSelectedTrack(0, i) -- Get selected track i

		-- LOOP THROUGH ITEM IDX
		count_sel_items_on_track[i] = CountSelectedItems_OnTrack(track)
		
	end -- ENDLOOP through selected tracks
	
	
	-- MAXIMUM OF ITEM SELECTED ON A TRACK
	max_sel_item_on_track = MaxValTable(count_sel_items_on_track)
	
	--debug(init_sel_items)
	
	-- LOOP COLUMN OF ITEMS ON TRACK
	for j = 0, max_sel_item_on_track - 1 do
	
	--msg("\n*****\nCOLUMN = "..j)
	
		reaper.Main_OnCommand(40289, 0) -- unselect all items
	
		-- LOOP TRHOUGH SELECTED TRACKS
		for k = 0, selected_tracks_count - 1  do
			
			--msg("----\nTRACK SEL = "..k)
			
			-- LOOP THROUGH ITEM IDX
			item = GetSelectedItems_OnTrack(k, j)
			--msg(item)
			
			if item ~= nil then
				--msg("Notes = "..reaper.ULT_GetMediaItemNote(item))
				reaper.SetMediaItemSelected(item, true)
			end
		
		end -- ENDLOOP through selected tracks
		
		reaper.Main_OnCommand(40706, 0) -- set items to one random color
		reaper.Main_OnCommand(40032, 0) -- set items to one random color
	end
	

	reaper.Undo_EndBlock("Group selected items according to their order in selection per track", -1) -- End of the undo block. Leave it at the bottom of your main function.

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
-- UNSELECT ALL TRACKS
function UnselectAllTracks()
	first_track = reaper.GetTrack(0, 0)
	reaper.SetOnlyTrackSelected(first_track)
	reaper.SetTrackSelected(first_track, false)
end

-- SAVE INITIAL TRACKS SELECTION
init_sel_tracks = {}
local function SaveSelectedTracks (table)
	for i = 0, reaper.CountSelectedTracks(0)-1 do
		table[i+1] = reaper.GetSelectedTrack(0, i)
	end
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
	UnselectAllTracks()
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
--[[ SAVE INITIAL CURSOR POS
function SaveCursorPos()
	init_cursor_pos = reaper.GetCursorPosition()
end

-- RESTORE INITIAL CURSOR POS
function RestoreCursorPos()
	reaper.SetEditCurPos(init_cursor_pos, false, false)
end]]

-- VIEW
--[[ SAVE INITIAL VIEW
function SaveView()
	start_time_view, end_time_view = reaper.BR_GetArrangeView(0)
end


-- RESTORE INITIAL VIEW
function RestoreView()
	reaper.BR_SetArrangeView(0, start_time_view, end_time_view)
end]]

--[[ <==== INITIAL SAVE AND RESTORE ----- ]]




--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

--SaveView()
--SaveCursorPos()
--SaveLoopTimesel()
SaveSelectedItems(init_sel_items)
SaveSelectedTracks(init_sel_tracks)

--reaper.ShowConsoleMsg("")
main() -- Execute your main function

--RestoreCursorPos()
--RestoreLoopTimesel()
RestoreSelectedItems(init_sel_items)
RestoreSelectedTracks(init_sel_tracks)
--RestoreView()

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
