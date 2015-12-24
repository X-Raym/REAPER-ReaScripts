--[[
 * ReaScript Name: Explode multi channel items on two tracks without render (stereo)
 * Description: Just like Explode multichannel audio to new-one channel items, but without MIDI, and without render. Use it with stereo items.
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (Lua): Explode Multi-Channel Items
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1506005
 * REAPER: 5.0 pre 29
 * Extensions: 2.7.1 #0
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2015-05-08)
	# Better restorations
 * v1.0 (2015-04-03)
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
]]-- <==== DEBUGGING -----

-- INIT
save_track = {}
save_item = {}
first = true
group_id = 1000


-- From Insert one new child track for each selected tracks X-Raym's script
function InsertChild() -- local (i, j, item, take, track)
	
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELTRKWITEM"), 0) -- Select only track with selected items

	-- GET THE TRACK
	for i = 0, reaper.CountTracks(0) do
		
		track = reaper.GetTrack(0, i)
		id = reaper.CSurf_TrackToID(track, false)
		depth = reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
		
		found = reaper.IsTrackSelected(track)

		if found == true then
			reaper.InsertTrackAtIndex(id,true)
			next_track = reaper.GetTrack(0, id)
			retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
			
			if first == true then

				reaper.GetSetMediaTrackInfo_String(next_track, "P_NAME", track_name .. " — Child R", true)
				reaper.SetMediaTrackInfo_Value(next_track, "D_PAN", 1)

			else
				reaper.GetSetMediaTrackInfo_String(next_track, "P_NAME", track_name .. " — Child L", true)
				reaper.SetMediaTrackInfo_Value(next_track, "D_PAN", -1)
			end
			
			id = id +1
			i = i+1
			
		end

		if found == true and depth ~= 1 then -- make children out of newly created tracks
			depth = depth - 1
			reaper.SetMediaTrackInfo_Value(reaper.CSurf_TrackFromID(id, false),"I_FOLDERDEPTH",depth)
			depth = 1
			reaper.SetMediaTrackInfo_Value(track,"I_FOLDERDEPTH",depth)
		end
	
	end
	
	first = false

end

function HedaRedrawHack()
	reaper.PreventUIRefresh(1)

	track=reaper.GetTrack(0,0)

	trackparam=reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT")	
	
	if trackparam==0 then
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 1)
	else
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
	end
	
	reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", trackparam)

	reaper.PreventUIRefresh(-1)
	
end

function Main() -- local (i, j, item, take, track)
	
	-- INITIALIZE loop through selected items
	for i = 0, count_selected_items-1  do

		reaper.Main_OnCommand(40289, 0) -- Unselect all items
		item = save_item[i]

		take = reaper.GetActiveTake(item) -- Get the active take
		if take ~= nil and reaper.TakeIsMIDI(take) == false then
			take_name = reaper.GetTakeName(take)

			track = reaper.GetMediaItem_Track(item)
			reaper.SetOnlyTrackSelected(track)
			reaper.SetMediaItemSelected(item, 1)
			
			reaper.Main_OnCommand(41173, 0) -- Move cursor at item start
			reaper.Main_OnCommand(40698, 0) -- Copy the item
			reaper.SetMediaItemInfo_Value(item, "I_GROUPID", group_id+i)
			reaper.Main_OnCommand(40914, 0) -- Set selected track as last touched
			reaper.Main_OnCommand(40058, 0) -- Paste item
			reaper.Main_OnCommand(40118, 0) -- Move to next track

			new_item = reaper.GetSelectedMediaItem(0, 0)
			new_take = reaper.GetActiveTake(new_item) -- Get the active take

			reaper.SetMediaItemInfo_Value(new_item, "I_GROUPID", group_id+i)
			reaper.GetSetMediaItemTakeInfo_String(new_take, "P_NAME", take_name .. " — L", true)
			reaper.SetMediaItemTakeInfo_Value(new_take, "I_CHANMODE", 3) -- Set take to R

			reaper.Main_OnCommand(41173, 0) -- Move cursor at item start
			reaper.Main_OnCommand(40058, 0) -- Paste item
			reaper.Main_OnCommand(40118, 0) -- Move to next track
			reaper.Main_OnCommand(40118, 0) -- Move to next track

			reaper.SetMediaItemInfo_Value(item, "B_MUTE", 1) -- Set take to R

			new_item = reaper.GetSelectedMediaItem(0, 0)
			new_take = reaper.GetActiveTake(new_item) -- Get the active take

			reaper.SetMediaItemInfo_Value(new_item, "I_GROUPID", group_id+i)
			reaper.GetSetMediaItemTakeInfo_String(new_take, "P_NAME", take_name .. " — R", true)
			reaper.SetMediaItemTakeInfo_Value(new_take, "I_CHANMODE", 4) -- Set take to L

		end -- END if audio

	end -- ENDLOOP through selected items

end -- END function Main

--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

-- ITEMS
-- SAVE ITEMS SELECTION
function SaveItems()
	for f = 0, count_selected_items-1 do
		save_item[f] = reaper.GetSelectedMediaItem(0, f)
	end
end

-- RESTORE ITEMS SELECTION
function RestoreItems()
	reaper.Main_OnCommand(40289, 0) -- Unselect all items
	for p = 0, count_selected_items-1 do
		reaper.SetMediaItemSelected(save_item[p], true)
	end
end

-- CURSOR
-- SAVE INITIAL CURSOR POS
function SaveCursorPos()
	init_cursor_pos = reaper.GetCursorPosition()
end

-- RESTORE INITIAL CURSOR POS
function RestoreCursorPos()
	reaper.Main_OnCommand(40042, 0) -- Go to start of the project
	reaper.MoveEditCursor(init_cursor_pos, false)
end

-- VIEW
--SAVE INITIAL VIEW
function SaveView()
	start_time_view, end_time_view = reaper.BR_GetArrangeView(0)
end

-- RESTORE INITIAL VIEW
function RestoreView()
	reaper.BR_SetArrangeView(0, start_time_view, end_time_view)
end

--[[ <==== INITIAL SAVE AND RESTORE ----- ]]

--msg_start() -- Display characters in the console to show you the begining of the script execution.
count_selected_items = reaper.CountSelectedMediaItems(0)

if count_selected_items > 0 then
	reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.
	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	SaveView()
	SaveCursorPos()

	InsertChild()
	InsertChild()
	SaveItems()
	
	Main() -- Execute your main function
	
	RestoreItems()

	reaper.UpdateArrange() -- Update the arrangement (often needed)

	RestoreCursorPos()
	RestoreView()
	
	reaper.Undo_EndBlock("Explode multi channel items on two tracks without render (stereo)", 0) -- End of the undo block. Leave it at the bottom of your main function.

	reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

	HedaRedrawHack()
	--msg_end() -- Display characters in the console to show you the end of the script execution.
end
